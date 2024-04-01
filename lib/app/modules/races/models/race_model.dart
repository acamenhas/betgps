import 'package:betgps/app/shared/base_model.dart';

class RaceModel implements IBaseModel {
  String? id;
  String? date;
  String? hour;
  String? name;
  String? raceCourse;
  String? raceCourseId;
  String? distance;
  int? nrHorses;
  String? status;
  String? statusId;
  double? pl;
  double? plPercent;
  double? balance;
  double? operationalRating;
  String? obs;
  String? emotion;
  String? stake;

  RaceModel(
      {this.id,
      this.date,
      this.hour,
      this.name,
      this.raceCourse,
      this.raceCourseId,
      this.distance,
      this.nrHorses,
      this.status,
      this.statusId,
      this.pl,
      this.plPercent,
      this.balance,
      this.operationalRating,
      this.obs,
      this.emotion,
      this.stake});

  static List<RaceModel> fromJsonList(List list) {
    if (list == null) return [];
    return list
        .map((item) => item.cast<String, dynamic>())
        .map<RaceModel>((item) => RaceModel.fromMap(item))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'hour': hour,
      'name': name,
      'raceCourse': raceCourse,
      'raceCourseId': raceCourseId,
      'distance': distance,
      'nrHorses': nrHorses,
      'status': status,
      'statusId': statusId,
      'pl': pl,
      'plPercent': plPercent,
      'balance': balance,
      'operationalRating': operationalRating,
      'emotion': emotion,
      'stake': stake
    };
  }

  factory RaceModel.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return RaceModel();
    }

    return RaceModel(
        id: map['id'] ?? "",
        date: map['date'].toString() ?? "",
        hour: map['date'].toString().substring(11, 16) ?? "",
        name: map['name'],
        raceCourse: map['raceCourse']['name'],
        raceCourseId: map['raceCourse']['id'],
        distance: map['distance']['name'],
        nrHorses: map['nrHorses'] ?? 0,
        status: map['raceStatus'] != null ? map['raceStatus']['name'] : "",
        statusId: map['raceStatus'] != null ? map['raceStatus']['id'] : "",
        pl: map['pl'],
        plPercent: map['plPercent'],
        balance: map['balance'],
        operationalRating: map['operationalRating'],
        obs: map['obs'] ?? "",
        emotion: map['emotion'] != null ? map['emotion']['name'] : "",
        stake: map['stake'] != null ? map['stake']['name'] : "");
  }
}
