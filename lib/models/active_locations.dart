// ignore_for_file: prefer_collection_literals

class LiveAgencies {
  double? lat;
  double? lng;
  String? agencyId;
  String? agencyName;
  int? phoneNumber;
  String? representativeName;
  String? rescueOpsName; // can be null
  String? rescueOpsDescription; // can be null
  int? rescueTeamSize; // can be null

  LiveAgencies({
    this.lat,
    this.lng,
    this.agencyId,
    this.agencyName,
    this.phoneNumber,
    this.representativeName,
    this.rescueOpsName,
    this.rescueOpsDescription,
    this.rescueTeamSize,
  });

  LiveAgencies.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    agencyId = json['agencyId'];
    agencyName = json['agencyName'];
    phoneNumber = json['phoneNumber'];
    representativeName = json['representativeName'];
    rescueOpsName = json['rescueOpsName'];
    rescueOpsDescription = json['rescueOpsDescription'];
    rescueTeamSize = json['rescueTeamSize'];
  }


}
