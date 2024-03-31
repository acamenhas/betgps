import 'package:betgps/app/modules/emotions/models/emotion_model.dart';
import 'package:betgps/app/modules/emotions/repositories/emotions_repository.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:hasura_connect/hasura_connect.dart';

class EmotionsController extends StreamStore<Exception, List<EmotionModel>>
    implements Disposable {
  final EmotionsRepository emotionsRepository;

  EmotionsController(this.emotionsRepository) : super([]);

  Snapshot<List<EmotionModel>>? snapshot;

  Future getAll() async {
    snapshot = await emotionsRepository.getAll();
    executeStream(snapshot!);
  }

  @override
  void dispose() {}
}
