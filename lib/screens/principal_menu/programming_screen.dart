import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart'; // Asegúrate de tener esta clase
import 'package:next_generation_app_fixed/models/programming_model.dart';
import 'package:next_generation_app_fixed/utils/dialog_helper.dart'; // tu función de dialog

class ProgrammingScreen extends StatefulWidget {
  const ProgrammingScreen({super.key});

  @override
  State<ProgrammingScreen> createState() => _ProgrammingScreenState();
}

class _ProgrammingScreenState extends State<ProgrammingScreen> {
  List<ProgrammingModel> _allProgrammings = [];
  ProgrammingModel? _thisWeekProgramming;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProgrammingData();
  }

  Future<void> fetchProgrammingData() async {
    try {
      final data = await MongoDatabase.getAllProgrammings();
      final latest = await MongoDatabase.latestOfCurrentWeek();

      setState(() {
        _allProgrammings = data;
        _thisWeekProgramming = latest;
        loading = false;
      });

      if (latest.id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Programación de esta semana"),
              content: Text(
                latest.roles.map((r) => "${r.nombreRol}: ${r.nombresAsignados.join(", ")}").join("\n"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                )
              ],
            ),
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCustomDialog(context, "Aún no hay programación para esta semana.", 3);
          // showDialog(
          //   context: context,
          //   builder: (context) => AlertDialog(
          //     title: const Text("Sin programación"),
          //     content: const Text("Aún no hay programación para esta semana."),
          //     actions: [
          //       TextButton(
          //         onPressed: () => Navigator.pop(context),
          //         child: const Text("Cerrar"),
          //       )
          //     ],
          //   ),
          // );
        });
      }
    } catch (e) {
      debugPrint("Error al cargar programación: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Programaciones")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allProgrammings.length,
              itemBuilder: (context, index) {
                final p = _allProgrammings[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      "Semana de: ${p.fechaHoraPogramacion.toLocal().toString().split(" ")[0]}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: p.roles
                          .map((r) => Text("${r.nombreRol}: ${r.nombresAsignados.join(", ")}"))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
