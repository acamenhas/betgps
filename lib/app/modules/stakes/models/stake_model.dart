import 'package:betgps/app/shared/base_model.dart';

class StakeModel implements IBaseModel {
  String? id;
  String? name;

  StakeModel({this.id, this.name});

  static List<StakeModel> fromJsonList(List list) {
    if (list == null) return [];
    return list
        .map((item) => item.cast<String, dynamic>())
        .map<StakeModel>((item) => StakeModel.fromMap(item))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory StakeModel.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return StakeModel();
    }

    return StakeModel(id: map['id'] ?? "", name: map['name'] ?? "");
  }
}
