class MusyrifModel {
  final String id;
  final String name;
  final String email;
  final String password;

  MusyrifModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  factory MusyrifModel.fromJson(Map<String, dynamic> json) {
    return MusyrifModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}
