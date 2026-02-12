import 'package:equatable/equatable.dart';

/// User model from uSafe ID
class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    this.emailVerified = false,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Create from JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['sub'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['picture'] as String? ?? json['avatar'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': avatar,
      'email_verified': emailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    avatar,
    emailVerified,
    createdAt,
    updatedAt,
  ];
}
