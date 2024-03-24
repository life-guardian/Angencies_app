// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';

import 'package:agencies_app/functions/validate_textfield.dart';
import 'package:agencies_app/classes/exact_location.dart';
import 'package:agencies_app/providers/agencydetails_providers.dart';
import 'package:agencies_app/providers/location_provider.dart';
import 'package:agencies_app/screens/rescue_map_screen.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_osm_map_dialog.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_show_dialog.dart';
import 'package:agencies_app/small_widgets/custom_elevated_buttons/manage_elevated_button.dart';
import 'package:agencies_app/small_widgets/custom_textfields/text_form_field_modal.dart';
import 'package:agencies_app/small_widgets/custom_text_widgets/custom_text_widget.dart';
import 'package:agencies_app/transitions_animations/custom_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:http/http.dart' as http;

class RescueOperation extends ConsumerStatefulWidget {
  const RescueOperation({
    super.key,
    required this.token,
  });
  final token;

  @override
  ConsumerState<RescueOperation> createState() => _RescueOperationState();
}

class _RescueOperationState extends ConsumerState<RescueOperation> {
  TextEditingController operationNameController = TextEditingController();
  TextEditingController teamSizeController = TextEditingController();
  TextEditingController descController = TextEditingController();
  double? lat;
  double? lng;
  String? address;
  bool buttonEnabled = true;
  ExactLocation exactLocation = ExactLocation();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget activeButtonText = Text(
    'START',
    style: GoogleFonts.mulish(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
  );

  @override
  void dispose() {
    super.dispose();
    operationNameController.dispose();
    teamSizeController.dispose();
    descController.dispose();
  }

  void setButtonText() {
    activeButtonText = Text(
      'START',
      style: GoogleFonts.mulish(
          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
    );
  }

  Future<void> getDeviceLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ref.read(accessLiveLocationProvider.notifier).state = false;
        debugPrint("Location permission denied");
      }
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      lat = currentPosition.latitude;
      lng = currentPosition.longitude;
      ref.read(accessLiveLocationProvider.notifier).state = true;

      debugPrint(
          "Current Latitude: ${currentPosition.latitude.toString()} ,current Longitude: ${currentPosition.longitude.toString()}");
    }
  }

  void openMaps() async {
    PickedData pickedLocationData = await customOsmMapDialog(
        context: context, titleText: 'Select Location to send alert');
    lat = pickedLocationData.latLong.latitude;
    lng = pickedLocationData.latLong.longitude;
    try {
      address = await exactLocation.locality(lat: lat!, lng: lng!);
    } catch (e) {
      address = pickedLocationData
          .addressName; // if failed to fetch address then assign value from osm address
      debugPrint('Failed to fetch address: ${e.toString()}');
    }
    setState(() {});
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      startOperation();
    }
  }

  void startOperation() async {
    // code to send data to server setState(() {
    setState(() {
      buttonEnabled = false;
      activeButtonText = const Center(
        child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(),
        ),
      );
    });

    await getDeviceLocation();

    final jwtToken = widget.token;
    var serverMessage;
    bool hasAccessLiveLocation = ref.read(accessLiveLocationProvider);

    var reqBody = {
      "name": operationNameController.text,
      "description": descController.text,
      "latitude": lat,
      "longitude": lng,
      "rescueTeamSize": teamSizeController.text.toString()
    };

    if (hasAccessLiveLocation) {
      try {
        String baseUrl = dotenv.get("BASE_URL");

        var response = await http.post(
          Uri.parse('$baseUrl/api/rescueops/agency/start'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $jwtToken',
          },
          body: json.encode(reqBody),
        );

        var jsonResponse = jsonDecode(response.body);

        serverMessage = jsonResponse['message'];

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(serverMessage.toString()),
            ),
          );
          String? rescueId = await getRescueOperationDetails();
          ref.read(isRescueOperationOnGoingProvider.notifier).state = true;
          ref.read(rescueOperationIdProvider.notifier).state = rescueId;
          Navigator.of(context).pushReplacement(
            CustomSlideTransition(
              direction: AxisDirection.left,
              child: const RescueMapScreen(),
            ),
          );
        } else {
          setState(() {
            setButtonText();
          });

          customShowDialog(
            context: context,
            titleText: 'Something went wrong',
            contentText: serverMessage.toString(),
          );
        }
      } catch (e) {
        setState(() {
          setButtonText();
        });

        debugPrint("Exception occured: ${e.toString()}");
      }
    } else {
      customShowDialog(
        context: context,
        titleText: 'Please give access to location to start the operation',
        contentText: serverMessage.toString(),
      );
    }

    buttonEnabled = true;
  }

  Future<String?> getRescueOperationDetails() async {
    var baseUrl = dotenv.get("BASE_URL");

    var response = await http.get(
      Uri.parse('$baseUrl/api/rescueops/agency/isongoing'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    debugPrint("Status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse["rescueOpsId"];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 12,
        left: 12,
        right: 12,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTextWidget(
                text: 'Start Rescue Operation',
                fontSize: 20,
              ),
              const SizedBox(
                height: 31,
              ),
              const CustomTextWidget(
                text: 'RESCUE OPERATION NAME',
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormFieldModal(
                hintText: 'Enter Rescue operation name',
                controller: operationNameController,
                checkValidation: (value) =>
                    validateTextField(value, 'Operation Name'),
              ),
              const SizedBox(
                height: 21,
              ),
              const CustomTextWidget(
                text: 'RESCUE TEAM SIZE',
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormFieldModal(
                keyboardType: TextInputType.number,
                hintText: 'Enter rescue team size',
                controller: teamSizeController,
                checkValidation: (value) =>
                    validateTextField(value, 'Team Size'),
              ),
              const SizedBox(
                height: 21,
              ),
              const CustomTextWidget(
                text: 'DESCRIPTION',
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormFieldModal(
                hintText: 'Enter description',
                controller: descController,
                checkValidation: (value) =>
                    validateTextField(value, 'Description'),
              ),
              const SizedBox(
                height: 21,
              ),
              const SizedBox(
                height: 31,
              ),
              ManageElevatedButton(
                buttonItem: activeButtonText,
                onButtonClick: buttonEnabled ? _submitForm : () {},
              ),
              const SizedBox(
                height: 31,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
