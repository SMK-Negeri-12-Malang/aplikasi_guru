class GuruModel {
  final String id;
  final String name;
  final String email;
  final String password;

  GuruModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  factory GuruModel.fromJson(Map<String, dynamic> json) {
    return GuruModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}
