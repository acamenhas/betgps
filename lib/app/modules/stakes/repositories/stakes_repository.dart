import 'package:betgps/app/modules/stakes/documents/stakes_document.dart';
import 'package:betgps/app/modules/stakes/models/stake_model.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hasura_connect/hasura_connect.dart';

class StakesRepository extends Disposable {
  final HasuraConnect connect;

  StakesRepository(this.connect);

  Future<Snapshot<List<StakeModel>>> getAll() async {
    var snapshot = await connect.subscription(stakesAll);
    return snapshot.map((data) {
      if (data == null) {
        return [];
      }
      return StakeModel.fromJsonList(data["data"]["betgps_stake"]);
    });
  }

  @override
  void dispose() {}
}
