// ignore_for_file: library_prefixes, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:agencies_app/models/active_locations.dart';
import 'package:agencies_app/functions/modal_bottom_sheet.dart';
import 'package:agencies_app/providers/agencydetails_providers.dart';
import 'package:agencies_app/providers/location_provider.dart';
import 'package:agencies_app/small_widgets/custom_elevated_buttons/manage_elevated_button.dart';
import 'package:agencies_app/small_widgets/custom_text_widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RescueMapScreen extends ConsumerStatefulWidget {
  const RescueMapScreen({
    super.key,
  });

  @override
  ConsumerState<RescueMapScreen> createState() => _RescueMapScreenState();
}

class _RescueMapScreenState extends ConsumerState<RescueMapScreen> {
  ModalBottomSheet modalBottomSheet = ModalBottomSheet();

  late IO.Socket socket;
  late String token;
  bool isSocketDisconnected = false;
  StreamSubscription<Position>? positionStreamSubscription;
  late bool isRescueOnGoing;
  String? rescueId;

  late List<double> latLng;
  List<LiveAgencies> liveAgencies = [];

  @override
  void initState() {
    super.initState();
    getRescueDetailsLocal();
    connectSocket();
  }

  void getRescueDetailsLocal() {
    if (mounted) {
      isRescueOnGoing = ref.read(isRescueOperationOnGoingProvider);
      rescueId = ref.read(rescueOperationIdProvider);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (positionStreamSubscription != null) {
      positionStreamSubscription!.cancel();
    }
    disconnectSocket();
  }

  void openModalBottomSheet({required LiveAgencies liveAgency}) {
    modalBottomSheet.openModal(
      context: context,
      widget: markerPointDetails(liveAgency: liveAgency),
    );
  }

  void connectSocket() {
    if (mounted) {
      token = ref.read(tokenProvider);
    }
    var baseUrl = dotenv.get("BASE_URL");
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $token'}
    });
    // gets and sends details for intial connect
    socket.connect();
    socket.onConnect((data) async {
      debugPrint("Socket Connected");
      await initialConnectGetSendDetails();
      listenSocketOn();
      startTrackingLocation();
    });
  }

  void disconnectSocket() async {
    socket.disconnect();
    socket.onDisconnect((data) {
      debugPrint("Socket Dissconnected");
    });
  }

  void listenSocketOn() {
    socket.on("agencyLocationUpdate", (data) {
      if (mounted) {
        debugPrint("Got agency");
        debugPrint(data.toString());
        bool isPlotted = false;
        for (int i = 0; i < liveAgencies.length; i++) {
          if (liveAgencies[i].agencyId == data["agencyId"]) {
            liveAgencies[i].lat = data["lat"];
            liveAgencies[i].lng = data["lng"];
            liveAgencies[i].rescueOpsName = data[""];
            isPlotted = true;
          }
        }
        setState(() {
          if (!isPlotted) {
            liveAgencies.add(LiveAgencies.fromJson(data));
          }
        });
      }
    });

    socket.on("disconnected", (disconnectedAgencyId) {
      debugPrint("Agency id disconnected $disconnectedAgencyId");

      if (mounted) {
        for (int i = 0; i < liveAgencies.length; i++) {
          if (liveAgencies[i].agencyId == disconnectedAgencyId) {
            liveAgencies.remove(liveAgencies[i]);
            break;
          }
        }
        setState(() {});
      }
    });
  }

  void startTrackingLocation() async {
    LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      geo.LocationSettings locationSettings = const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10,
      );
      positionStreamSubscription = geo.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        if (mounted) {
          ref.read(deviceLocationProvider.notifier).state = [
            position.latitude,
            position.longitude
          ];
          emitLocationUpdate(position.latitude, position.longitude);
        }
      });
    } else {
      debugPrint("Location permission denied - cannot track location.");
    }
  }

  void emitLocationUpdate(double latitude, double longitude) {
    socket.emit('agencyLocationUpdate', {'lat': latitude, 'lng': longitude});
  }

  Future<void> initialConnectGetSendDetails() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permission denied");
      }
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        ref.read(deviceLocationProvider.notifier).state = [
          currentPosition.latitude,
          currentPosition.longitude
        ];
        debugPrint("Initial lat ${latLng[0]} and lng: ${latLng[1]}");

        await getInitialConnectAgenciesUsersLocation();
      }
    }
    return;
  }

  Future<void> getInitialConnectAgenciesUsersLocation() async {
    var baseUrl = dotenv.get("BASE_URL");

    try {
      var response = await http.get(
        Uri.parse(
          "$baseUrl/api/rescueops/initialconnect/${latLng[0]}/${latLng[1]}",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        final initialAgencies = jsonResponse["agencies"];
        debugPrint("Got initial connect agency");
        debugPrint(initialAgencies.toString());

        for (var liveAgency in initialAgencies) {
          liveAgencies.add(LiveAgencies.fromJson(liveAgency));
        }
        if (mounted) {
          setState(() {});
        }
      }
    } catch (error) {
      debugPrint(
          "Error while fetching intial connect agencies and user ${error.toString()}");
    }

    return;
  }

  Future<void> launchPhoneDial({required int phoneNo}) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNo.toString(),
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Cannot launch phoneCall url");
    }
  }

  void stopRescueOperation({required String rescueOpsId}) async {
    var baseUrl = dotenv.get("BASE_URL");

    var response = await http.put(
      Uri.parse('$baseUrl/api/rescueops/agency/stop/$rescueOpsId'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      if (mounted) {
        ref.read(isRescueOperationOnGoingProvider.notifier).state = false;
        ref.read(rescueOperationIdProvider.notifier).state = null;
      }
      String serverMessage = '';
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(serverMessage.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mounted) {
      latLng = ref.watch(deviceLocationProvider);
    }
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(latLng[0], latLng[1]),
              zoom: 12,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              openStreetMapTileLayer,
              MarkerLayer(
                markers: [
                  // Marker of this device
                  Marker(
                    point: LatLng(latLng[0], latLng[1]),
                    width: 60,
                    height: 60,
                    rotateAlignment: Alignment.centerLeft,
                    builder: (
                      context,
                    ) {
                      return Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                                "assets/images/rescue_map/selfAgency.PNG"),
                          ),
                          const CustomTextWidget(
                            text: "Me",
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ],
                      );
                    },
                  ),

                  for (var liveAgency in liveAgencies)
                    Marker(
                      point: LatLng(liveAgency.lat!, liveAgency.lng!),
                      width: 60,
                      height: 60,
                      rotateAlignment: Alignment.centerLeft,
                      builder: (
                        context,
                      ) {
                        return GestureDetector(
                          onTap: () {
                            openModalBottomSheet(liveAgency: liveAgency);
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  liveAgency.rescueOpsName == null
                                      ? "assets/images/rescue_map/agencySpying.PNG"
                                      : "assets/images/rescue_map/agencyRescuing.PNG",
                                ),
                              ),
                              Flexible(
                                child: CustomTextWidget(
                                  text: liveAgency.agencyName ?? "",
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          if (isRescueOnGoing)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: ManageElevatedButton(
                buttonItem: Text(
                  'Stop Operation'.toUpperCase(),
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                onButtonClick: () {
                  stopRescueOperation(rescueOpsId: rescueId!);
                },
                enabled: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget markerPointDetails({required LiveAgencies liveAgency}) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        left: 12,
        right: 12,
        bottom: 5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            liveAgency.rescueOpsName == null
                ? 'Agency Details'
                : 'Rescue Operation Started',
            style: GoogleFonts.mulish().copyWith(
              fontWeight: FontWeight.bold,
              color:
                  liveAgency.rescueOpsName == null ? Colors.blue : Colors.green,
              fontSize: 21,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agency Name'.toUpperCase(),
                      style: GoogleFonts.mulish().copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      liveAgency.agencyName!,
                      style: GoogleFonts.mulish().copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Representative Name'.toUpperCase(),
                      style: GoogleFonts.mulish().copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      liveAgency.representativeName!,
                      style: GoogleFonts.mulish().copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                if (liveAgency.rescueOpsName != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rescue Operation Name'.toUpperCase(),
                        style: GoogleFonts.mulish().copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        liveAgency.rescueOpsName!,
                        style: GoogleFonts.mulish().copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (liveAgency.rescueOpsName != null)
                  const SizedBox(
                    height: 8,
                  ),
                if (liveAgency.rescueOpsDescription != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description'.toUpperCase(),
                        style: GoogleFonts.mulish().copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        liveAgency.rescueOpsDescription!,
                        style: GoogleFonts.mulish().copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (liveAgency.rescueOpsName != null)
                  const SizedBox(
                    height: 8,
                  ),
                if (liveAgency.rescueTeamSize != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rescue Team Size'.toUpperCase(),
                        style: GoogleFonts.mulish().copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        liveAgency.rescueTeamSize!.toString(),
                        style: GoogleFonts.mulish().copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (liveAgency.rescueOpsName != null)
                  const SizedBox(
                    height: 8,
                  ),

                Row(
                  children: [
                    const Icon(
                      Icons.star_border_outlined,
                      size: 30,
                      color: Colors.blue,
                    ),
                    const SizedBox(
                      width: 11,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agency Phone'.toUpperCase(),
                          style: GoogleFonts.mulish().copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          liveAgency.phoneNumber.toString(),
                          style: GoogleFonts.mulish().copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // const Divider(thickness: 0.2),
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          await launchPhoneDial(
                            phoneNo: liveAgency.phoneNumber!,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundColor: const Color(0xff1E232C),
                        ),
                        child: const Text(
                          'CALL',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
