class UserModel {
  final String name;
  final String lastName;
  final String document;
  final String username;
  final int ministry;
  final String password;
  final int role;
  final int state; // 1: activo, 0: inactivo
  final DateTime dateRegistration;

  UserModel({
    required this.name,
    required this.lastName,
    required this.document,
    required this.username,
    required this.ministry,
    required this.password,
    required this.role,
    required this.state, // 1: activo, 0: inactivo 
    required this.dateRegistration,
  });

  // 👉 Convertir modelo a mapa (para insertar en MongoDB)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastName': lastName,
      'document': document,
      'username': username,
      'ministry': ministry,
      'password': password,
      'role': role,
      'state': state,
      'dateRegistration': dateRegistration.toIso8601String(),
    };
  }

  // 👉 Convertir mapa de MongoDB a modelo (para leer)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      lastName: map['lastName'],
      document: map['document'],
      username: map['username'],
      ministry: map['ministry'],
      password: map['password'],
      role: map['role'],
      state: map['state'] ?? 1, // Por defecto activo
      dateRegistration: DateTime.parse(map['dateRegistration']),
    );
  }
}
