import 'package:betgps/app/shared/base_model.dart';

class EmotionModel implements IBaseModel {
  String? id;
  String? name;

  EmotionModel({this.id, this.name});

  static List<EmotionModel> fromJsonList(List list) {
    if (list == null) return [];
    return list
        .map((item) => item.cast<String, dynamic>())
        .map<EmotionModel>((item) => EmotionModel.fromMap(item))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory EmotionModel.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return EmotionModel();
    }

    return EmotionModel(id: map['id'] ?? "", name: map['name'] ?? "");
  }
}
