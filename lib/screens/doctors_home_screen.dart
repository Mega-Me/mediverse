import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediverse/models/appointment.dart';
import 'package:mediverse/services/api_service.dart';
import 'package:mediverse/doctor_session.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    if (DoctorSession.doctorId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor ID not available')),
        );
      });
      return;
    }

    _appointmentsFuture = _getUpcomingAppointments();
  }

  Future<List<Appointment>> _getUpcomingAppointments() async {
    final id = DoctorSession.doctorId;
    if (id == null) throw Exception('Doctor ID is not set');

    final all = await ApiService.fetchAppointmentsForDoctor(id);
    final now = DateTime.now();

    return all.where((appt) => appt.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Dr. ${DoctorSession.fullName ?? ''}'),
        backgroundColor: const Color(0xFFF5F6FA),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: FutureBuilder<List<Appointment>>(
          future: _appointmentsFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No upcoming appointments'));
            }

            final appointments = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (_, idx) {
                final appt = appointments[idx];
                final dateStr = DateFormat.yMMMd().format(appt.date);
                final timeStr = DateFormat.jm().format(appt.date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient: ${appt.patientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text('$dateStr, $timeStr', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text('${appt.duration.inMinutes} minutes', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
