import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import '../user_session.dart';
import 'package:intl/intl.dart';

class AddAppointmentScreen extends StatefulWidget {
  final String? rebookedDoctorId;
  final String? rebookedDoctorName;
  final int? rebookedDuration;

  const AddAppointmentScreen({
    super.key,
    this.rebookedDoctorId,
    this.rebookedDoctorName,
    this.rebookedDuration,
  });

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  Doctor? _selectedDoctor;
  List<Doctor> _doctors = [];

  static const genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();

    // Pre-fill duration if rebooked
    if (widget.rebookedDuration != null) {
      _durationController.text = widget.rebookedDuration.toString();
    }

    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    if (UserSession.preferredLanguage == null) return;

    try {
      final doctors = await ApiService.fetchDoctorsByLanguages(
        languages: UserSession.preferredLanguage!,
      );

      setState(() {
        _doctors = doctors;

        if (widget.rebookedDoctorId != null) {
          _selectedDoctor = _doctors.firstWhere(
                (doc) => doc.id == widget.rebookedDoctorId,
            orElse: () => _doctors.first,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load doctors')),
      );
    }
  }

  Future<void> _fetchDoctorsByGender() async {
    if (_selectedGender == null || UserSession.preferredLanguage == null) return;

    try {
      final doctors = await ApiService.fetchDoctorsByGenderAndLanguages(
        gender: _selectedGender!,
        languages: UserSession.preferredLanguage!,
      );

      setState(() {
        _doctors = doctors;
        _selectedDoctor = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to filter doctors')),
      );
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Appointment Request'),
        backgroundColor: const Color(0xFFF5F6FA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Select Doctor Gender'),
              Row(
                children: genderOptions.map((gender) {
                  return Row(
                    children: [
                      Radio<String>(
                        value: gender,
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() => _selectedGender = value);
                          _fetchDoctorsByGender();
                        },
                      ),
                      Text(gender),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Doctor>(
                value: _selectedDoctor,
                items: _doctors
                    .map(
                      (doc) => DropdownMenuItem(
                    value: doc,
                    child: Text(doc.fullName),
                  ),
                )
                    .toList(),
                onChanged: (value) => setState(() => _selectedDoctor = value),
                decoration: const InputDecoration(
                  labelText: 'Select Doctor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null ? 'Please select a doctor' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (min)'),
                validator: (value) =>
                value!.isEmpty ? 'Duration required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Appointment Date',
                  border: OutlineInputBorder(),
                ),
                onTap: _pickDate,
                validator: (_) =>
                _selectedDate == null ? 'Please select a date' : null,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedDoctor != null &&
                      _selectedDate != null) {
                    final success = await ApiService.createAppointment(
                      userId: UserSession.userId!,
                      doctorId: _selectedDoctor!.id,
                      date: _selectedDate!,
                      duration: int.parse(_durationController.text),
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Appointment successfully created'),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to create appointment'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
