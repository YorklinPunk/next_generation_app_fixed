import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart';
import 'package:next_generation_app_fixed/models/ministry_model.dart';
import 'package:next_generation_app_fixed/models/user_model.dart';
import 'package:next_generation_app_fixed/utils/dialog_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _documentController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _verPassword = false;
  List<MinistryModel> _ministries = [];
  MinistryModel? _selectedMinistry = MinistryModel(
    codMinistry: 0,
    nomMinistry: "-- Seleccione un ministerio --"
  );

  @override
  void initState() {
    super.initState();

    // Generar sugerencia automática de usuario
    _lastNameController.addListener(_sugerirUsername);
    _cargarMinistries();
  }

  void _cargarMinistries() async {
    final data = await MongoDatabase.getMinistries();
    data.insert(0, MinistryModel(
      codMinistry: 0,
      nomMinistry: "-- Seleccione un ministerio --"
    ));

    setState(() {
      _ministries = data;
    });
    
    setState(() {
      _selectedMinistry = _ministries.firstWhere((m) => m.codMinistry == 0);
    });
  }

  void _sugerirUsername() {
    final nombre = _nameController.text.trim();
    final apellidos = _lastNameController.text.trim().split(' ');

    if (nombre.isNotEmpty && apellidos.isNotEmpty) {
      final primeraLetraNombre = nombre[0].toLowerCase();
      final apellidoPaterno = apellidos[0].toLowerCase();
      final sugerido = '$primeraLetraNombre$apellidoPaterno';

      setState(() {
        _usernameController.text = sugerido;
      });
    }
  }

  void _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final document = _documentController.text.trim();
      final password = _passwordController.text.trim();

      // Validaciones específicas
      if (await MongoDatabase.existeUsername(username)) {
        showCustomDialog(context, "El nombre de usuario ya está registrado", 2);
        return;
      }

      if (await MongoDatabase.existeDocumento(document)) {
        showCustomDialog(context, "El DNI ya está registrado", 2);
        return;
      }

      if (password.length <= 5 || password.contains(' ')) {
        showCustomDialog(context, "La contraseña debe tener más de 5 caracteres y sin espacios", 2);
        return;
      }

      final user = UserModel(
        name: _nameController.text,
        lastName: _lastNameController.text,
        document: document,
        ministry: _selectedMinistry!.codMinistry,
        username: username,
        password: MongoDatabase.encriptarPassword(password),
        role: 3,
        state: 1,
        dateRegistration: DateTime.now(),
      );

      await MongoDatabase.userCollection.insertOne(user.toMap());
      showCustomDialog(context, "Usuario registrado correctamente", 1,
        onClose: () {
          Navigator.pop(context); // cerrar pantalla de registro después del diálogo
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E2C),
        elevation: 0,
        title: Text("Registro", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _campo("Nombres", _nameController),
              _campo("Apellidos", _lastNameController),
              _campo("DNI", _documentController, isNumeric: true),
              DropdownButtonFormField2<MinistryModel>(
                isExpanded: true,
                value: _selectedMinistry,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Ministerio",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFff8e3a)),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _ministries.map((min) {
                  return DropdownMenuItem<MinistryModel>(
                    value: min,
                    child: Text(min.nomMinistry),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMinistry = val;
                  });
                },
                validator: (val) {
                  if (val == null || val.codMinistry == 0) {
                    return "Seleccione un ministerio";
                  }
                  return null;
                },
              ),
              _campo("Usuario", _usernameController, enabled: false),
              _campo("Contraseña", _passwordController, isPassword: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFff8e3a),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    Text("Crear cuenta", style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isNumeric = false,
    bool enabled = true,
  }) {
   return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword ? !_verPassword : false,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _verPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _verPassword = !_verPassword;
                    });
                  },
                )
              : null,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFff8e3a))),
        ),
        validator: (value) =>
          value == null || value.isEmpty ? "Campo requerido" : null,
      ),
    );
  }
}
