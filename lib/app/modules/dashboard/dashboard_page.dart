import 'package:betgps/app/app_constants.dart';
import 'package:betgps/app/modules/emotions/emotions_controller.dart';
import 'package:betgps/app/modules/emotions/models/emotion_model.dart';
import 'package:betgps/app/modules/races/models/race_model.dart';
import 'package:betgps/app/modules/races/races_controller.dart';
import 'package:betgps/app/modules/stakes/models/stake_model.dart';
import 'package:betgps/app/modules/stakes/stakes_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:group_button/group_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final storeRaces = Modular.get<RacesController>();
  final storeEmotions = Modular.get<EmotionsController>();
  final storeStakes = Modular.get<StakesController>();

  List<RaceModel> races = [];
  late Disposer _races;

  List<EmotionModel> emotions = [];
  late Disposer _emotions;

  List<StakeModel> stakes = [];
  late Disposer _stakes;

  String filterDate = "";

  int raceFilter = 0;

  final btnsController = GroupButtonController();
  String selectedItem = "";

  final plController = TextEditingController();
  final obsController = TextEditingController();

  String balance = "";
  String todaysProfit = "";

  double operationRating = 0;
  double emotionalRating = 0;

  String emotionId = "";
  String stakeId = "";

  double yesterdayBalance = 0;
  double todayBalance = 0;

  getYesterdayBalance() async {
    yesterdayBalance = await storeRaces.getDaillyBalance(DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10));
  }

  @override
  void initState() {
    getYesterdayBalance();
    storeRaces.getAllByDay(DateTime.now().toIso8601String().substring(0, 10));
    storeEmotions.getAll();
    storeStakes.getAll();
    btnsController.selectIndex(raceFilter);

    _races = storeRaces.observer(onState: (state) async {
      for (var s in state) {
        if (s.balance! > todayBalance) {
          todayBalance = s.balance!;
        }
      }

      if (todayBalance == 0) {
        todayBalance = yesterdayBalance;
      }

      setState(() {
        filterDate = DateTime.now().toIso8601String().substring(0, 10);
        races = state;
        balance = "${todayBalance.toStringAsFixed(2)}€";
        todaysProfit =
            "${(((todayBalance / yesterdayBalance) - 1) * 100).toStringAsFixed(2)}%";
      });
    });

    _emotions = storeEmotions.observer(onState: (state) {
      state.insert(0, EmotionModel(id: '', name: ''));
      setState(() {
        emotions = state;
      });
    });

    _stakes = storeStakes.observer(onState: (state) {
      state.insert(0, StakeModel(id: '', name: ''));
      setState(() {
        stakes = state;
      });
    });
    super.initState();
  }

  bool finishLoading() {
    bool r = false;
    if (emotions.isNotEmpty && stakes.isNotEmpty && races.isNotEmpty) {
      r = true;
    }
    return r;
  }

  List<RaceModel> filterRaces() {
    List<RaceModel> aux = [];

    if (raceFilter == 0) {
      aux = races.where((r) => r.statusId == raceAvailable).toList();
    } else if (raceFilter == 1) {
      aux = races.where((r) => r.statusId == racePlayed).toList();
    } else {
      aux = races;
    }

    return aux;
  }

  List<dynamic> distinctRaceCourse() {
    List<dynamic> r = [];
    List<RaceModel> aux = filterRaces();
    aux.forEach((rc) {
      if (!r.contains((rc.raceCourseId, rc.raceCourse))) {
        r.add((rc.raceCourseId, rc.raceCourse));
      }
    });
    return r;
  }

  @override
  void dispose() {
    _races();
    _emotions();
    _stakes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !finishLoading()
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      border:
                                          Border.all(color: Colors.black87)),
                                  child: Center(
                                    child: Text(
                                      filterRaces().length.toString(),
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  filterDate,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(balance),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(todaysProfit),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GroupButton<String>(
                                  options: const GroupButtonOptions(
                                      selectedColor: Colors.black87),
                                  controller: btnsController,
                                  buttons: const ["Available", "Played", "All"],
                                  onSelected: (value, i, isSelected) {
                                    btnsController.selectIndex(i);
                                    setState(() {
                                      raceFilter = i;
                                    });
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Row(
                                children: [
                                  PopupMenuButton<String>(
                                    tooltip: "Abandon RaceCourse",
                                    icon: Icon(Icons.event_busy_outlined),
                                    initialValue: selectedItem,
                                    onSelected: (String item) {
                                      showDialog<String>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Abandon RaceCourse'),
                                          content: const Text(
                                              'Are you sure that you want to abandon all the races of this racecourt?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'No'),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                races.forEach((r) async {
                                                  if (r.raceCourseId == item &&
                                                      r.statusId ==
                                                          raceAvailable) {
                                                    await storeRaces
                                                        .abandon(r.id!);
                                                  }
                                                });
                                                Navigator.pop(context, 'Yes');
                                              },
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      for (var item in distinctRaceCourse())
                                        PopupMenuItem<String>(
                                          value: item.$1,
                                          child: Text(item.$2),
                                        ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        showDialog<String>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Finish Day'),
                                            content: const Text(
                                                'Are you sure that you want to finish this day?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'No'),
                                                child: const Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  double _balance = 0;
                                                  for (var r in races) {
                                                    if (r.statusId ==
                                                        racePlayed) {
                                                      if (r.balance! > 0) {
                                                        _balance = r.balance!;
                                                      }
                                                    }
                                                  }

                                                  races.forEach((r) async {
                                                    if (r.statusId ==
                                                        raceAvailable) {
                                                      await storeRaces
                                                          .reject(r.id!);
                                                    }
                                                  });

                                                  await storeRaces.finishDay(
                                                      DateTime.now()
                                                          .toIso8601String()
                                                          .substring(0, 10),
                                                      _balance);

                                                  Navigator.pop(context, 'Yes');
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon:
                                          Icon(Icons.event_available_outlined))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                          visible: filterRaces().isEmpty,
                          child: const Center(child: Text("No races yet!"))),
                      ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: filterRaces().length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              color: raceFilter == 0
                                  ? raceAvailableColor
                                  : raceFilter == 1 || raceFilter == 2
                                      ? filterRaces()[index].statusId ==
                                              raceAbandoned
                                          ? raceAbandonedColor
                                          : filterRaces()[index].statusId ==
                                                  raceRejected
                                              ? raceRejectedColor
                                              : filterRaces()[index].statusId ==
                                                      raceAvailable
                                                  ? raceAvailableColor
                                                  : filterRaces()[index].pl! > 0
                                                      ? raceWonColor
                                                      : raceLostColor
                                      : const Color.fromARGB(
                                          255, 222, 247, 223),
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                        "${filterRaces()[index].raceCourse!} - ${filterRaces()[index].distance!} // ${filterRaces()[index].nrHorses!} runners"),
                                    Visibility(
                                      visible: (raceFilter == 1 ||
                                              raceFilter == 2) &&
                                          filterRaces()[index]
                                                  .operationalRating! >
                                              0,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: RatingBar.builder(
                                          initialRating: filterRaces()[index]
                                              .operationalRating!,
                                          minRating: 1,
                                          maxRating: 5,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 20,
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                          ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                        visible: filterRaces()[index].obs != "",
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20.0),
                                          child: Tooltip(
                                              margin: const EdgeInsets.only(
                                                  left: 20, right: 20),
                                              message:
                                                  filterRaces()[index].obs!,
                                              child: const Icon(Icons.info)),
                                        )),
                                    Visibility(
                                        visible:
                                            filterRaces()[index].emotion != "",
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                              filterRaces()[index].emotion!),
                                        )),
                                    Visibility(
                                        visible:
                                            filterRaces()[index].stake != "",
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child:
                                              Text(filterRaces()[index].stake!),
                                        ))
                                  ],
                                ),
                                subtitle: Text(
                                  filterRaces()[index].name!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                leading: SizedBox(
                                    width: 60,
                                    child: Text(
                                      filterRaces()[index].hour!,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )),
                                trailing: raceFilter == 0
                                    ? Column(
                                        children: [
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                                Icons.more_vert_outlined),
                                            onSelected: (String item) {
                                              if (item == "reject") {
                                                showDialog<String>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Reject Race'),
                                                    content: Text(
                                                        'Are you sure that you want to reject the ${filterRaces()[index].hour!} ${filterRaces()[index].raceCourse!} race?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, 'No'),
                                                        child: const Text('No'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await storeRaces
                                                              .reject(
                                                                  filterRaces()[
                                                                          index]
                                                                      .id!);
                                                          Navigator.pop(
                                                              context, 'Yes');
                                                        },
                                                        child:
                                                            const Text('Yes'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else if (item == "pl") {
                                                plController.text = "";
                                                emotionId = "";
                                                stakeId = "";
                                                showDialog<String>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Finish Race'),
                                                    content: SizedBox(
                                                      width: 400,
                                                      height: 312,
                                                      child: Column(
                                                        children: [
                                                          TextField(
                                                            autofocus: true,
                                                            controller:
                                                                plController,
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelText:
                                                                  'Enter profit lost value',
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 12.0),
                                                            child: Text(
                                                                "Operational rating"),
                                                          ),
                                                          RatingBar.builder(
                                                            initialRating: 0,
                                                            minRating: 1,
                                                            maxRating: 5,
                                                            direction:
                                                                Axis.horizontal,
                                                            allowHalfRating:
                                                                true,
                                                            itemCount: 5,
                                                            itemPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                            itemBuilder:
                                                                (context, _) =>
                                                                    const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            onRatingUpdate:
                                                                (rating) {
                                                              setState(() {
                                                                operationRating =
                                                                    rating;
                                                              });
                                                            },
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 12.0),
                                                            child: TextField(
                                                              autofocus: false,
                                                              maxLines: 4,
                                                              controller:
                                                                  obsController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                labelText:
                                                                    'Observations',
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 12.0),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 3,
                                                                  child:
                                                                      DropdownButtonFormField<
                                                                          String>(
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Select your emotion',
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                                    value:
                                                                        emotionId,
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        emotionId =
                                                                            newValue!;
                                                                      });
                                                                    },
                                                                    items: emotions.map<
                                                                        DropdownMenuItem<
                                                                            String>>((EmotionModel
                                                                        value) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value: value
                                                                            .id,
                                                                        child: Text(
                                                                            value.name!),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      DropdownButtonFormField<
                                                                          String>(
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Select your stake',
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                                    value:
                                                                        stakeId,
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        stakeId =
                                                                            newValue!;
                                                                      });
                                                                    },
                                                                    items: stakes.map<
                                                                        DropdownMenuItem<
                                                                            String>>((StakeModel
                                                                        value) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value: value
                                                                            .id,
                                                                        child: Text(
                                                                            value.name!),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                'Cancel'),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          double balance = await storeRaces
                                                              .getLastBalanceOfDay(
                                                                  DateTime.now()
                                                                      .toIso8601String()
                                                                      .substring(
                                                                          0,
                                                                          10));

                                                          if (balance == 0) {
                                                            balance = await storeRaces
                                                                .getDaillyBalance(DateTime
                                                                        .now()
                                                                    .subtract(
                                                                        const Duration(
                                                                            days:
                                                                                1))
                                                                    .toIso8601String()
                                                                    .substring(
                                                                        0, 10));
                                                          }
                                                          double pl = double.parse(
                                                                  plController
                                                                      .text) -
                                                              balance;

                                                          double pl_numeric =
                                                              double.parse(pl
                                                                  .toStringAsFixed(
                                                                      2));

                                                          double pl_percent =
                                                              pl / balance;

                                                          await storeRaces.finish(
                                                              filterRaces()[
                                                                      index]
                                                                  .id!,
                                                              pl_numeric,
                                                              double.parse(
                                                                  pl_percent
                                                                      .toStringAsFixed(
                                                                          6)),
                                                              double.parse(
                                                                  plController
                                                                      .text),
                                                              operationRating,
                                                              obsController
                                                                  .text,
                                                              emotionId,
                                                              stakeId);

                                                          Navigator.pop(
                                                              context, 'Save');
                                                        },
                                                        child:
                                                            const Text('Save'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: "pl",
                                                child: Text('Finish race'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: "reject",
                                                child: Text('Reject race'),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    : raceFilter == 2
                                        ? filterRaces()[index].statusId !=
                                                    raceRejected &&
                                                filterRaces()[index].statusId !=
                                                    raceAbandoned &&
                                                filterRaces()[index].statusId !=
                                                    raceAvailable
                                            ? Text(
                                                "${filterRaces()[index].plPercent! > 0 ? "+" : ""}${(filterRaces()[index].plPercent! * 100).toStringAsFixed(2)}%",
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              )
                                            : null
                                        : raceFilter == 1
                                            ? Column(
                                                children: [
                                                  Text(
                                                    "${filterRaces()[index].plPercent! > 0 ? "+" : ""}${(filterRaces()[index].plPercent! * 100).toStringAsFixed(2)}%",
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    "${filterRaces()[index].balance!.toStringAsFixed(2)}€",
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  )
                                                ],
                                              )
                                            : null,
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ));
  }
}
