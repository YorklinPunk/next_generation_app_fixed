import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart';
import 'package:next_generation_app_fixed/models/all_report_model.dart';
import 'package:next_generation_app_fixed/models/user_model.dart';
import 'report_screen.dart';

class ReportListScreen extends StatefulWidget {
  final UserModel user;
  const ReportListScreen({super.key, required this.user});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<AllReportModel> _reports = [];
  bool _loading = true;
  
  get id => null;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final result = await MongoDatabase.getAllReports();
      setState(() {
        _reports = (result.content != null)
            ? result.content!.map<AllReportModel>((e) => e as AllReportModel).toList()
            : [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar reportes: $e")),
      );
    }
  }

  void _createNewReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(user: widget.user, lastReportid: id ?? null),
      ),
    );
    _loadReports(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD3C3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD3C3),
        elevation: 0,
        centerTitle: true, // 👈 Centra el título
        title: const Text(
          "Reportes",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text("No hay reportes"))
              : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final r = _reports[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Text("${index + 1}"),
                        title: Text(
                          "Fecha: ${r.fecha.toLocal().toString().split(" ")[0]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportScreen(user: widget.user, lastReportid: r.id),
                              ),
                            );
                          },
                          child: const Text("Ver"),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(          
        backgroundColor: const Color(0xFF1E1E2C),
        selectedItemColor: Color(0xFFff8e3a),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Estadísticas"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Asistencia"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendario"),
        ],
        onTap: (index) {
          // Aquí puedes manejar navegación
          switch (index) {
            case 0:
              // Navega a estadísticas
              break;
            case 1:
              // Navega a asistencia
              break;
            case 2:
              // Navega a calendario
              break;
          }
        },
      ),
      floatingActionButton: (widget.user.role == 1 || widget.user.role == 2)
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFff8e3a),
              onPressed: _createNewReport,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }
}
