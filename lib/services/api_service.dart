import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
// import '../models/user_model.dart';
// import '../models/update_model.dart';
// import '../models/response_model.dart';

Dio createDio({required String baseUrl, bool ignoreBadCertificates = false}) {
  final dio = Dio()..options.baseUrl = baseUrl;

  if (ignoreBadCertificates) {
    // Configura el cliente HTTP para ignorar certificados inválidos
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  return dio;
}

class ApiService {
  final Dio dio;

  ApiService({required String baseUrl, bool ignoreBadCertificates = false})
      : dio = createDio(baseUrl: baseUrl, ignoreBadCertificates: ignoreBadCertificates);

  // Future<List<UserModel>> fetchUsers() async {
  //   const url = '/api/participants';

  //   try {
  //     final response = await dio.get(url);
  //     if (response.statusCode == 200) {
  //       final List<dynamic> usersJson = response.data['data'] ?? [];
  //       return usersJson.map((json) => UserModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Error al cargar los datos: ${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception('Error en la solicitud: $e');
  //   }
  // }
  // Future<List<UserModel>> fetchUsers() async {
  //   const url = 'AKfycbx1GecgRStxWzmHOnUY_z9KGuHuQPZPqbJQ8l7IMAqBT_IJg1KUrr73vsLHtdk22lWEcw/exec'; // Reemplaza con la URL de process.env.URL_APP_SCRIP

  //   try {
  //     print(dio.options.baseUrl);
  //     final response = await dio.get(url);
  //     if (response.statusCode == 200) {
  //       final List<dynamic> usersJson = response.data['data'] ?? [];
  //       return usersJson.map((json) => UserModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Error al cargar los datos: ${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception('Error en la solicitud: $e');
  //   }
  // }

  // Future<ResponseModel> fetchUser(UpdateModel data) async {
  //   const url = '/api/participants/update';
  //   try {

  //     final response = await dio.post(
  //       url,
  //       data: data.toJson(),
  //     );
  //     return ResponseModel.fromJson(response.data);

  //   } on DioException catch (e) {
  //     throw Exception('Error al cargar los datos: $e');
  //   }
  // }
}
