class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final List<String>? preferredLanguage;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.preferredLanguage,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      preferredLanguage: json['preferredLanguage'] != null
          ? List<String>.from(json['preferredLanguage'])
          : null,
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
