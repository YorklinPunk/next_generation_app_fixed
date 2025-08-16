import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageManagerScreen extends StatefulWidget {
  const ImageManagerScreen({super.key});
  @override
  State<ImageManagerScreen> createState() => _ImageManagerScreenState();
}

class _ImageManagerScreenState extends State<ImageManagerScreen> {
  final String imgbbApiKey = '88a83654cc050c57ebc10abc8628d69f';
  File? _imageFile;
  String? _uploadedUrl;
  String? _imageId;
  Map<String, dynamic>? _imageInfo;

  Future<void> _pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _imageFile = File(picked.path));

    final bytes = await _imageFile!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {
        'key': imgbbApiKey,
        'image': base64Image,
        'name': picked.name,
      },
    );

    if (response.statusCode == 200) {
      final data = (const JsonDecoder().convert(response.body) as Map)['data'];
      setState(() {
        _uploadedUrl = data['url'];
        _imageId = data['id'];
      });
    }
  }

  Future<void> _fetchImageDetails() async {
    if (_imageId == null) return;

    final response = await http.get(
      Uri.parse('https://api.imgbb.com/1/image/$_imageId?key=$imgbbApiKey'),
    );

    if (response.statusCode == 200) {
      final data = (const JsonDecoder().convert(response.body) as Map)['data'];
      setState(() => _imageInfo = data as Map<String, dynamic>);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imagenes ImgBB')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickAndUploadImage, child: const Text("Subir Imagen")),
            if (_uploadedUrl != null) ...[
              const SizedBox(height: 16),
              Text("Imagen subida:", style: TextStyle(fontWeight: FontWeight.bold)),
              Image.network(_uploadedUrl!),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _fetchImageDetails, child: const Text("Obtener detalles")),
            ],
            if (_imageInfo != null) ...[
              const SizedBox(height: 16),
              Text("Detalles de la imagen:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(jsonEncode(_imageInfo)),
            ]
          ],
        ),
      ),
    );
  }
}
