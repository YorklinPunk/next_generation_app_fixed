import 'package:flutter/material.dart';
import 'package:next_generation_app_fixed/models/user_model.dart';
import 'package:next_generation_app_fixed/db/mongo_database.dart';
import 'package:next_generation_app_fixed/models/ministry_model.dart';
import 'package:next_generation_app_fixed/models/report_model.dart'; // Asegúrate de tener este archivo

class ReportScreen extends StatefulWidget {
  final UserModel user;
  const ReportScreen({super.key, required this.user});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<MinistryModel> _ministries = [];
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, bool> _isEditing = {};

  @override
  void initState() {
    super.initState();
    _cargarMinistries();    
  }

  Future<void> _cargarMinistries() async {
    final data = await MongoDatabase.getMinistries();
    setState(() {
      _ministries = data.content;
    });
  }

  void _startEditing(int index) {
    setState(() {
      _isEditing[index] = true;
      _controllers[index] = TextEditingController(text: "0");
    });
  }

  void _stopEditing(int index) {
    final controller = _controllers[index];
    final newCantidad = int.tryParse(controller?.text ?? "");

    if (newCantidad != null) {
      // Guardar los datos
      final detalle = MinistryDetail(
        codMinistry: _ministries[index].codMinistry,
        nomMinistry: _ministries[index].nomMinistry,
        cantidad: newCantidad,
        nomUsuarioEdit: widget.user.username, // <- cámbialo si es dinámico
        fechaHoraEdit: DateTime.now(),
      );

      final report = ReportModel(
        id: null, // MongoDB genera un ID automáticamente
        Fecha: DateTime.now(),
        ministries: [detalle],
      );

      //MongoDatabase.saveReport(report);
    }

    setState(() {
      _isEditing[index] = false;
      _controllers[index]?.dispose();
      _controllers.remove(index);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reporte de Ministerios")),
      body: _ministries.isEmpty
          ? const Center(child: Text("No hay ministerios disponibles"))
          : ListView.builder(
              itemCount: _ministries.length,
              itemBuilder: (context, index) {
                final ministry = _ministries[index];
                final isEditing = _isEditing[index] ?? false;

                
                return GestureDetector(
                  onDoubleTap: () => {
                    if( widget.user.ministry == ministry.codMinistry){
                      _startEditing(index)
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No tienes permiso para editar ${ministry.nomMinistry}")),
                      )
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(child: Text("${index + 1}")),
                      title: Text(ministry.nomMinistry),
                      trailing: isEditing
                          ? SizedBox(
                              width: 60,
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus) _stopEditing(index);
                                },
                                child: TextField(
                                  controller: _controllers[index],
                                  keyboardType: TextInputType.number,
                                  autofocus: true,
                                ),
                              ),
                            )
                          : const Icon(Icons.edit),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
