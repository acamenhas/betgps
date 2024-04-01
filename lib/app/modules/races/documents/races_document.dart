const String racesByDay = """
  subscription q(\$di: timestamp, \$df: timestamp) {
    betgps_race(order_by:{date: asc}, where: {date: {_gt: \$di, _lt: \$df}}) {
      id
      date
      name
      raceCourse {
        id
        name
      }
      distance {
        name
      }
      raceStatus {
        id
        name
      }
      emotion {
        name
      }
      stake {
        name
      }
      nrHorses
      pl
      plPercent
      balance
      operationalRating
      obs
    }
  }
""";

const String rejectRace = """
mutation MyMutation(\$id: uuid, \$raceStatusId: uuid, \$updateDate: timestamp) {
  update_betgps_race(where: {id: {_eq: \$id}}, _set: {
    raceStatusId: \$raceStatusId,
    updateDate: \$updateDate
    }) {
    affected_rows
  }
}
""";

const String lastBalanceOfDay = """
query q(\$di: timestamp, \$df: timestamp) {
  betgps_race(where: {date: {_gt: \$di, _lt: \$df}, balance: {_gt: "0"}}, order_by: {date: desc}, limit: 1) {
    balance
  }
}
""";

const String daillyBalance = """
query q(\$date: date) {
  betgps_dailly(where: {date: {_eq: \$date}}) {
    balance
  }
}
""";

const String finishRace = """
mutation MyMutation(\$id: uuid, \$pl: float8, \$pl_percent: float8, \$balance: float8, \$raceStatusId: uuid, \$updateDate: timestamp, \$operationalRating: float8, \$obs: String, \$emotionId: uuid, \$stakeId: uuid) {
  update_betgps_race(where: {id: {_eq: \$id}}, _set: {
    pl: \$pl,
    plPercent: \$pl_percent,
    balance: \$balance,
    operationalRating: \$operationalRating,
    obs: \$obs,
    raceStatusId: \$raceStatusId,
    updateDate: \$updateDate,
    emotionId: \$emotionId,
    stakeId: \$stakeId
    }) {
    affected_rows
  }
}
""";

const String insertDay = """
mutation MyMutation(\$date: date, \$balance: float8) {
  insert_betgps_dailly_one(object: {
    date: \$date,
    balance: \$balance
    }) {
    date
  }
}
""";
