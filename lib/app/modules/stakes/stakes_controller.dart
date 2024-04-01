import 'package:betgps/app/modules/stakes/models/stake_model.dart';
import 'package:betgps/app/modules/stakes/repositories/stakes_repository.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:hasura_connect/hasura_connect.dart';

class StakesController extends StreamStore<Exception, List<StakeModel>>
    implements Disposable {
  final StakesRepository stakesRepository;

  StakesController(this.stakesRepository) : super([]);

  Snapshot<List<StakeModel>>? snapshot;

  Future getAll() async {
    snapshot = await stakesRepository.getAll();
    executeStream(snapshot!);
  }

  @override
  void dispose() {}
}
