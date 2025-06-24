import 'package:flutter/material.dart';
import 'package:mediverse/models/appointment.dart';
import 'package:mediverse/screens/profile_screen.dart';
import 'package:mediverse/services/api_service.dart';
import 'package:mediverse/user_session.dart';
import 'package:mediverse/screens/add_appointment_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _getUpcomingAppointments();
  }

  Future<List<Appointment>> _getUpcomingAppointments() async {
    final allAppointments = await ApiService.fetchAppointments(UserSession.userId!);
    final now = DateTime.now();

    return allAppointments
        .where((appt) => appt.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // optional: sort by date
  }

  @override
  Widget build(BuildContext context) {
    final userId = UserSession.userId;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${UserSession.fullName ?? 'User'}'),
        backgroundColor: const Color(0xFFF5F6FA),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: FutureBuilder<List<Appointment>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No appointments found'));
            }
            final appointments = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Appointment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: appointments.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final appt = appointments[index];
                      final dateStr = DateFormat.yMMMd().format(appt.date);
                      final timeStr = DateFormat.jm().format(appt.date);

                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appt.doctorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddAppointmentScreen(
                                        rebookedDoctorId: appt.doctorId,
                                        rebookedDoctorName: appt.doctorName,
                                        rebookedDuration: appt.duration.inMinutes,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Rebook'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),

                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Request Appointment',
      ),
    );
  }
}
