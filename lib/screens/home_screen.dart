import 'package:flutter/material.dart';
import 'package:mediverse/models/appointment.dart';
import 'package:mediverse/screens/profile_screen.dart';
import 'package:mediverse/services/api_service.dart';
import 'package:mediverse/user_session.dart';
import 'package:mediverse/screens/add_appointment_screen.dart';
import 'package:mediverse/screens/video_call_screen.dart';
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
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _joinVideoCall(BuildContext context, Appointment appt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          roomId: appt.roomId,
          userId: 'patient_${UserSession.userId}',
          otherUserName: appt.doctorName,
          isCaller: false,
        ),
      ),
    );
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
                  builder: (_) => const ProfileScreen(),
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
                    'Appointments',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: appointments.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final appt = appointments[index];
                      final dateStr = DateFormat.yMMMd().format(appt.date);
                      final timeStr = DateFormat.jm().format(appt.date);
                      final isCallable = appt.status == 'approved';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt.doctorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 8),
                                  Text('$dateStr, $timeStr',
                                      style: const TextStyle(color: Colors.black87)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 8),
                                  Text('${appt.duration.inMinutes} minutes',
                                      style: const TextStyle(color: Colors.black87)),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Status indicator
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: appt.status == 'approved'
                                          ? Colors.green[50]
                                          : Colors.orange[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: appt.status == 'approved'
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                    child: Text(
                                      appt.status.toUpperCase(),
                                      style: TextStyle(
                                        color: appt.status == 'approved'
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Call and Rebook Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Join Call Button
                                  if (isCallable)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ElevatedButton.icon(
                                        onPressed: () => _joinVideoCall(context, appt),
                                        icon: const Icon(Icons.video_call, size: 22),
                                        label: const Text('Join Call',
                                            style: TextStyle(fontSize: 16)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Rebook Button
                                  ElevatedButton.icon(
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
                                    label: const Text('Rebook',
                                        style: TextStyle(fontSize: 16)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Debug info (optional)
                              // const SizedBox(height: 10),
                              // Text('Room ID: ${appt.roomId}',
                              //   style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
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