import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  final ObjectId? id;
  final String name;
  final String lastName;
  final String document;
  final String username;
  final DateTime birthday;
  final int ministry;
  final String password;
  final int role;
  final int state; // 1: activo, 0: inactivo
  final DateTime dateRegistration;
  final String urlUser;

  UserModel({
    this.id,
    required this.name,
    required this.lastName,
    required this.document,
    required this.username,
    required this.birthday,
    required this.ministry,
    required this.password,
    required this.role,
    required this.state, // 1: activo, 0: inactivo 
    required this.dateRegistration,
    required this.urlUser,
  });

  // 👉 Convertir modelo a mapa (para insertar en MongoDB)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'lastName': lastName,
      'document': document,
      'username': username,
      'birthday': birthday,
      'ministry': ministry,
      'password': password,
      'role': role,
      'state': state,
      'dateRegistration': dateRegistration,
      'urlUser': urlUser,
    };
  }

  // 👉 Convertir mapa de MongoDB a modelo (para leer)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'],
      name: map['name'],
      lastName: map['lastName'],
      document: map['document'],
      username: map['username'],
      birthday: map['birthday'] is DateTime
          ? map['birthday']
          : DateTime.parse(map['birthday'].toString()),
      ministry: map['ministry'],
      password: map['password'],
      role: map['role'],
      state: map['state'] ?? 1,
      dateRegistration: map['dateRegistration'] is DateTime
          ? map['dateRegistration']
          : DateTime.parse(map['dateRegistration'].toString()),
      urlUser: map['urlUser'] ?? '',
    );
  }
}
