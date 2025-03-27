class GuruQuran {
  final String id;
  final String name;
  final String email;
  final String password;

  GuruQuran({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  factory GuruQuran.fromJson(Map<String, dynamic> json) {
    return GuruQuran(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
