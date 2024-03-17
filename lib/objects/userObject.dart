
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:tictactoe/Configurations/constants.dart';

List<UserObject> userFromJson(String str) => List<UserObject>.from(json.decode(str).map((x) => UserObject.fromJson(x)));

String userToJson(List<UserObject> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserObject {
  String id;
  String name;
  int birthdate;
  bool isMale;
  int? country;
  int? city;
  int bronzeCoins;
  int silverCoins;
  int goldCoins;
  String provider;
  String email;
  String username;
  String? facebookId;
  Score? classicScore;
  Score? nineScore;
  Score? powersScore;
  DateTime createdAt;
  DateTime lastModified;

  UserObject({
    required this.id,
    required this.name,
    required this.birthdate,
    required this.isMale,
    this.country,
    this.city,
    required this.bronzeCoins,
    required this.silverCoins,
    required this.goldCoins,
    required this.provider,
    required this.email,
    required this.username,
    this.facebookId,
    this.classicScore,
    this.nineScore,
    this.powersScore,
    required this.createdAt,
    required this.lastModified,
  });

  Map<String, dynamic>? updateTournament(GameType type){
    switch(type){
      case GameType.classicDailyTournament:
        return classicScore!.updateTournament('daily', 1);
      case GameType.classicWeeklyTournament:
        return classicScore!.updateTournament('weekly', 1);
      case GameType.classicMonthlyTournament:
        return classicScore!.updateTournament('monthly', 1);
      case GameType.nineDailyTournament:
        return nineScore!.updateTournament('daily', 1);
      case GameType.nineWeeklyTournament:
        return nineScore!.updateTournament('weekly', 1);
      case GameType.nineMonthlyTournament:
        return nineScore!.updateTournament('monthly', 1);
      case GameType.powersDailyTournament:
        return powersScore!.updateTournament('daily', 1);
      case GameType.powersWeeklyTournament:
        return powersScore!.updateTournament('weekly', 1);
      case GameType.powersMonthlyTournament:
        return powersScore!.updateTournament('monthly', 1);
      default: return null;
    }
  }

  factory UserObject.fromJson(Map<String, dynamic> json) => UserObject(
    id: json["id"],
    name: json["name"],
    birthdate: json["birthdate"],
    isMale: json["isMale"],
    country: json["country"],
    city: json["city"],
    bronzeCoins: json["bronzeCoins"],
    silverCoins: json["silverCoins"],
    goldCoins: json["goldCoins"],
    provider: json["provider"],
    email: json["email"],
    username: json["username"],
    facebookId: json["facebookId"],
    classicScore: json["classicScore"] != null ? Score.fromJson(json["classicScore"]) : null,
    nineScore: json["nineScore"] != null ? Score.fromJson(json["nineScore"]) : null,
    powersScore: json["powersScore"] != null ? Score.fromJson(json["powersScore"]) : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
    lastModified: DateTime.fromMillisecondsSinceEpoch(json["lastModified"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "birthdate": birthdate,
    "isMale": isMale,
    "country": country,
    "city": city,
    "bronzeCoins": bronzeCoins,
    "silverCoins": silverCoins,
    "goldCoins": goldCoins,
    "provider": provider,
    "email": email,
    "username": username,
    "facebookId": facebookId,
    "classicScore": classicScore?.toJson(),
    "nineScore": nineScore?.toJson(),
    "powersScore": powersScore?.toJson(),
    "createdAt": createdAt.millisecondsSinceEpoch,
    "lastModified": lastModified.millisecondsSinceEpoch,
  };
}

class Score {
  int score;
  int wins;
  int loses;
  Map<String, dynamic>? tournamentWins;
  DateTime createdAt;
  DateTime lastModified;

  Score({
    required this.score,
    required this.wins,
    required this.loses,
    this.tournamentWins,
    required this.createdAt,
    required this.lastModified,
  });

  Map<String, dynamic> updateTournament(String name, int value){

    if (tournamentWins == null) {
      tournamentWins = {
        name: value
      };
      return tournamentWins!;
    }else{
      final toChange = tournamentWins!.keys.firstWhereOrNull((e) => e == name);
      if (toChange == null){
        tournamentWins![name] = value;
      }else{
        tournamentWins![name] = tournamentWins![name]! + value;
      }
      return tournamentWins!;
    }
  }

  factory Score.fromJson(Map<String, dynamic> json) => Score(
    score: json["score"],
    wins: json["wins"],
    loses: json["loses"],
    tournamentWins: json["tournamentWins"],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
    lastModified: DateTime.fromMillisecondsSinceEpoch(json["lastModified"]),
  );

  Map<String, dynamic> toJson() => {
    "score": score,
    "wins": wins,
    "loses": loses,
    "tournamentWins": tournamentWins,
    "createdAt": createdAt.millisecondsSinceEpoch,
    "lastModified": lastModified.millisecondsSinceEpoch,
  };
}
