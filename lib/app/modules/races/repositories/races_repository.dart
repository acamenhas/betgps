import 'package:betgps/app/modules/races/documents/races_document.dart';
import 'package:betgps/app/modules/races/models/race_model.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hasura_connect/hasura_connect.dart';

class RacesRepository extends Disposable {
  final HasuraConnect connect;

  RacesRepository(this.connect);

  Future<Snapshot<List<RaceModel>>> getAllByDay(String date) async {
    var snapshot = await connect.subscription(racesByDay,
        variables: {'di': '${date}T00:00:00', 'df': '${date}T23:59:59'});
    return snapshot.map((data) {
      if (data == null) {
        return [];
      }
      return RaceModel.fromJsonList(data["data"]["betgps_race"]);
    });
  }

  Future<dynamic> reject(String raceId) async {
    return await connect.mutation(rejectRace, variables: {
      'id': raceId,
      'raceStatusId': '64f5faee-b813-4bdc-8721-a8474d71c35d',
      'updateDate': DateTime.now().toIso8601String()
    });
  }

  Future<dynamic> abandon(String raceId) async {
    return await connect.mutation(rejectRace, variables: {
      'id': raceId,
      'raceStatusId': '4cd545d0-52e8-4723-bf0b-53649a9eadf2',
      'updateDate': DateTime.now().toIso8601String()
    });
  }

  Future<double> getLastBalanceOfDay(String date) async {
    var result = await connect.query(lastBalanceOfDay,
        variables: {'di': '${date}T00:00:00', 'df': '${date}T23:59:59'});

    if ((result["data"]["betgps_race"] as List).isNotEmpty) {
      return (result["data"]["betgps_race"] as List).first['balance'];
    } else {
      return 0.0;
    }
  }

  Future<double> getDaillyBalance(String date) async {
    var result = await connect.query(daillyBalance, variables: {'date': date});

    if ((result["data"]["betgps_dailly"] as List).isNotEmpty) {
      return (result["data"]["betgps_dailly"] as List).first['balance'];
    } else {
      return 0.0;
    }
  }

  Future<dynamic> finish(
      String raceId,
      double pl,
      double pl_percent,
      double balance,
      double operationalRating,
      String obs,
      String emotionId) async {
    return await connect.mutation(finishRace, variables: {
      'id': raceId,
      'pl': pl,
      'pl_percent': pl_percent,
      'balance': balance,
      'operationalRating': operationalRating,
      'obs': obs,
      'emotionId': emotionId,
      'raceStatusId': '146e9766-dfb7-4bd1-b78a-d64bcd597212',
      'updateDate': DateTime.now().toIso8601String()
    });
  }

  Future<dynamic> finishDay(String date, double balance) async {
    return await connect.mutation(insertDay, variables: {
      'date': date,
      'balance': balance,
    });
  }

  @override
  void dispose() {}
}
