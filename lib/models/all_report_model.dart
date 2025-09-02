import 'package:mongo_dart/mongo_dart.dart';

class AllReportModel {
  final ObjectId id;
  final DateTime fecha;

  AllReportModel({
    required this.id,
    required this.fecha
  });
  factory AllReportModel.fromMap(Map<String, dynamic> map) {
    return AllReportModel(
      id: map['_id'] as ObjectId,
      fecha: (map['fecha'] as DateTime).toLocal(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'fecha': fecha
    };
  }
}