import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/generic_model/operation_result_model.dart';

class ImageManagerApi {
  static var imgbbApiKey = '88a83654cc050c57ebc10abc8628d69f';
  static var _uploadedUrl;
  static var _imageId;
  // static Map<String, dynamic>? _imageInfo;

  static Future<OperationResultGeneric<String>> pickAndUploadImage(String nombre, File _imageFile) async {
    var response = OperationResultGeneric<String>(
      isValid: false,
      exceptions: [],
      content: "",
    );

    try {
      final bytes = await _imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);    
      const String url = "https://api.imgbb.com/1/upload";

      final Map<String, String> body = {
        "key": imgbbApiKey,
        "image": base64Image,
        "name": nombre // nombre personalizado
      };

      // Petición POST
      final result = await http.post(Uri.parse(url), body: body);
      if (result.statusCode == 200) {
        final data = (const JsonDecoder().convert(result.body) as Map)['data'];
          _uploadedUrl = data as Map<String, dynamic>;
          response.content = _uploadedUrl['url'] as String;
          response.isValid = true;
          _imageId = data['id'];
      }else {
        print("❌ Error al subir imagen: ${result.statusCode}");
        print(result.body);
        response.exceptions.add(OperationException('${result.statusCode}', 'Error al subir imagen'));
      }
    } catch (e) {
      response.exceptions.add(OperationException('fetch_error', 'Error al subir la imagen: $e'));
    }
    return response;
  }

  // Future<void> _fetchImageDetails() async {
  //   if (_imageId == null) return;

  //   final response = await http.get(
  //     Uri.parse('https://api.imgbb.com/1/image/$_imageId?key=$imgbbApiKey'),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = (const JsonDecoder().convert(response.body) as Map)['data'];
  //     setState(() => _imageInfo = data as Map<String, dynamic>);
  //   }
  // }  
}
