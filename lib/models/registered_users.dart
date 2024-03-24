class RegisteredUsers {
  String? userName;
  int? phoneNumber;

  RegisteredUsers({this.userName, this.phoneNumber});

  RegisteredUsers.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    phoneNumber = json['phoneNumber'];
  }
}
