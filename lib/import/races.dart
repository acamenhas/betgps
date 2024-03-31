import 'dart:io';

import 'package:betgps/import/hasura_service.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:http/http.dart' as http;

String raceMainBlock = '<div class="sdc-site-concertina-block"';
String raceStatusActive = '468045e2-78e5-4025-974d-fac37289950b';
String raceStatusAbandoned = '4cd545d0-52e8-4723-bf0b-53649a9eadf2';

void main(List<String> args) async {
  HasuraService hasuraService = HasuraService.instance;

  print("import races...");
  var url = Uri.https('www.skysports.com', '/racing/racecards');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    String htmlToParse = response.body;
    int i = 0;

    while (htmlToParse.contains(raceMainBlock)) {
      i++;
      int posRaceBlock = htmlToParse.indexOf(raceMainBlock);
      htmlToParse = htmlToParse.substring(
          posRaceBlock + raceMainBlock.length, htmlToParse.length);
      String title = HtmlCharacterEntities.decode(parseTitle(htmlToParse));
      if (title.isNotEmpty) {
        print(title);

        String racingCourseId = "";
        if (args.isNotEmpty && args.first == "save") {
          racingCourseId = await hasuraService.getRaceCourse(
              title.replaceAll("(IRE)", "").replaceAll("ABD: ", ""));
          if (racingCourseId.isEmpty) {
            racingCourseId = await hasuraService.insertRaceCourse(title);
          }
        }

        List<List<String>> races = parceRaces(htmlToParse);
        for (var race in races) {
          print(race.toString());

          if (args.isNotEmpty && args.first == "save") {
            final dateDetails = race[0].split(":");
            final date = DateTime.now();
            final dateRace = date.copyWith(
                hour: int.parse(dateDetails[0]),
                minute: int.parse(dateDetails[1]),
                second: 0,
                millisecond: 0,
                microsecond: 0);

            String raceName = race[1].toString();

            //age
            String ageId = "";
            ageId = await hasuraService.getAge(race[2].toString());
            if (ageId.isEmpty) {
              ageId = await hasuraService.insertAge(race[2].toString());
            }

            //class
            String classId = "";
            classId = await hasuraService.getClass(race[3].toString());
            if (classId.isEmpty) {
              classId = await hasuraService.insertClass(race[3].toString());
            }

            //distance
            String distanceId = "";
            String distanceAux = race[4].toString();
            if (race[4].toString().contains('f')) {
              distanceAux = race[4]
                  .toString()
                  .substring(0, race[4].toString().indexOf('f') + 1)
                  .trimLeft();
            } else {
              if (race[4].toString().contains('y')) {
                List<String> aux = race[4].toString().trimLeft().split(" ");
                distanceAux = aux[0];
              }
            }

            distanceId = await hasuraService.getDistance(distanceAux);
            if (distanceId.isEmpty) {
              distanceId = await hasuraService.insertDistance(distanceAux);
            }

            //race
            await hasuraService.insertRace(
                dateRace.toIso8601String(),
                raceName,
                racingCourseId,
                ageId,
                classId,
                distanceId,
                title.contains('ABD') ? raceStatusAbandoned : raceStatusActive,
                int.parse(race[5].toString()),
                raceName.toLowerCase().contains('handicap'));
          }
        }
        print("");
      }
    }
  }
}

String parseTitle(String block) {
  String titleBlock = '<h3 class="sdc-site-concertina-block__title"';
  int posTitle = block.indexOf(titleBlock);
  block = block.substring(posTitle + titleBlock.length, block.length);
  posTitle = block.indexOf('">');
  block = block.substring(posTitle + 2, block.length);
  posTitle = block.indexOf('</span');
  block = block.substring(0, posTitle);
  return block.contains("(") && !block.contains("IRE") ? "" : block;
}

List<List<String>> parceRaces(String block) {
  List<List<String>> aux = [];
  String raceBlock = '<div class="sdc-site-racing-meetings__event"';
  while (block.contains(raceBlock) &&
      (block.indexOf(raceBlock) < block.indexOf(raceMainBlock))) {
    int posRaceBlock = block.indexOf(raceBlock);
    block = block.substring(posRaceBlock + raceBlock.length, block.length);

    /* TIME */
    String raceBlockTime = '<span class="sdc-site-racing-meetings__event-time';
    posRaceBlock = block.indexOf(raceBlockTime);
    String blockTime =
        block.substring(posRaceBlock + raceBlockTime.length, block.length);
    posRaceBlock = blockTime.indexOf('">');
    blockTime = blockTime.substring(posRaceBlock + 2, blockTime.length);

    posRaceBlock = blockTime.indexOf('</span');
    blockTime = blockTime.substring(0, posRaceBlock);

    /* NAME */
    String raceBlockName = '<span class="sdc-site-racing-meetings__event-name';
    posRaceBlock = block.indexOf(raceBlockName);
    String blockName =
        block.substring(posRaceBlock + raceBlockName.length, block.length);
    posRaceBlock = blockName.indexOf('">');
    blockName = blockName.substring(posRaceBlock + 2, blockName.length);
    posRaceBlock = blockName.indexOf('</span');
    blockName = blockName.substring(0, posRaceBlock).trim();

    /* DETAILS */
    String raceBlockDetails =
        '<span class="sdc-site-racing-meetings__event-details';
    posRaceBlock = block.indexOf(raceBlockDetails);
    String blockDetails =
        block.substring(posRaceBlock + raceBlockDetails.length, block.length);
    posRaceBlock = blockDetails.indexOf('">');
    blockDetails =
        blockDetails.substring(posRaceBlock + 2, blockDetails.length);
    posRaceBlock = blockDetails.indexOf('</span');
    blockDetails = blockDetails
        .substring(0, posRaceBlock)
        .trim()
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("runners", "")
        .trim();

    List<String> details = blockDetails.split(",");
    details = [blockTime, HtmlCharacterEntities.decode(blockName), ...details];
    aux.add(details);
  }

  return aux;
}
