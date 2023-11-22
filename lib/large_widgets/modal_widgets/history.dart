// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';

import 'package:agencies_app/api_urls/config.dart';

import 'package:agencies_app/models/alert_history.dart';
import 'package:agencies_app/models/event_history.dart';
import 'package:agencies_app/small_widgets/listview_builder/build_listview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  const History({
    super.key,
    required this.token,
    required this.agencyName,
  });

  final token;
  final String agencyName;

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late final jwtToken;
  late Map<String, String> headers;

  List<String> values = [
    'Alert History',
    'Event History',
    'Rescue Operations History'
  ];
  String dropDownValue = 'Alert History';

  List<AlertHistory> alertHistoryData = [];
  List<EventHistory> eventHistoryData = [];

  Widget activeWidget = const Center(
    child: CircularProgressIndicator(
      color: Colors.grey,
    ),
  );

  @override
  void initState() {
    super.initState();
    initializeTokenHeader();
    getAlertHistoryData().then((value) {
      setState(() {
        alertHistoryData.addAll(value);
        activeWidget = BuildAlertHistoryListView(list: alertHistoryData);
      });
    });
    getEventHistoryData().then(
      (value) => eventHistoryData.addAll(value),
    );
  }

  void initializeTokenHeader() {
    jwtToken = widget.token;
    headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $jwtToken'
    };
  }

  Future<List<AlertHistory>> getAlertHistoryData() async {
    var response = await http.get(
      Uri.parse(alertHistoryUrl),
      headers: headers,
    );

    List<AlertHistory> data = [];

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      for (var jsonData in jsonResponse) {
        data.add(AlertHistory.fromJson(jsonData));
      }
    }

    return data;
  }

  Future<List<EventHistory>> getEventHistoryData() async {
    var response = await http.get(
      Uri.parse(eventHistoryUrl),
      headers: headers,
    );

    List<EventHistory> data = [];

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      for (var jsonData in jsonResponse) {
        data.add(EventHistory.fromJson(jsonData));
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/logos/indiaflaglogo.png'),
              const SizedBox(
                width: 21,
              ),
              Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jai Hind!',
                    style: GoogleFonts.inter().copyWith(fontSize: 12),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'NDRF Team ${widget.agencyName}',
                    // email,
                    style: GoogleFonts.plusJakartaSans().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 21,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Expanded(
                            child: Text(
                              dropDownValue,
                              style: GoogleFonts.plusJakartaSans().copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                underline: null,
                                iconSize: 35,
                                // value: dropDownValue,
                                items: values
                                    .map(
                                      (value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropDownValue = newValue!;
                                    if (dropDownValue == 'Alert History') {
                                      activeWidget = BuildAlertHistoryListView(
                                          list: alertHistoryData);
                                    } else if (dropDownValue ==
                                        'Event History') {
                                      // eventhistory widget;
                                      activeWidget = BuildEventHistoryListView(
                                          list: eventHistoryData);
                                    } else {
                                      // rescue history widget
                                      activeWidget = const Center(
                                          child: Text('Need to work on this'));
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                icon: const Icon(
                                  Icons.sort_rounded,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // listview here
                  // BuildListView(list: temp),
                  Expanded(
                    child: activeWidget,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
