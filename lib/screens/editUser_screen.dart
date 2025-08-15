import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/models/user_model.dart';

class EditUserScreen extends StatefulWidget {
  final UserModel user;
  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _imageController = TextEditingController(text: widget.user.urlUser ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Aquí llamarías a MongoDatabase.editUser(...)
    print("Nuevo nombre: ${_nameController.text}");
    print("Nuevo email: ${_usernameController.text}");
    print("Nueva URL imagen: ${_imageController.text}");

    Navigator.pop(context); // Vuelve a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: "URL de Imagen"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text("Guardar cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
