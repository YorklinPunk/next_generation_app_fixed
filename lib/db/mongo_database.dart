import 'package:mongo_dart/mongo_dart.dart';
import '../models/programming_model.dart';
import '../models/user_model.dart';
import '../models/ministry_model.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

class MongoDatabase {
  static var db;
  static var userCollection;
  static var servicesCollection;
  static var rolesCollection;
  static var checkinsCollection;
  static var ministriesCollection;
  static var programmingCollection;

  static Future<void> connect() async {
    db = await Db.create(
      "mongodb://flutter_user:Flutter2024!@ac-8rk5moq-shard-00-00.np6zcyj.mongodb.net:27017,ac-8rk5moq-shard-00-01.np6zcyj.mongodb.net:27017,ac-8rk5moq-shard-00-02.np6zcyj.mongodb.net:27017/DBNextGeneration?ssl=true&replicaSet=atlas-8rk5moq-shard-0&authSource=admin&retryWrites=true&w=majority"
    );

    await db.open();
    print("✅ Conectado a MongoDB");

    userCollection = db.collection("users");
    servicesCollection = db.collection("services");
    rolesCollection = db.collection("roles");
    checkinsCollection = db.collection("checkins");
    ministriesCollection = db.collection("ministries");
    programmingCollection = db.collection("programming");
  }

  //Hash de contraseña
  // Utiliza SHA-256 para encriptar la contraseña
  static String encriptarPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<List<Map<String, dynamic>>> getUsuarios() async {
    return await userCollection.find().toList();
  }

  // Método para insertar un usuario con modelo
  // static Future<void> insertUser(UserModel user) async {
  //   try {
  //     await userCollection.insertOne(user.toMap());
  //     print("Usuario registrado con éxito ${user.username}");
  //   } catch (e) {
  //     print("Error al registrar: $e");
  //   }
  // }

  static Future<List<UserModel>> getUsers() async {
    final docs = await userCollection.find().toList();
    return docs.map((doc) => UserModel.fromMap(doc)).toList();
  }

  static Future<bool> existeUsername(String username) async {
    final user = await userCollection.findOne({'username': username});
    return user != null;
  }

  static Future<bool> existeDocumento(String document) async {
    final user = await userCollection.findOne({'document': document});
    return user != null;
  }


  //LISTA DE MINISTERIOS
  static Future<List<MinistryModel>> getMinistries() async {
    try {
      final results = await ministriesCollection.find().toList();

      final ministries = results.map((doc) {
        final map = Map<String, dynamic>.from(doc); // conversión explícita
        if (map['status'] == 1 && map.containsKey('codMinistry')) {
          return MinistryModel.fromMap(map);
        }
        // Validar que los campos existan
        if (map.containsKey('codMinistry') && map.containsKey('nomMinistry')) {
          return MinistryModel.fromMap(map);
        } else {
          print("❌ Registro inválido: $map");
          return null;
        }
      }).whereType<MinistryModel>().toList();

      return ministries;
    } catch (e) {
      print("❌ Error al obtener ministerios: $e");
      return [];
    }
  }


  //CRU programming
  static Future<bool> insertProgramming(ProgrammingModel programming) async {
    try {
      final result = await programmingCollection.insertOne(programming.toMap());
      return result.isSuccess;
    } catch (e) {
      print("Error al insertar programación: $e");
      return false;
    }
  }

  static Future<bool> updateProgramming(ProgrammingModel programming) async {
    try {
      if (programming.id == null) {
        print("No se puede actualizar: id nulo");
        return false;
      }

      final result = await programmingCollection.updateOne(
        where.id(programming.id!),
        modify.set('nomUsuarioCreacion', programming.nomUsuarioCreacion)
          ..set('fechaHoraCreacion', programming.fechaHoraCreacion.toIso8601String())
          ..set('roles', programming.roles.map((e) => e.toMap()).toList())
          ..set('fechaHoraPogramacion', programming.fechaHoraPogramacion.toIso8601String())
          ..set('fechaHoraEdicion', programming.fechaHoraEdicion.toIso8601String())
          ..set('nomUsuarioEdicion', programming.nomUsuarioEdicion),
      );

      return result.isSuccess;
    } catch (e) {
      print("Error al actualizar programación: $e");
      return false;
    }
  }

  static Future<List<ProgrammingModel>> getAllProgrammings() async {
    final result = await MongoDatabase.programmingCollection.find().toList();
    return result.map((e) => ProgrammingModel.fromMap(e)).toList();
  }

  static Future<ProgrammingModel> latestOfCurrentWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    try {
      final result = await programmingCollection.find({
        'fechaHoraPogramacion': {
          '\$gte': startOfWeek.toIso8601String(),
          '\$lte': endOfWeek.toIso8601String(),
        }
      }).sort({'fechaHoraPogramacion': -1}).toList();

      if (result.isNotEmpty) {
        return ProgrammingModel.fromMap(result.first);
      }
    } catch (e) {
      print("Error al buscar programación de la semana actual: $e");
    }

    // Retornar modelo vacío si no se encontró nada o hubo error
    return ProgrammingModel(
      id: null,
      nomUsuarioCreacion: '',
      fechaHoraCreacion: DateTime.now(),
      roles: [],
      fechaHoraPogramacion: DateTime.now(),
      fechaHoraEdicion: DateTime.now(),
      nomUsuarioEdicion: '',
    );
  }


}
