import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediverse/models/appointment.dart' show Appointment;
import 'package:mediverse/models/doctor.dart';
import 'package:mediverse/models/user.dart';
import 'package:mediverse/screens/connection_lost_screen.dart';
import 'package:mediverse/services/connection_utils.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.6:5000/api';
  //static const String baseUrl = 'http://10.241.93.81:5000/api';
  //static const String baseUrl = 'http://10.0.0.64:5000/api';
  // static const String baseUrl = 'http://localhost:5000/api';


  static Future<UserModel?> getUserById(String userId) async {
    await checkBackendConnection(); // auto-navigate if failed

    final res = await http.get(Uri.parse('$baseUrl/auth/profile/$userId'));
    if (res   == null) return null;

    //return UserModel.fromJson(jsonDecode(res.body));

    if (res.statusCode == 200) return UserModel.fromJson(jsonDecode(res.body));
    throw Exception('Load profile failed');
  }

  static Future<Map<String, dynamic>> signup({
    required String fullname,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullname,
        'email': email, // map phone to dummy email if needed
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 201,
      'data': data,
      'message': data['message'] ?? 'Unknown error',
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'data': data,
        'message': data['message'] ?? 'Invalid login',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to server',
      };
    }
  }

  static Future<UserModel> getUserById_old(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/auth/profile/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load user');
    }
  }

  // User profile update function
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String birthdate,
    required String gender,
    required String phone,
    required List<String> languages,
    String? profileImageUrl,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-profile/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'birthdate': birthdate,
        'gender': gender,
        'preferredLanguage': languages,
        'phoneNumber': phone,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      }),
    );

    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'data': data,
      'message': data['message'] ?? 'Error updating profile',
    };
  }


  static Future<List<Doctor>> fetchDoctorsByLanguages({
    required List<String> languages,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctors/filter-languages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'languages': languages}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Doctor.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch doctors');
    }
  }


  static Future<List<Doctor>> fetchDoctorsByGenderAndLanguages({
    required String gender,
    required List<String> languages,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctors/filter-gender-language'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'gender': gender,
        'languages': languages,
      }),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Doctor.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  static Future<bool> createAppointment({
    required String userId,
    required String doctorId,
    required DateTime date,
    required int duration,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'doctorId': doctorId,
        'date': date.toIso8601String(),
        'duration': duration,
      }),
    );

    debugPrint('Response ${response.statusCode}: ${response.body}');
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/auth/profile/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  static Future<List<Appointment>> fetchAppointments(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/appointments/user/$userId'));
    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Appointment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch appointments');
    }
  }

  static Future<List<Appointment>> fetchAppointmentsForDoctor(
      String doctorId, {
        String? filterStatus,
      }) async {
    final query = filterStatus != null ? '?status=$filterStatus' : '';
    final response = await http.get(Uri.parse('$baseUrl/appointments/doctor/$doctorId'));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => Appointment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load doctor appointments');
    }
  }



}
