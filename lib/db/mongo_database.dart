import 'package:mongo_dart/mongo_dart.dart';
import 'package:next_generation_app_fixed/models/list_programming_model.dart';
import 'package:next_generation_app_fixed/models/report_model.dart';
import '../models/programming_model.dart';
import '../models/user_model.dart';
import '../models/ministry_model.dart';
import '../models/generic_model/operation_result_model.dart';

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
  static var ReportCollection;

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
    ReportCollection = db.collection("reports");
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

  static Future<OperationResultGeneric<List<UserModel>>> getUsers() async {
    var response = OperationResultGeneric<List<UserModel>>(
      isValid: false,
      exceptions: [],
      content: [],
    );
    try {
      final docs = await userCollection.find().toList();
      response.isValid = true; // Si llegamos aquí, la consulta fue exitosa
      response.content = docs.map((doc) => UserModel.fromMap(doc)).toList();
      return response;
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al obtener usuarios: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<String>> existeUsername(String username) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: '',
    );

    try {
      final user = await userCollection.findOne({'username': username});
      response.isValid = user != null; // Si el usuario existe, es válido
      if (response.isValid) {
        response.content = "El nombre de usuario ya existe.";
      } else {
        response.content = "El nombre de usuario está disponible.";
      }
    }
    catch (e){
      response.exceptions.add(OperationException('fetch_error', 'Error al verificar el nombre de usuario: $e'));
      return response;
    }
    return response; // Ensure a response is always returned
  }

  static Future<OperationResultGeneric<String>> existeDocumento(String document) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: '',
    );

    try {
      final user = await userCollection.findOne({'document': document});
      response.isValid = user != null; // Si el usuario existe, es válido
      if (response.isValid) {
        response.content = "El DNI ya está registrado.";
      } else {
        response.content = "El DNI está disponible.";
      }
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al verificar el DNI: $e'));
      return response;
    }
    return response; // Ensure a response is always returned
  }


  //LISTA DE MINISTERIOS
  static Future<OperationResultGeneric<List<MinistryModel>>> getMinistries() async {
    var response = OperationResultGeneric<List<MinistryModel>>(
      isValid: false,
      exceptions: [],
      content: [],
    );
    try {
      final results = await ministriesCollection.find().toList();
      if (results.isEmpty) {
        results.content = [];
      }
      response.isValid = true; 
      response.content = results.map((doc) {
                final map = Map<String, dynamic>.from(doc); // conversión explícita
                  if (map['status'] == 1 && map.containsKey('codMinistry')) {
                    return MinistryModel.fromMap(map);
                  }
                  // Validar que los campos existan
                  if (map.containsKey('codMinistry') && map.containsKey('nomMinistry')) {
                    return MinistryModel.fromMap(map);
                  } else {
                    return null;
                  }
                }).whereType<MinistryModel>().toList();
      return response; // Retorna la lista de ministerios
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al obtener ministerios: $e'));
      return response; // Retorna el error si ocurre una excepción
    }

      // final ministries = results.map((doc) {
      //   final map = Map<String, dynamic>.from(doc); // conversión explícita
      //   if (map['status'] == 1 && map.containsKey('codMinistry')) {
      //     return MinistryModel.fromMap(map);
      //   }
      //   // Validar que los campos existan
      //   if (map.containsKey('codMinistry') && map.containsKey('nomMinistry')) {
      //     return MinistryModel.fromMap(map);
      //   } else {
      //     print("❌ Registro inválido: $map");
      //     return null;
      //   }
      // }).whereType<MinistryModel>().toList();

      // return ministries;
    // } catch (e) {
    //   print("❌ Error al obtener ministerios: $e");
    //   return [];
    // }
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

  static Future<List<ListProgrammingModel>> getAllProgrammings() async {
    final result = await MongoDatabase.programmingCollection.find().toList();
    if(result.isEmpty) {
      print("No hay programaciones registradas.");
      return [];
    }
    return result.map((e) => ListProgrammingModel.fromMap(e)).toList();
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


  //CRU Report
  static Future<OperationResultGeneric<String>> insertReport(ReportModel report) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: '',
    );

    try {
      final result = await ReportCollection.insertOne(report.toMap());

      response.isValid = result.isSuccess; // asumiendo que result tiene isSuccess
      response.content = "Reporte insertado con éxito";
      return response;
    } catch (e) {
      response.exceptions.add(OperationException('insert_error', 'Error al insertar reporte: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<List<ReportModel>>> getAllReports() async {
    var response = OperationResultGeneric<List<ReportModel>>(
      isValid: false,
      exceptions: [],
      content: [],
    );

    try {
      final results = await ReportCollection.find().toList();
      response.isValid = true; // Si llegamos aquí, la consulta fue exitosa
      response.content = results.map((doc) => ReportModel.fromMap(doc)).toList();
      return response;
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al obtener reportes: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<ReportModel?>> getLatestReport() async {
    var response = OperationResultGeneric<ReportModel?>(
      isValid: false,
      exceptions: [],
      content: null,
    );

    try {
      final result = await ReportCollection.find().sort({'Fecha': -1}).limit(1).toList();
      response.isValid = true; // Si llegamos aquí, la consulta fue exitosa
      response.content = result.isNotEmpty ? ReportModel.fromMap(result.first) : null;
      return response;
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al obtener el último reporte: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<String>> editReport(ReportModel report) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: '',
    );
    try {
      if (report.id == null) {
        response.exceptions.add(OperationException('update_error', 'No se puede actualizar: id nulo'));
        return response;
      }

      final result = await ReportCollection.updateOne(
        where.id(report.id!),
        modify
          ..set('ministries', report.ministries.map((e) => e.toMap()).toList()),
      );
      response.isValid = result.isSuccess; // asumiendo que result tiene isSuccess
      response.content = "Reporte actualizado con éxito";      
      return response;

    } catch (e) {
      response.exceptions.add(OperationException('update_error', 'Error al actualizar reporte: $e'));
      return response;
    }
  }
}
