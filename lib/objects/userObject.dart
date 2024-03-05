
import 'dart:convert';

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
