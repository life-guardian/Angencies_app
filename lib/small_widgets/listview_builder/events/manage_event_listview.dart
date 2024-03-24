// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';

import 'package:agencies_app/providers/manage_events_provider.dart';
import 'package:agencies_app/screens/event_registered_users_screen.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_logout_dialog.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_show_dialog.dart';
import 'package:agencies_app/transitions_animations/custom_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class BuildManageEventListView extends StatefulWidget {
  const BuildManageEventListView({
    super.key,
    required this.ref,
    required this.token,
    required this.agencyName,
  });

  final WidgetRef ref;
  final token;
  final String agencyName;

  @override
  State<BuildManageEventListView> createState() =>
      _BuildManageEventListViewState();
}

class _BuildManageEventListViewState extends State<BuildManageEventListView> {
  @override
  void initState() {
    super.initState();
  }

  void deleteEvent({required String id, required int index}) async {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    String baseUrl = dotenv.get("BASE_URL");

    var response = await http.delete(
      Uri.parse('$baseUrl/api/event/agency/cancel/$id'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${widget.token}'
      },
    );

    var jsonResponse = jsonDecode(response.body);

    String message = jsonResponse['message'];

    if (response.statusCode == 200) {
      setState(() {
        Navigator.of(context).pop();
        widget.ref.read(manageEventsProvider.notifier).removeAt(id: id);
        // widget.eventList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } else {
      customShowDialog(
          context: context,
          titleText: 'Something went wrong',
          contentText: message);
    }
  }

  void navigateToRegisteredUsers({required String id}) {
    Navigator.of(context).push(
      CustomSlideTransition(
        direction: AxisDirection.left,
        child: EventRegisteredUsersScreen(
          token: widget.token,
          agencyName: widget.agencyName,
          eventId: id.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final eventList = widget.ref.watch(manageEventsProvider);
    return eventList.isEmpty
        ? const Center(
            child: Text(
              "Sorry No Data found!",
            ),
          )
        : ListView.builder(
            itemCount: eventList.length,
            itemBuilder: (context, index) {
              final eventData = eventList.elementAt(index);
              return InkWell(
                onTap: () {
                  navigateToRegisteredUsers(id: eventData.eventId.toString());
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventData.eventName.toString(),
                                style: GoogleFonts.plusJakartaSans().copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                // code here to show exact location
                                eventData.locality.toString(),
                                style: GoogleFonts.plusJakartaSans().copyWith(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                DateFormat('dd/MM/yy').format(DateTime.parse(
                                    eventData.eventDate.toString())),
                                style: GoogleFonts.plusJakartaSans().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: (themeData.brightness ==
                                          Brightness.light)
                                      ? const Color.fromARGB(255, 224, 28, 14)
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(224, 210, 85, 74),
                                Color.fromARGB(210, 228, 53, 37)
                              ],
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              customLogoutDialog(
                                  context: context,
                                  titleText: 'Confirm Delete !',
                                  onTap: () {
                                    // delete from server
                                    deleteEvent(
                                        id: eventData.eventId.toString(),
                                        index: index);
                                  },
                                  actionText2: 'Yes',
                                  contentText:
                                      'Deleting an event cancels all registrations. This action cannot be undone.');
                            },
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
