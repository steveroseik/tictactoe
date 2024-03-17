import 'dart:convert';

List<LeaderboardObject> leaderboardFromJson(String str) => List<LeaderboardObject>.from(json.decode(str).map((x) => LeaderboardObject.fromJson(x)));

String leaderboardToJson(List<LeaderboardObject> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));



class LeaderboardObject {
    String userId;
    int score;
    int dailyTournamentWins;
    int weeklyTournamentWins;
    int monthlyTournamentWins;

    LeaderboardObject({
        required this.userId,
        required this.score,
        required this.dailyTournamentWins,
        required this.weeklyTournamentWins,
        required this.monthlyTournamentWins,
    });

    factory LeaderboardObject.fromJson(Map<String, dynamic> json) => LeaderboardObject(
        userId: json["userId"],
        score: json["score"],
        dailyTournamentWins: json["dailyTournamentWins"],
        weeklyTournamentWins: json["weeklyTournamentWins"],
        monthlyTournamentWins: json["monthlyTournamentWins"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "score": score,
        "dailyTournamentWins": dailyTournamentWins,
        "weeklyTournamentWins": weeklyTournamentWins,
        "monthlyTournamentWins": monthlyTournamentWins,
    };
}
