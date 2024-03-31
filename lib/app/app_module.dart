import 'package:betgps/app/modules/dashboard/dashboard_page.dart';
import 'package:betgps/app/modules/emotions/emotions_controller.dart';
import 'package:betgps/app/modules/emotions/repositories/emotions_repository.dart';
import 'package:betgps/app/modules/races/races_controller.dart';
import 'package:betgps/app/modules/races/repositories/races_repository.dart';
import 'package:betgps/app/shared/custom_hasura_connect.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_triple_bind/modular_triple_bind.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.factory((i) => CustomHasuraConnect.getConnect()),
        Bind.factory((i) => RacesRepository(i.get())),
        TripleBind.factory((i) => RacesController(i.get())),
        Bind.factory((i) => EmotionsRepository(i.get())),
        TripleBind.factory((i) => EmotionsController(i.get())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            transition: TransitionType.noTransition,
            child: (context, args) => const DashboardPage()),
      ];
}
