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
      response.content = response.isValid ? "El nombre de usuario ya existe." : "El nombre de usuario está disponible.";      
      return response;
    }
    catch (e){
      response.exceptions.add(OperationException('fetch_error', 'Error al verificar el nombre de usuario: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<String>> existeDocumento(String document) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: '',
    );

    try {      
      final user = await userCollection.findOne({'document': document});
      response.isValid = user != null;
      response.content = response.isValid ? "El DNI ya está registrado." : "El DNI está disponible.";
      return response;
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al verificar el DNI: $e'));
      return response;
    }
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
  }


  //CRU programming
  static Future<OperationResultGeneric<String>> insertProgramming(ProgrammingModel programming) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: '',
    );

    try {
      final result = await programmingCollection.insertOne(programming.toMap());
      response.isValid = result.isSuccess;
      response.content = result.isSuccess ? "Reporte insertado correctamente" : "No se registró el reporte";
      return response;
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al insertar programación: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<String>> updateProgramming(ProgrammingModel programming) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: '',
    );

    try {
      if (programming.id == null) {
        response.exceptions.add(OperationException('fetch_error', 'No se puede actualizar: id nulo'));
        return response;
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

      result.isValid = result.isSuccess;
      result.content = "Programación actualizada correctemente";

      return response;
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al actualizar programación: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<List<ListProgrammingModel>>> getAllProgrammings() async {
    var response = OperationResultGeneric<List<ListProgrammingModel>>(
      isValid: false,
      exceptions: [],
      content: [],
    );
    try{
      final result = await MongoDatabase.programmingCollection.find().toList();
      if(result.isEmpty) {
        response.content = [];
        return response;
      }

      response.content = result.map((e) => ListProgrammingModel.fromMap(e)).toList();      
      response.isValid = true;
      return response;
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al listar programación: $e'));
      return response;
    }
  }

  static Future<OperationResultGeneric<ProgrammingModel>> latestOfCurrentWeek() async {
    var response = OperationResultGeneric<ProgrammingModel>(
      isValid: false,
      exceptions: [],
      content: ProgrammingModel(
          id: null,
          nomUsuarioCreacion: '',
          fechaHoraCreacion: DateTime.now(),
          roles: [],
          fechaHoraPogramacion: DateTime.now(),
          fechaHoraEdicion: DateTime.now(),
          nomUsuarioEdicion: '',
        ),
    );

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
        response.content = ProgrammingModel.fromMap(result.first);
      }

      response.isValid = true;
      return response;
      
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al buscar programación de la semana actual: $e'));
      return  response;
    }
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
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final query = where
          .gte("fecha", startOfWeek)
          .lte("fecha", endOfWeek)
          .sortBy("fecha", descending: true)
          .limit(1);

      final result = await ReportCollection.find(query).toList();

      response.isValid = true;
      response.content = result.isNotEmpty ? ReportModel.fromMap(result.first) : null;
      return response;

    } catch (e) {
      response.exceptions.add(
        OperationException('fetch_error', 'Error al obtener el último reporte: $e'),
      );
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
