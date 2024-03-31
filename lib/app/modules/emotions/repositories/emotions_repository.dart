import 'package:betgps/app/modules/emotions/documents/emotions_document.dart';
import 'package:betgps/app/modules/emotions/models/emotion_model.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hasura_connect/hasura_connect.dart';

class EmotionsRepository extends Disposable {
  final HasuraConnect connect;

  EmotionsRepository(this.connect);

  Future<Snapshot<List<EmotionModel>>> getAll() async {
    var snapshot = await connect.subscription(emotionsAll);
    return snapshot.map((data) {
      if (data == null) {
        return [];
      }
      return EmotionModel.fromJsonList(data["data"]["betgps_emotion"]);
    });
  }

  @override
  void dispose() {}
}
