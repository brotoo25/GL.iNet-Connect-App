/// Model class representing router admin credentials
class Credential {
  /// Router admin username
  final String username;

  /// Router admin password
  final String password;

  /// Constructor with required parameters
  const Credential({
    required this.username,
    required this.password,
  });

  /// Factory constructor to parse credentials from JSON
  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() {
    // Mask password for security
    return 'Credential(username: $username, password: ****)';
  }
}
