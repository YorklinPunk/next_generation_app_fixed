import 'package:mongo_dart/mongo_dart.dart';

class ListProgrammingModel {
  final ObjectId? id;
  final DateTime fechaHoraPogramacion;
  final String nomUsuarioEdicion;

  ListProgrammingModel({
    required this.id,
    required this.fechaHoraPogramacion,
    required this.nomUsuarioEdicion,
  });

  factory ListProgrammingModel.fromMap(Map<String, dynamic> map) {
    return ListProgrammingModel(
      id: map['_id'] as ObjectId?,
      fechaHoraPogramacion: DateTime.parse(map['fechaHoraPogramacion'] as String),
      nomUsuarioEdicion: map['nomUsuarioEdicion'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {      
      if (id != null) '_id': id,
      'fechaHoraPogramacion': fechaHoraPogramacion.toIso8601String(),
      'nomUsuarioEdicion': nomUsuarioEdicion,
    };
  }
}
