class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String photoUrl;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photo_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'photo_url': photoUrl,
  };
}
