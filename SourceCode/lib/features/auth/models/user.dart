/// Model User untuk autentikasi.
class User {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String? location;
  final int isActive;

  const User({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.location,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'password': password,
        'full_name': fullName,
        'location': location,
        'is_active': isActive,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int?,
        username: map['username'] as String,
        password: map['password'] as String,
        fullName: map['full_name'] as String,
        location: map['location'] as String?,
        isActive: map['is_active'] as int? ?? 1,
      );
}
