import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/screens/principal_screen.dart';
import 'package:next_generation_app_fixed/screens/register_screen.dart';
import 'package:next_generation_app_fixed/services/auth_service.dart';
import 'package:next_generation_app_fixed/utils/dialog_helper.dart';
import 'package:next_generation_app_fixed/screens/principal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8e152), // Fondo oscuro
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 130,
            ),
            Text(
              "Red García",
              style: TextStyle(
                color: Color.fromARGB(255, 14, 14, 14),
                fontSize: 18,
              ),
            ),

            SizedBox(height: 30),

            // LOGIN CARD
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF2B2B3C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bienvenido",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  // Email Field
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Usuario',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.account_box, color: Colors.grey[400]),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFf8e152)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFf8e152)),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("¿Olvidaste tu contraseña?",
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  SizedBox(height: 15),
                  

                  // LOGIN BUTTON
                  Center(
                    child: ElevatedButton(
                      onPressed: () async  {
                        //                       
                        final username = _usernameController.text.trim();
                        final password = _passwordController.text.trim();

                        if (username.isEmpty || password.isEmpty) {
                          showCustomDialog(context, "Todos los campos son obligatorios", 3);
                          return;
                        }

                        final user = await AuthService.login(username, password);

                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrincipalScreen(user: user),
                            ),
                          );
                        } else {
                          showCustomDialog(context, "Usuario y/o contraseña incorrecta", 3);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFff8e3a),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text("Iniciar sesión",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  
                  SizedBox(height: 15),

                  Center(
                    child: OutlinedButton(
                       onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 215, 160),
                        side: BorderSide(color: Color(0xFFff8e3a), width: 1),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Registrarse",
                        style: TextStyle(
                          color: Colors.black, // texto negro
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // OR divider
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: Divider(color: Color(0xFF2B2B3C))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR", style: TextStyle(color: Colors.white70)),
                ),
                Expanded(child: Divider(color: Color(0xFF2B2B3C))),
              ],
            ),

            SizedBox(height: 20),

            // Social buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialIcon(Icons.g_mobiledata, Colors.red),
                SizedBox(width: 20),
                _socialIcon(Icons.facebook, Colors.blue),
                SizedBox(width: 20),
                _socialIcon(Icons.alternate_email, Colors.lightBlue),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      radius: 24,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
