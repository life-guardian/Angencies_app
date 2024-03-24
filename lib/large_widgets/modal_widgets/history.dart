// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';
import 'package:agencies_app/large_widgets/modal_widgets/filter_history.dart';

import 'package:agencies_app/models/alert_history.dart';
import 'package:agencies_app/models/event_history.dart';
import 'package:agencies_app/functions/modal_bottom_sheet.dart';
import 'package:agencies_app/models/operation_history.dart';
import 'package:agencies_app/providers/alert_history_provider.dart';
import 'package:agencies_app/providers/event_history_provider.dart';
import 'package:agencies_app/providers/rescue_history_provider.dart';
import 'package:agencies_app/small_widgets/listview_builder/manage/alert_history_listview.dart';
import 'package:agencies_app/small_widgets/listview_builder/manage/event_history_listview.dart';
import 'package:agencies_app/small_widgets/listview_builder/manage/rescue_operation_history_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class History extends ConsumerStatefulWidget {
  const History({
    super.key,
    required this.token,
    required this.agencyName,
  });

  final token;
  final String agencyName;

  @override
  ConsumerState<History> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<History> {
  late final jwtToken;
  late Map<String, String> headers;
  ModalBottomSheet modalBottomSheet = ModalBottomSheet();

  List<String> values = [
    'Alert History',
    'Event History',
    'Rescue Operations History'
  ];
  String filterValue = 'Alert History';

  List<OperationHistory> operationHistoryData = [];
  late Widget activeWidget;

  @override
  void initState() {
    super.initState();

    assignActiveWidget();
    initializeTokenHeader();
    // Get list of data from server
    getAlertHistoryData();
    getEventHistoryData();
    getOperationHistoryData();
  }

  void assignActiveWidget() {
    activeWidget = ref.read(alertHistoryProvider).isNotEmpty
        ? activeWidget = BuildAlertHistoryListView(
            ref: ref,
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.grey,
            ),
          );
  }

  void initializeTokenHeader() {
    jwtToken = widget.token;
    headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $jwtToken'
    };
  }

  String baseUrl = dotenv.get("BASE_URL");

  Future<void> getAlertHistoryData() async {
    var response = await http.get(
      Uri.parse('$baseUrl/api/history/agency/alerts'),
      headers: headers,
    );

    List<AlertHistory> data = [];

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      for (var jsonData in jsonResponse) {
        data.add(AlertHistory.fromJson(jsonData));
      }
    }

    ref.read(alertHistoryProvider.notifier).addList(data);

    setState(() {
      activeWidget = BuildAlertHistoryListView(
        ref: ref,
      );
    });
  }

  Future<void> getEventHistoryData() async {
    var response = await http.get(
      Uri.parse('$baseUrl/api/history/agency/events'),
      headers: headers,
    );

    List<EventHistory> data = [];

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      for (var jsonData in jsonResponse) {
        data.add(EventHistory.fromJson(jsonData));
      }
    }
    ref.read(eventHistoryProvider.notifier).addList(data);
  }

  Future<void> getOperationHistoryData() async {
    var response = await http.get(
      Uri.parse('$baseUrl/api/history/agency/operations'),
      headers: headers,
    );

    List<OperationHistory> data = [];

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      for (var jsonData in jsonResponse) {
        data.add(OperationHistory.fromJson(jsonData));
      }
    }

    ref.read(rescueHistoryProvider.notifier).addList(data);
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
                    widget.agencyName,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            filterValue,
                            style: GoogleFonts.plusJakartaSans().copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            modalBottomSheet.openModal(
                              context: context,
                              widget: FilterHistory(
                                getFilterValue: (value) {
                                  setState(() {
                                    filterValue = value;
                                    if (filterValue == 'Alert History') {
                                      activeWidget = BuildAlertHistoryListView(
                                        ref: ref,
                                      );
                                    } else if (filterValue == 'Event History') {
                                      // eventhistory widget;
                                      activeWidget = BuildEventHistoryListView(
                                        ref: ref,
                                      );
                                    } else {
                                      // rescue history widget
                                      activeWidget = BuildRescueHistoryListView(
                                        ref: ref,
                                      );
                                    }
                                  });
                                },
                              ),
                              isDismissible: true,
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'Filter',
                                style: GoogleFonts.plusJakartaSans().copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 4),
                                child: Image.asset(
                                  'assets/logos/settings-sliders.png',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
