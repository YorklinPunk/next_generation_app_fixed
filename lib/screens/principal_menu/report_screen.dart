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
  ReportModel _latestReport = ReportModel(
    fecha: DateTime.now(),
    ministries: [],
  );
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, bool> _isEditing = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _cargarMinistries();
    await _getLatestReport();
  }

  Future<void> _cargarMinistries() async {
    final data = await MongoDatabase.getMinistries();
    setState(() {
      _ministries = data.content;
    });
  }

  Future<void> _getLatestReport() async {
    final reportResult = await MongoDatabase.getLatestReport();
    ReportModel? latestReport = reportResult.content;

    if (latestReport != null && latestReport.ministries.isNotEmpty) {
      setState(() {
        _latestReport = latestReport;
      });
      print("último reporte encontrado: ${latestReport.fecha}");
    } else {
      // Crear uno vacío basado en _ministries ya cargado
      List<MinistryDetail> ministryDetails = _ministries.map((ministry) {
        return MinistryDetail(
          codMinistry: ministry.codMinistry,
          nomMinistry: ministry.nomMinistry,
          cantidad: 0,
          nomUsuarioEdit: widget.user.ministry == ministry.codMinistry ? widget.user.username : "",
          fechaHoraEdit: DateTime.now(),
        );
      }).toList();

      setState(() {
        _latestReport = ReportModel(
          fecha: DateTime.now(),
          ministries: ministryDetails,
        );
      });

      print("No se encontró ningún reporte. Se generó uno nuevo.");
    }
  }


  void _startEditing(int index) {
    setState(() {
      _isEditing[index] = true;
      _controllers[index] = TextEditingController(text: "0");
    });
  }

  void _stopEditing(int index) async {
    print("Guardando cambios para el ministerio en el índice $index");
    final controller = _controllers[index];
    final newCantidad = int.tryParse(controller?.text ?? "");
    
    final i = _latestReport.ministries.indexWhere(
      (m) => m.codMinistry == _ministries[index].codMinistry,
    );

    if (i == -1) return;

    final currentMinistry = _latestReport.ministries[i];

    // Si no hay cambios en la cantidad, salir sin guardar
    if (newCantidad == currentMinistry.cantidad) {
      setState(() {
        _isEditing[index] = false;
        _controllers[index]?.dispose();
        _controllers.remove(index);
      });
      return;
    }

    currentMinistry.cantidad = newCantidad ?? 0;
    currentMinistry.nomUsuarioEdit = widget.user.username;
    currentMinistry.fechaHoraEdit = DateTime.now();
     try {
      if (_latestReport.id != null) {
        print("Editando reporte existente");
        await MongoDatabase.editReport(_latestReport);
      } else {
        print("Insertando nuevo reporte");
        await MongoDatabase.insertReport(_latestReport);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte guardado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el reporte')),
      );
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
      body: _latestReport.ministries.isEmpty
          ? const Center(child: Text("No hay ministerios disponibles"))
          : ListView.builder(
              itemCount: _latestReport.ministries.length,
              itemBuilder: (context, index) {
                final ministry = _latestReport.ministries[index];
                final isEditing = _isEditing[index] ?? false;

                
                return GestureDetector(
                  onDoubleTap: () => {
                    if( widget.user.ministry == ministry.codMinistry || widget.user.role == 1 ){
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
                      // leading: CircleAvatar(child: Text("${index + 1}")),
                      title: Text(ministry.nomMinistry),
                      trailing: SizedBox(
                        width: 25,
                        child: isEditing ?
                        Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus) {
                              print("Se perdió el foco");
                              _stopEditing(index);
                            }
                          },
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            autofocus: true,
                          ),
                        )
                        :Text(ministry.cantidad.toString(), // Aquí puedes mostrar la cantidad actual si la tienes
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,),
                        ),
                      ),
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
