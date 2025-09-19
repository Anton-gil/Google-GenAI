// lib/models/user.dart
enum UserRole { buyer, seller, both }

enum VerificationStatus { pending, verified, rejected }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final UserRole role;
  final VerificationStatus verificationStatus;
  final String? aadhaarNumber;
  final String? address;
  final String? bio;
  final DateTime createdAt;
  final bool isVerifiedArtisan;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.role,
    required this.verificationStatus,
    this.aadhaarNumber,
    this.address,
    this.bio,
    required this.createdAt,
    this.isVerifiedArtisan = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    UserRole? role,
    VerificationStatus? verificationStatus,
    String? aadhaarNumber,
    String? address,
    String? bio,
    DateTime? createdAt,
    bool? isVerifiedArtisan,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      isVerifiedArtisan: isVerifiedArtisan ?? this.isVerifiedArtisan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role.toString(),
      'verificationStatus': verificationStatus.toString(),
      'aadhaarNumber': aadhaarNumber,
      'address': address,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'isVerifiedArtisan': isVerifiedArtisan,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.buyer,
      ),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.toString() == json['verificationStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      aadhaarNumber: json['aadhaarNumber'],
      address: json['address'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['createdAt']),
      isVerifiedArtisan: json['isVerifiedArtisan'] ?? false,
    );
  }
}