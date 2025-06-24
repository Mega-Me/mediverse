import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediverse/screens/profile_update_screen.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';
import '../user_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _getPastAppointments();
    print(UserSession.fullName);
  }

  Future<List<Appointment>> _getPastAppointments() async {
    final all = await ApiService.fetchAppointments(UserSession.userId!);
    final now = DateTime.now();

    return all.where((appt) => appt.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // most recent first
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        title: Text('${UserSession.fullName ?? ''} Profile'),
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 40,
                        /*backgroundImage: imgUrl != null
                            ? NetworkImage(imgUrl)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,*/
                      ),
                      const SizedBox(width: 16),

                      // Info Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(UserSession.fullName.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text('$UserSession.phoneNumber'),
                            const SizedBox(height: 2),
                            Text(UserSession.preferredLanguage?.join(', ') ?? ''),

                          ],
                        ),
                      ),

                      // Edit Profile Button
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit Profile',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileUpdateScreen(userId: UserSession.userId!),
                                ),
                              );

                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Appointment History',
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

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.teal),
                                const SizedBox(width: 6),
                                Text('Status: ${appt.status}', style: const TextStyle(color: Colors.black87)),
                              ],
                            ),

                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                                const SizedBox(width: 6),
                                Text('Payment: ${appt.payment}', style: const TextStyle(color: Colors.black87)),
                              ],
                            ),

                            if (appt.payment.toLowerCase() == 'pending')
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.payment),
                                  label: const Text('Pay Now'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Redirect to payment gateway')),
                                    );
                                    // TODO: Add your payment gateway or method
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade600,
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
    );
  }
}
