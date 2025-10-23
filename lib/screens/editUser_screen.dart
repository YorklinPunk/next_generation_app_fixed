import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_generation_app_fixed/screens/login_screen.dart';
import '../providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:next_generation_app_fixed/db/image_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:next_generation_app_fixed/models/user_model.dart';
import 'package:next_generation_app_fixed/models/ministry_model.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditUserScreen({super.key, required this.user});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _documentController;
  late TextEditingController _passwordController;
  late TextEditingController _birthdayController;

  List<MinistryModel> _ministries = [];
  MinistryModel? _selectedMinistry;

  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _documentController = TextEditingController(text: widget.user.document);
    _passwordController = TextEditingController(text: "password");
    _birthdayController = TextEditingController(
      text: widget.user.birthday.toLocal().toString().split(" ")[0],
    );

    _loadMinistries();
  }

  Future<void> _loadMinistries() async {
    final result = await MongoDatabase.getMinistries();
    setState(() {
      _ministries = result.content;
      _selectedMinistry = _ministries.firstWhere(
        (m) => m.codMinistry == widget.user.ministry,
        orElse: () => _ministries.first,
      );
    });
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permiso de galería denegado")),
      );
    }
  }

  Future<void> _uploadImage(String dni) async {

    if (_selectedImage != null) {      
      if (_selectedImage!.lengthSync() > 5 * 1024 * 1024) { // 5 MB
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La imagen no puede superar los 5 MB")),
        );
        return;
      }
      
      final result = await ImageManagerApi.pickAndUploadImage(dni, _selectedImage!);
      
      if (!result.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.exceptions.first.description)),
        );
        return;
      }
      setState(() {
        _uploadedImageUrl = result.content;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto guardada correctamente")),
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se ha seleccionado ninguna imagen")),
      );
    }
  }

  Future<void> _saveChanges() async {
    final updatedUser = UserModel(
      id: widget.user.id,
      name: _nameController.text,
      lastName: _lastNameController.text,
      document: _documentController.text,
      username: widget.user.username,
      birthday: DateTime.parse(_birthdayController.text),
      ministry: _selectedMinistry!.codMinistry,
      password: _passwordController.text,
      role: widget.user.role,
      state: widget.user.state,
      dateRegistration: widget.user.dateRegistration,
      urlUser: _uploadedImageUrl ?? widget.user.urlUser,
    );

    //await MongoDatabase.editUser(updatedUser);
    Navigator.pop(context, updatedUser);
  }

  void _closeSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Seguro que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí, salir"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 🔹 Limpia usuario global
    ref.read(userProvider.notifier).state = null;

    // 🔹 Navega al login
    // 🔹 Redirige al login y elimina el historial de navegación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()), // <- aquí tu login real
      (route) => false, // elimina todas las rutas anteriores
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: ElevatedButton(
  //         onPressed: _closeSession,
  //         child: const Text("Cerrar Sesión"),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _documentController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Usuario")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (widget.user.urlUser.isNotEmpty
                          ? NetworkImage(widget.user.urlUser)
                          : const AssetImage("assets/images/avatar.png"))
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _uploadImage(widget.user.document),
            child: const Text("Guardar foto"),
          ),
          const SizedBox(height: 20),
          _inputField("Nombre", _nameController),
          _inputField("Apellido", _lastNameController),
          _inputField("DNI", _documentController, isNumeric: true),
          _dateField("F. Nacimiento", _birthdayController),
          DropdownButtonFormField<MinistryModel>(
            value: _selectedMinistry,
            items: _ministries.map((m) {
              return DropdownMenuItem(value: m, child: Text(m.nomMinistry));
            }).toList(),
            onChanged: (val) => setState(() => _selectedMinistry = val),
            decoration: const InputDecoration(labelText: "Ministerio"),
          ),
          _inputField("Contraseña", _passwordController, isPassword: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveChanges,
            child: const Text("Guardar cambios"),
          ),
          ElevatedButton(
            onPressed: _closeSession,
            child: const Text(
              "Cerrar Sesión",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 231, 68, 57), // color de fondo rojo para indicar cierre / alerta
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 5, // sombra para resaltar el botón
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {bool isPassword = false, bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: widget.user.birthday,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.text = picked.toIso8601String().split("T")[0];
          }
        },
      ),
    );
  }
}
