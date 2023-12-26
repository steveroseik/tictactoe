
class TournamentRoom{
  String id;
  List<String> users;

  TournamentRoom({required this.id, required this.users});

  factory TournamentRoom.fromJson(Map<String, dynamic> json) =>
      TournamentRoom(
          id: json['id'], users: List<String>.from(json['users']));

  updateUsers(List<dynamic> newUsers){
    users = List<String>.from(newUsers);
  }
}