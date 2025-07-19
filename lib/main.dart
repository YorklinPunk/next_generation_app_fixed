import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart'; // Asegúrate de tener esta clase
import 'screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Conectar a MongoDB antes de lanzar la app
  await MongoDatabase.connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
