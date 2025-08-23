import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/generic_model/operation_result_model.dart';

class ImageManagerApi {
  static var imgbbApiKey = 'gEBXYibvtsevfHAQ6GvZd0eer3OZgjDC';
  static var _uploadedUrl;
  static var _imageId;
  // static Map<String, dynamic>? _imageInfo;

  static Future<OperationResultGeneric<String>> pickAndUploadImage(
    String nombre,
    File imageFile
  ) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: "",
    );

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://upload-sa-sao.gofile.io/uploadFile"),
      );

      // Header con token
      request.headers['Authorization'] = 'Bearer gEBXYibvtsevfHAQ6GvZd0eer3OZgjDC';

      // Adjuntar archivo
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Enviar petición
      var streamedResponse = await request.send();
      var result = await http.Response.fromStream(streamedResponse);

      print("📡 Status: ${result.statusCode}");
      print("📡 Body: ${result.body}");

      if (result.statusCode == 200) {
        final responseData = const JsonDecoder().convert(result.body) as Map<String, dynamic>;

        if (responseData['status'] == 'ok') {
          final directLink = responseData['data']['directLink'] as String;
          response.content = directLink;
          response.isValid = true;
        } else {
          response.exceptions.add(
            OperationException('upload_error', 'Respuesta con error: ${result.body}'),
          );
        }
      } else {
        response.exceptions.add(
          OperationException('${result.statusCode}', 'Error en servidor: ${result.body}'),
        );
      }
    } catch (e) {
      response.exceptions.add(
        OperationException('fetch_error', 'Error al subir la imagen: $e'),
      );
    }

    return response;
  }



}
