/// Model class representing router admin credentials
class Credential {
  /// Router admin username
  final String username;

  /// Router admin password
  final String password;

  /// Constructor with required parameters
  Credential({
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

  /// Create a copy with optional field updates
  Credential copyWith({
    String? username,
    String? password,
  }) {
    return Credential(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    // Mask password for security
    return 'Credential(username: $username, password: ****)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Credential &&
        other.username == username &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(username, password);
}

