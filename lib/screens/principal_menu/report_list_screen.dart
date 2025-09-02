import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart';
import 'package:next_generation_app_fixed/models/report_model.dart';
import 'package:next_generation_app_fixed/models/user_model.dart';
import 'report_screen.dart';

class ReportListScreen extends StatefulWidget {
  final UserModel user;
  const ReportListScreen({super.key, required this.user});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<ReportModel> _reports = [];
  bool _loading = true;

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
            ? result.content!.map<ReportModel>((e) => e as ReportModel).toList()
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
    // Crea un reporte vacío y abre ReportScreen
    final newReport = ReportModel(fecha: DateTime.now(), ministries: []);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(user: widget.user, initialReport: newReport),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportes de Ministerios")),
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
                                builder: (_) => ReportScreen(user: widget.user, initialReport: r),
                              ),
                            );
                          },
                          child: const Text("Ver"),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReport,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
