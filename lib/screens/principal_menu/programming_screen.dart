import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart'; // Asegúrate de tener esta clase
import 'package:next_generation_app_fixed/models/list_programming_model.dart';
import 'package:next_generation_app_fixed/models/programming_model.dart';
import 'package:next_generation_app_fixed/utils/dialog_helper.dart'; // tu función de dialog

class ProgrammingScreen extends StatefulWidget {
  const ProgrammingScreen({super.key});

  @override
  State<ProgrammingScreen> createState() => _ProgrammingScreenState();
}

class _ProgrammingScreenState extends State<ProgrammingScreen> {
  List<ListProgrammingModel> _allProgrammings = [];
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
        _allProgrammings = data.content; 
        _thisWeekProgramming = latest.content;
        loading = false;
      });

      if (latest.content.id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Programación de esta semana"),
              content: Text(
                latest.content.roles.map((r) => "${r.nombreRol}: ${r.nombresAsignados.join(", ")}").join("\n"),
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
          showCustomDialog(context, "Aún no hay programación para esta semana.", 4);
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
      appBar: AppBar(title: const Text("Programación Semanal")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _allProgrammings.isEmpty
              ? const Center(
                  child: Text(
                    "No hay programaciones",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _allProgrammings.length,
                  itemBuilder: (context, index) {
                    final p = _allProgrammings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          foregroundColor: Colors.white,
                        ),
                        title: Text(
                          "Fecha: ${p.fechaHoraPogramacion.toLocal().toString().split(" ")[0]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Editado por: ${p.nomUsuarioEdicion}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: "Ver programación",
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => ProgrammingDetailScreen(id: p.id!),
                            //   ),
                            // );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
