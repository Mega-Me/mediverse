import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediverse/models/appointment.dart';
import 'package:mediverse/services/api_service.dart';
import 'package:mediverse/doctor_session.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});
  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _getPastAppointments();
  }

  Future<List<Appointment>> _getPastAppointments() async {
    final all = await ApiService.fetchAppointmentsForDoctor(DoctorSession.doctorId!);
    final now = DateTime.now();

    return all
        .where((appt) => appt.date.isBefore(now))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${DoctorSession.fullName ?? ''} Profile'),
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
              return const Center(child: Text('No past sessions'));
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
