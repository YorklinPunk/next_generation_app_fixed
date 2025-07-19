import 'package:flutter/material.dart';

class WeAreScreen extends StatelessWidget {
  const WeAreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8e152),
      appBar: AppBar(
        title: const Text("Somos Next Generation", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFf8e152),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Next Generation",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Somos un grupo de jóvenes de la iglesia Agua Viva que acompaña a los adolescentes luego del mensaje. "
              "A través de juegos, dinámicas, música y diversión, buscamos crear un espacio seguro donde puedan "
              "conectar, crecer y disfrutar.\n\n¡Aquí la fe y la amistad se viven con alegría!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/group_photo.jpg', // Asegúrate de tener esta imagen en assets
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
