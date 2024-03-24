// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:agencies_app/constants/sizes.dart';
import 'package:agencies_app/models/event_list.dart';
import 'package:agencies_app/functions/modal_bottom_sheet.dart';
import 'package:agencies_app/providers/manage_events_provider.dart';
import 'package:agencies_app/small_widgets/listview_builder/events/manage_event_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ManageEventsScreen extends ConsumerStatefulWidget {
  const ManageEventsScreen({
    super.key,
    required this.agencyName,
    required this.token,
  });

  final String agencyName;
  final token;

  @override
  ConsumerState<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends ConsumerState<ManageEventsScreen> {
  late final jwtToken;
  late Map<String, String> headers;
  List<EventList> eventList = [];
  List<String> eventsLocality = [];

  ModalBottomSheet modalBottomSheet = ModalBottomSheet();
  String filterValue = 'Events';

  late Widget activeWidget;

  @override
  void initState() {
    super.initState();
    assignActiveWidget();
    initializeTokenHeader();
    getEventList();
  }

  void assignActiveWidget() {
    activeWidget = ref.read(manageEventsProvider).isNotEmpty
        ? BuildManageEventListView(
            ref: ref,
            token: widget.token,
            agencyName: widget.agencyName,
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

  Future<void> getEventList() async {
    var response = await http.get(
      Uri.parse('$baseUrl/api/event/agency/list'),
      headers: headers,
    );

    List<EventList> data = [];

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      for (var jsonData in jsonResponse) {
        data.add(EventList.fromJson(jsonData));
      }
    }

    await getEventsLocality(data: data).then((eventListWithLocalities) {
      data = eventListWithLocalities;
    });

    ref.read(manageEventsProvider.notifier).addList(data);

    setState(() {
      activeWidget = BuildManageEventListView(
        ref: ref,
        token: widget.token,
        agencyName: widget.agencyName,
      );
    });
  }

  Future<List<EventList>> getEventsLocality(
      {required List<EventList> data}) async {
    List<List<double>> coordinates = [];

    for (var event in data) {
      coordinates.add(event.eventPlace!);
    }

    // print(coordinates.toList());

    List<String> localities = [];

    for (List<double> coordinate in coordinates) {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(coordinate[1], coordinate[0]);
        Placemark placemark = placemarks[0];
        String? locality = placemark.locality;
        localities.add(locality!);
      } catch (error) {
        localities.add("Unknown"); // Add a placeholder for unknown localities
      }
    }

    // eventList.ad

    for (int i = 0; i < data.length; i++) {
      data[i].locality = localities[i];
    }

    // print(data);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
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
                  const Spacer(),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor:
                          (themeData.brightness == Brightness.light)
                              ? const Color.fromARGB(185, 30, 35, 44)
                              : const Color(0xffe1dcd3),
                      side: BorderSide(
                        color: (themeData.brightness == Brightness.light)
                            ? const Color.fromARGB(32, 30, 35, 44)
                            : const Color(0xffE1DCD3),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                        ),
                        Text('back')
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 21,
            ),
            Expanded(
              child: Container(
                // width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        margin: screenWidth > mobileScreenWidth
                            ? EdgeInsets.only(left: screenWidth / 6.5)
                            : null,
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 5, bottom: 15),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filterValue,
                                  style: GoogleFonts.plusJakartaSans().copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Tap on the event to see registered users",
                                  style: GoogleFonts.plusJakartaSans().copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: screenWidth > mobileScreenWidth
                              ? screenWidth / 1.5
                              : double.infinity,
                          child: activeWidget,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
