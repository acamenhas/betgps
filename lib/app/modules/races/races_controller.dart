import 'package:betgps/app/modules/races/models/race_model.dart';
import 'package:betgps/app/modules/races/repositories/races_repository.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:hasura_connect/hasura_connect.dart';

class RacesController extends StreamStore<Exception, List<RaceModel>>
    implements Disposable {
  final RacesRepository racesRepository;

  RacesController(this.racesRepository) : super([]);

  Snapshot<List<RaceModel>>? snapshot;

  Future getAllByDay(String date) async {
    snapshot = await racesRepository.getAllByDay(date);
    executeStream(snapshot!);
  }

  Future<bool> reject(String raceId) async {
    dynamic r = await racesRepository.reject(raceId);
    return true;
  }

  Future<bool> abandon(String raceId) async {
    dynamic r = await racesRepository.abandon(raceId);
    return true;
  }

  Future<double> getLastBalanceOfDay(String date) async {
    double balance = await racesRepository.getLastBalanceOfDay(date);
    return balance;
  }

  Future<double> getDaillyBalance(String date) async {
    double balance = await racesRepository.getDaillyBalance(date);
    return balance;
  }

  Future<bool> finish(
      String raceId,
      double pl,
      double pl_percent,
      double balance,
      double operationalRating,
      String obs,
      String emotionId,
      String stakeId) async {
    dynamic r = await racesRepository.finish(raceId, pl, pl_percent, balance,
        operationalRating, obs, emotionId, stakeId);
    return true;
  }

  Future<bool> finishDay(String date, double balance) async {
    dynamic r = await racesRepository.finishDay(date, balance);
    return true;
  }

  @override
  void dispose() {}
}
