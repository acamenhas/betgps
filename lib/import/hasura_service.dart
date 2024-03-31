import 'package:betgps/app/shared/custom_hasura_connect.dart';
import 'package:hasura_connect/hasura_connect.dart';

class HasuraService {
  late HasuraConnect _connect;

  HasuraService._() {
    _connect = CustomHasuraConnect.getConnect();
  }

  static final instance = HasuraService._();

  /*
    ===========================================
    COUNTRY
    ===========================================
  */

  String countryQuery = """
    query q(\$country: String) {
      betgps_country(where: {name: {_eq: \$country}}) {
        id
      }
    }
  """;

  Future<String> getCountry(String country) async {
    var resp =
        await _connect.query(countryQuery, variables: {'country': country});

    if ((resp['data']['betgps_country'] as List).isNotEmpty) {
      return (resp['data']['betgps_country'] as List).first['id'];
    } else {
      return "";
    }
  }

  /*
    ===========================================
    RACE COURSE
    ===========================================
  */

  String raceCourseQuery = """
    query q(\$raceCourse: String) {
      betgps_raceCourse(where: {name: {_eq: \$raceCourse}}) {
        id
      }
    }
  """;

  Future<String> getRaceCourse(String raceCourse) async {
    var resp = await _connect
        .query(raceCourseQuery, variables: {'raceCourse': raceCourse});

    if ((resp['data']['betgps_raceCourse'] as List).isNotEmpty) {
      return (resp['data']['betgps_raceCourse'] as List).first['id'];
    } else {
      return "";
    }
  }

  String insertRaceCourseMutation = """
    mutation MyMutation(\$name: String, \$countryId: uuid) {
      insert_betgps_raceCourse_one(object: {name: \$name, countryId: \$countryId}) {
        id
      }
    }
  """;

  Future<String> insertRaceCourse(String name) async {
    String countryId = "";
    if (name.contains("(IRE)")) {
      countryId = await getCountry("IE");
    } else {
      countryId = await getCountry("EN");
    }
    dynamic r = await _connect.mutation(insertRaceCourseMutation, variables: {
      'name': name.replaceAll("(IRE)", "").replaceAll("ABD: ", ""),
      'countryId': countryId
    });
    return r['data']['insert_betgps_raceCourse_one']['id'].toString();
  }

  /*
    ===========================================
    CLASS
    ===========================================
  */

  String classQuery = """
    query q(\$name: String) {
      betgps_class(where: {name: {_eq: \$name}}) {
        id
      }
    }
  """;

  Future<String> getClass(String name) async {
    var resp = await _connect.query(classQuery, variables: {'name': name});

    if ((resp['data']['betgps_class'] as List).isNotEmpty) {
      return (resp['data']['betgps_class'] as List).first['id'];
    } else {
      return "";
    }
  }

  String insertClassMutation = """
    mutation MyMutation(\$name: String) {
      insert_betgps_class_one(object: {name: \$name}) {
        id
      }
    }
  """;

  Future<String> insertClass(String name) async {
    dynamic r =
        await _connect.mutation(insertClassMutation, variables: {'name': name});
    return r['data']['insert_betgps_class_one']['id'].toString();
  }

  /*
    ===========================================
    AGE
    ===========================================
  */

  String ageQuery = """
    query q(\$age: String) {
      betgps_age(where: {name: {_eq: \$age}}) {
        id
      }
    }
  """;

  Future<String> getAge(String age) async {
    var resp = await _connect.query(ageQuery, variables: {'age': age});

    if ((resp['data']['betgps_age'] as List).isNotEmpty) {
      return (resp['data']['betgps_age'] as List).first['id'];
    } else {
      return "";
    }
  }

  String insertAgeMutation = """
    mutation MyMutation(\$name: String) {
      insert_betgps_age_one(object: {name: \$name}) {
        id
      }
    }
  """;

  Future<String> insertAge(String name) async {
    dynamic r =
        await _connect.mutation(insertAgeMutation, variables: {'name': name});
    return r['data']['insert_betgps_age_one']['id'].toString();
  }

  /*
    ===========================================
    DISTANCE
    ===========================================
  */

  String distanceQuery = """
    query q(\$distance: String) {
      betgps_distance(where: {name: {_eq: \$distance}}) {
        id
      }
    }
  """;

  Future<String> getDistance(String distance) async {
    var resp =
        await _connect.query(distanceQuery, variables: {'distance': distance});

    if ((resp['data']['betgps_distance'] as List).isNotEmpty) {
      return (resp['data']['betgps_distance'] as List).first['id'];
    } else {
      return "";
    }
  }

  String insertDistanceMutation = """
    mutation MyMutation(\$name: String) {
      insert_betgps_distance_one(object: {name: \$name}) {
        id
      }
    }
  """;

  Future<String> insertDistance(String name) async {
    dynamic r = await _connect
        .mutation(insertDistanceMutation, variables: {'name': name});
    return r['data']['insert_betgps_distance_one']['id'].toString();
  }

  /*
    ===========================================
    RACE
    ===========================================
  */

  String insertRaceMutation = """
    mutation MyMutation(\$date: timestamp, \$name: String, \$racingCourseId: uuid, \$ageId: uuid, \$classId: uuid, \$distanceId: uuid, \$raceStatusId: uuid, \$nrHorses: Int, \$handicap: Boolean) {
      insert_betgps_race_one(object: {date: \$date, name: \$name, racingCourseId: \$racingCourseId, ageId: \$ageId, classId: \$classId, distanceId: \$distanceId, raceStatusId: \$raceStatusId, nrHorses: \$nrHorses, handicap:\$handicap}) {
        id
      }
    }
  """;

  Future<String> insertRace(
      String date,
      String name,
      String racingCourseId,
      String ageId,
      String classId,
      String distanceId,
      String raceStatusId,
      int nrHorses,
      bool handicap) async {
    dynamic r = await _connect.mutation(insertRaceMutation, variables: {
      'date': date,
      'name': name,
      'racingCourseId': racingCourseId,
      'ageId': ageId,
      'classId': classId,
      'distanceId': distanceId,
      'raceStatusId': raceStatusId,
      'nrHorses': nrHorses,
      'handicap': handicap
    });
    return r['data']['insert_betgps_race_one']['id'].toString();
  }
}
