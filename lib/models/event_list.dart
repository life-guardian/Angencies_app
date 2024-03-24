// ignore_for_file: prefer_collection_literals

class EventList {
  String? eventId;
  String? eventName;
  List<double>? eventPlace;
  String? eventDate;
  String? locality;

  EventList({this.eventId, this.eventName, this.eventPlace, this.eventDate});

  EventList.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    eventName = json['eventName'];
    eventPlace = json['eventPlace'].cast<double>();
    eventDate = json['eventDate'];
  }
}
