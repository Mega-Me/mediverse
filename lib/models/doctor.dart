class Doctor {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final List<String> specialization;
  final List<String> preferredLanguage;

  Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.specialization,
    required this.preferredLanguage,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      specialization: List<String>.from(json['specialization']),
      preferredLanguage: List<String>.from(json['preferredLanguage']),
    );
  }
}
