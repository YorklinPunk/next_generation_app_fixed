// 
class MinistryModel {
  final int codMinistry;
  final String nomMinistry;

  MinistryModel({
    required this.codMinistry,
    required this.nomMinistry,
  });

  Map<String, dynamic> toMap() {
    return {
      'codMinistry': codMinistry,
      'nomMinistry': nomMinistry,
    };
  }

  factory MinistryModel.fromMap(Map<String, dynamic> map) {
    return MinistryModel(
      codMinistry: map['codMinistry'] ?? 0,
      nomMinistry: map['nomMinistry'] ?? '',
    );
  }
}