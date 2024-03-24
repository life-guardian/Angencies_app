// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:agencies_app/large_widgets/card_widgets/event_rescue_count_card.dart';
import 'package:agencies_app/large_widgets/modal_widgets/organize_event.dart';
import 'package:agencies_app/large_widgets/modal_widgets/rescue_operation.dart';
import 'package:agencies_app/large_widgets/modal_widgets/send_alert.dart';
import 'package:agencies_app/functions/modal_bottom_sheet.dart';
import 'package:agencies_app/providers/agencydetails_providers.dart';

import 'package:agencies_app/screens/managae_events_screen.dart';
import 'package:agencies_app/screens/rescue_map_screen.dart';
import 'package:agencies_app/large_widgets/card_widgets/event_card.dart';
import 'package:agencies_app/large_widgets/card_widgets/manage_card.dart';

import 'package:agencies_app/large_widgets/modal_widgets/history.dart';
import 'package:agencies_app/transitions_animations/custom_page_transition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
// import 'package:jwt_decoder/jwt_decoder.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.token});
  final token;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String userId;
  String? eventsCount;
  String? rescueCount;
  String? agencyname;
  late bool isRescueOnGoing;

  // late double rescuseLineBarCount;
  // late double eventsLineBarCount;

  bool? isadded;

  ModalBottomSheet modalBottomSheet = ModalBottomSheet();

  @override
  void initState() {
    super.initState();
    getAgencyDataFromServer();
    // code to decode data from server
  }

  Future<void> getAgencyDataFromServer() async {
    final jwtToken = widget.token;

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $jwtToken'
    };

    String baseUrl = dotenv.get("BASE_URL");

    var response = await http.get(
      Uri.parse('$baseUrl/api/agency/eventroperationcount'),
      headers: headers,
    );

    var jsonResponse = jsonDecode(response.body);
    setState(() {
      eventsCount = jsonResponse['eventsCount'].toString();
      rescueCount = jsonResponse['rescueOperationsCount'].toString();
      agencyname = jsonResponse['agencyName'].toString();
      agencyname = agencyname![0].toUpperCase() + agencyname!.substring(1);
      ref
          .read(agencyNameProvider.notifier)
          .update((state) => agencyname ?? 'Loading...');
    });

    ref
        .read(eventsCountProvider.notifier)
        .update((state) => [eventsCount ?? '0', rescueCount ?? '0']);
  }

  void navigateToRescueMaps() {
    Navigator.of(context).push(
      CustomSlideTransition(
        direction: AxisDirection.left,
        child: const RescueMapScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isRescueOnGoing = ref.watch(isRescueOperationOnGoingProvider);

    ThemeData themeData = Theme.of(context);
    agencyname = ref.watch(agencyNameProvider);
    eventsCount = ref.watch(eventsCountProvider.notifier).state[0];
    rescueCount = ref.watch(eventsCountProvider.notifier).state[1];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/logos/indiaflaglogo.png'),
                  const SizedBox(
                    width: 21,
                  ),
                  Column(
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
                        agencyname ?? 'Loading...',
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
            EventRescueCountCard(
                eventCount: eventsCount ?? '0',
                rescueCount: rescueCount ?? '0'),
            const SizedBox(
              height: 21,
            ),
            Text(
              'Manage',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: kIsWeb
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: [
                  ManageCard(
                    text1: 'Rescue Operation',
                    text2: 'Start',
                    showModal: isRescueOnGoing
                        ? () {
                            navigateToRescueMaps();
                          }
                        : () async {
                            await modalBottomSheet.openModal(
                              context: context,
                              widget: RescueOperation(token: widget.token),
                            );
                            getAgencyDataFromServer();
                          },
                    lineColor1: Colors.yellow.shade400,
                    lineColor2: Colors.yellow.shade50,
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  ManageCard(
                    text1: 'Awareness Event',
                    text2: 'Organize Event',
                    showModal: () async {
                      await modalBottomSheet.openModal(
                        context: context,
                        widget: OrganizeEvent(token: widget.token),
                      );
                      getAgencyDataFromServer();
                    },
                    lineColor1: Colors.green.shade400,
                    lineColor2: Colors.green.shade50,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 140,
              // width: manageEventWidth,
              child: Row(
                mainAxisAlignment: kIsWeb
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: [
                  ManageCard(
                    text1: 'Alert for disaster',
                    text2: 'Send Alert',
                    showModal: () {
                      modalBottomSheet.openModal(
                        context: context,
                        widget: SendAlert(token: widget.token),
                      );
                    },
                    lineColor1: Colors.red.shade400,
                    lineColor2: Colors.red.shade50,
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  ManageCard(
                    text1: 'History',
                    text2: 'History',
                    showModal: () {
                      modalBottomSheet.openModal(
                        context: context,
                        widget: History(
                            token: widget.token, agencyName: agencyname!),
                      );
                    },
                    lineColor1: Colors.blue.shade400,
                    lineColor2: Colors.blue.shade50,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 31,
            ),
            Text(
              'View',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 21,
            ),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: kIsWeb
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: [
                  EventCard(
                    text1: 'E',
                    text2: 'Manage',
                    text3: 'Events',
                    color1: const Color.fromARGB(232, 213, 128, 115),
                    color2: const Color.fromARGB(232, 214, 70, 47),
                    circleColor: themeData.brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : const Color.fromARGB(206, 255, 255, 255),
                    onTap: () => Navigator.of(context).push(
                      CustomSlideTransition(
                        direction: AxisDirection.left,
                        child: ManageEventsScreen(
                            agencyName: agencyname!, token: widget.token),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  EventCard(
                    text1: 'M',
                    text2: 'Rescue',
                    text3: 'Map',
                    color1: const Color.fromARGB(223, 226, 168, 180),
                    color2: const Color.fromARGB(226, 215, 123, 140),
                    circleColor: themeData.brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : const Color.fromARGB(206, 255, 255, 255),
                    onTap: () => Navigator.of(context).push(
                      CustomSlideTransition(
                        direction: AxisDirection.left,
                        child: const RescueMapScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 21,
            ),
          ],
        ),
      ),
    );
  }
}
