import 'package:mongo_dart/mongo_dart.dart';

class ReportModel {
  final ObjectId? id;
  final DateTime fecha;
  List<MinistryDetail> ministries;

  ReportModel({
    this.id,
    required this.fecha,
    required this.ministries,
  });
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['_id'],
      fecha: (map['fecha'] is DateTime 
            ? (map['fecha'] as DateTime).toLocal() 
            : DateTime.parse(map['fecha']).toLocal()),
      ministries: (map['ministries'] as List<dynamic>)
          .map((e) => MinistryDetail.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha,
      'ministries': ministries.map((e) => e.toMap()).toList(),
    };
  }
}

class MinistryDetail {
  final int codMinistry;
  final String nomMinistry;
  int cantidad;
  String nomUsuarioEdit;
  DateTime fechaHoraEdit;

  MinistryDetail({
    required this.codMinistry,
    required this.nomMinistry,
    required this.cantidad,
    required this.nomUsuarioEdit,
    required this.fechaHoraEdit,
  });

  factory MinistryDetail.fromMap(Map<String, dynamic> map) {
    return MinistryDetail(
      codMinistry: map['codMinistry'] ?? 0,
      nomMinistry: map['nomMinistry'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      nomUsuarioEdit: map['nomUsuarioEdit'] ?? '',
      fechaHoraEdit: (map['fechaHoraEdit'] is DateTime
            ? (map['fechaHoraEdit'] as DateTime).toLocal()
            : DateTime.parse(map['fechaHoraEdit']).toLocal()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codMinistry': codMinistry,
      'nomMinistry': nomMinistry,
      'cantidad': cantidad,
      'nomUsuarioEdit': nomUsuarioEdit,
      'fechaHoraEdit': fechaHoraEdit,
    };
  }
}