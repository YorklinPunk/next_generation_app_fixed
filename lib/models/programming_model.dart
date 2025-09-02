import 'package:mongo_dart/mongo_dart.dart';

class ProgrammingModel {
  final ObjectId? id;
  final String nomUsuarioCreacion;
  final DateTime fechaHoraCreacion;
  final List<RolAsignado> roles;
  final DateTime fechaHoraPogramacion;
  final DateTime fechaHoraEdicion;
  final String nomUsuarioEdicion;

  ProgrammingModel({
    required this.id,
    required this.nomUsuarioCreacion,
    required this.fechaHoraCreacion,
    required this.roles,
    required this.fechaHoraPogramacion,
    required this.fechaHoraEdicion,
    required this.nomUsuarioEdicion,
  });

  factory ProgrammingModel.fromMap(Map<String, dynamic> map) {
    return ProgrammingModel(
      id: map['_id'] as ObjectId?,
      nomUsuarioCreacion: map['nomUsuarioCreacion'] as String,
      fechaHoraCreacion: (map['fechaHoraCreacion'] is DateTime
          ? (map['fechaHoraCreacion'] as DateTime).toLocal()
          : DateTime.parse(map['fechaHoraCreacion']).toLocal()),
      roles: (map['roles'] as List<dynamic>)
          .map((e) => RolAsignado.fromMap(e as Map<String, dynamic>))
          .toList(),
      fechaHoraPogramacion:(map['fechaHoraPogramacion'] is DateTime
          ? (map['fechaHoraPogramacion'] as DateTime).toLocal()
          : DateTime.parse(map['fechaHoraPogramacion']).toLocal()),
      fechaHoraEdicion: (map['fechaHoraEdicion'] is DateTime
          ? (map['fechaHoraEdicion'] as DateTime).toLocal()
          : DateTime.parse(map['fechaHoraEdicion']).toLocal()),
      nomUsuarioEdicion: map['nomUsuarioEdicion'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'nomUsuarioCreacion': nomUsuarioCreacion,
      'fechaHoraCreacion': fechaHoraCreacion.toIso8601String(),
      'roles': roles.map((e) => e.toMap()).toList(),
      'fechaHoraPogramacion': fechaHoraPogramacion.toIso8601String(),
      'fechaHoraEdicion': fechaHoraEdicion.toIso8601String(),
      'nomUsuarioEdicion': nomUsuarioEdicion,
    };
  }
}

class RolAsignado {
  final String nombreRol;
  final List<String> nombresAsignados;

  RolAsignado({required this.nombreRol, required this.nombresAsignados});

  factory RolAsignado.fromMap(Map<String, dynamic> map) {
    return RolAsignado(
      nombreRol: map['nombreRol'] as String,
      nombresAsignados: List<String>.from(map['nombresAsignados'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreRol': nombreRol,
      'nombresAsignados': nombresAsignados,
    };
  }
}
