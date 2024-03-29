// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';

import 'package:agencies_app/custom_functions/validate_textfield.dart';
import 'package:agencies_app/large_widgets/map_widgets/exact_location.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_google_maps_dialog.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_show_dialog.dart';
import 'package:agencies_app/small_widgets/custom_elevated_buttons/manage_elevated_button.dart';
import 'package:agencies_app/small_widgets/custom_textfields/select_map_location_field.dart';
import 'package:agencies_app/small_widgets/custom_textfields/textfield_modal.dart';
import 'package:agencies_app/small_widgets/custom_text_widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:http/http.dart' as http;

class RescueOperation extends StatefulWidget {
  const RescueOperation({
    super.key,
    required this.token,
  });
  final token;

  @override
  State<RescueOperation> createState() => _RescueOperationState();
}

class _RescueOperationState extends State<RescueOperation> {
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

  void openMaps() async {
    PickedData pickedLocationData = await customGoogleMapsDialog(
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
      if (address == null) {
        customShowDialog(
            context: context,
            titleText: 'Something went wrong',
            contentText:
                'Please check that you have proper inputed operation location.');
      } else {
        startOperation();
      }
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

    final jwtToken = widget.token;
    var serverMessage;

    var reqBody = {
      "name": operationNameController.text,
      "description": descController.text,
      "latitude": lat,
      "longitude": lng,
      "rescueTeamSize": teamSizeController.text.toString()
    };

    try {
                            String rescueOperationUrl = dotenv.get("rescueOperationUrl");

      var response = await http.post(
        Uri.parse(rescueOperationUrl),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);

      serverMessage = jsonResponse['message'];

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverMessage.toString()),
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

    buttonEnabled = true;
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
                text: 'OPERATION LOCATION',
              ),
              const SizedBox(
                height: 5,
              ),
              SelectMapLocationField(
                onTap: openMaps,
                address: address,
                initialText: 'Give precise location access',
              ),
              const SizedBox(
                height: 21,
              ),
              const CustomTextWidget(
                text: 'RESCUE OPERATION NAME',
              ),
              const SizedBox(
                height: 5,
              ),
              TextfieldModal(
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
              TextfieldModal(
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
              TextfieldModal(
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
