class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final DateTime date;
  final Duration duration;
  final String status;
  final String payment;
  final String roomId; // Add this field

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.duration,
    required this.status,
    required this.payment,
    required this.roomId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Handle patient data from either 'patient' or 'userId'
    dynamic patientData = json['patient'] ?? json['userId'];

    // Handle doctor data
    dynamic doctorData = json['doctor'];

    return Appointment(
      id: json['_id'] ?? '',
      doctorId: doctorData is Map && doctorData['_id'] != null
          ? doctorData['_id']
          : (doctorData is String ? doctorData : ''),
      doctorName: doctorData is Map && doctorData['fullName'] != null
          ? doctorData['fullName']
          : 'Unknown Doctor',
      patientId: patientData is Map && patientData['_id'] != null
          ? patientData['_id']
          : (patientData is String ? patientData : ''),
      patientName: patientData is Map && patientData['fullName'] != null
          ? patientData['fullName']
          : 'Unknown Patient',
      date: DateTime.parse(json['date']),
      duration: Duration(minutes: json['duration'] ?? 0),
      status: json['status'] ?? 'Pending',
      payment: json['payment'] ?? 'Pending',
      roomId: json['roomId'] ?? 'default_room_${json['_id']}',
    );
  }
}
