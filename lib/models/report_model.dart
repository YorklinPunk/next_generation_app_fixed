import 'package:mongo_dart/mongo_dart.dart';

class ReportModel {
  final ObjectId? id;
  final DateTime fecha;
  final List<MinistryDetail> ministries;

  ReportModel({
    this.id,
    required this.fecha,
    required this.ministries,
  });
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['_id'],
      fecha: DateTime.parse(map['fecha'] ?? DateTime.now().toIso8601String()),
      ministries: (map['ministries'] as List<dynamic>)
          .map((e) => MinistryDetail.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha.toIso8601String(),
      'ministries': ministries.map((e) => e.toMap()).toList(),
    };
  }
}

class MinistryDetail {
  final int codMinistry;
  final String nomMinistry;
  final int cantidad;
  final String nomUsuarioEdit;
  final DateTime fechaHoraEdit;

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
      fechaHoraEdit: DateTime.parse(map['fechaHoraEdit'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codMinistry': codMinistry,
      'nomMinistry': nomMinistry,
      'cantidad': cantidad,
      'nomUsuarioEdit': nomUsuarioEdit,
      'fechaHoraEdit': fechaHoraEdit.toIso8601String(),
    };
  }
}