import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/models/user_model.dart';
import 'package:next_generation_app_fixed/screens/principal_menu/weare_screen.dart';
import 'package:next_generation_app_fixed/screens/principal_menu/programming_screen.dart';


class PrincipalScreen extends StatelessWidget {
  final UserModel user;
  const PrincipalScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8e152),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome + Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bienvenido, \n${user.name}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/avatar.png"), // Usa tu imagen real
                    radius: 25,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Rooms horizontal scroll
              // const Text("Rooms", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 12),
              // SizedBox(
              //   height: 60,
              //   child: ListView(
              //     scrollDirection: Axis.horizontal,
              //     children: [
              //       _roomButton("Living Room", Icons.weekend),
              //       _roomButton("Bedroom", Icons.bed),
              //       _roomButton("Kitchen", Icons.kitchen),
              //       _roomButton("Bathroom", Icons.bathtub),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 20),

              // Smart systems
              const Text("Menú Principal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _smartCard(
                      context,
                      title: "Somos Next Generation",
                      subtitle: "Conócenos",
                      color: const Color(0xFFEBD8FD),
                      icon: Icons.present_to_all,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WeAreScreen()),
                        );
                      },
                    ),
                    // _smartCard(
                    //   context,
                    //   title: "Servicios",
                    //   subtitle: "Conoce nuestras áreas servicios",
                    //   color: const Color(0xFFC9F0FF),
                    //   icon: Icons.church,
                    //   onTap: () {
                    //     Navigator.pushNamed(context, "/airConditioner");
                    //   },
                    // ),
                    _smartCard(
                      context,
                      title: "Programación",
                      subtitle: "Programación de servicios semanales",
                      color: const Color(0xFFFFF2C7),
                      icon: Icons.event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProgrammingScreen()),
                        );
                      },
                    ),
                    _smartCard(
                      context,
                      title: "Reporte",
                      subtitle: "Asistencia semanal de ministerios",
                      color: const Color(0xFFFFD3C3),
                      icon: Icons.bar_chart,
                      onTap: () {
                        Navigator.pushNamed(context, "/heatingSystem");
                      },
                    ),
                    _smartCard(
                      context,
                      title: "Fotos",
                      subtitle: "Galería de fotos",
                      color: const Color(0xFFC9F0FF),
                      icon: Icons.photo_camera,
                      onTap: () {
                        Navigator.pushNamed(context, "/heatingSystem");
                      },
                    ),
                    _smartCard(
                      context,
                      title: "Asistencia",
                      subtitle: "Asistencia de servidores",
                      color: const Color(0xFFEBD8FD),
                      icon: Icons.check_circle,
                      onTap: () {
                        Navigator.pushNamed(context, "/heatingSystem");
                      },
                    ),
                    _smartCard(
                      context,
                      title: "Asignación",
                      subtitle: "Asignación de tareas a servidores",
                      color: const Color(0xFFFFF2C7),
                      icon: Icons.assignment_ind,
                      onTap: () {
                        Navigator.pushNamed(context, "/heatingSystem");
                      },
                    ),
                    _smartCard(
                      context,
                      title: "Anuncios",
                      subtitle: "Anuncios semanales",
                      color: const Color(0xFFC9F0FF),
                      icon: Icons.campaign,
                      onTap: () {
                        Navigator.pushNamed(context, "/heatingSystem");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E2C),
        selectedItemColor: Color(0xFFff8e3a),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Reusable room icon
  static Widget _roomButton(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF1E1E2C),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Smart system card
  static Widget _smartCard(BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
            ),
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
