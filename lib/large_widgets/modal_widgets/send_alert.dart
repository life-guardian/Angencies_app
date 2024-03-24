// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:agencies_app/functions/validate_textfield.dart';
import 'package:agencies_app/classes/exact_location.dart';
import 'package:agencies_app/small_widgets/custom_elevated_buttons/manage_elevated_button.dart';
import 'package:agencies_app/functions/datepicker_function.dart';
import 'package:agencies_app/small_widgets/custom_textfields/select_map_location_field.dart';
import 'package:agencies_app/small_widgets/custom_textfields/text_form_field_modal.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_osm_map_dialog.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_show_dialog.dart';
import 'package:agencies_app/small_widgets/custom_text_widgets/custom_text_widget.dart';
import 'package:agencies_app/small_widgets/custom_textfields/text_in_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class SendAlert extends StatefulWidget {
  const SendAlert({super.key, required this.token});
  final token;

  @override
  State<SendAlert> createState() => _SendAlertState();
}

class _SendAlertState extends State<SendAlert> {
  String? dropDownValue;
  bool isPickeddropDownValue = false;
  DateTime? _selectedDate;
  final formatter = DateFormat.yMd();
  TextEditingController alertNameController = TextEditingController();
  double? lat;
  double? lng;
  String? address;
  bool buttonEnabled = true;
  bool dateSelected = false;
  ExactLocation exactLocation = ExactLocation();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget activeButtonText = Text(
    'SEND ALERT',
    style: GoogleFonts.mulish(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
  );

  @override
  void dispose() {
    super.dispose();
    alertNameController.dispose();
  }

  void _presentDatePicker(BuildContext context) async {
    _selectedDate = await customDatePicker(context);
    if (!(_selectedDate == null)) {
      dateSelected = true;
    }
    setState(() {});
  }

  void setButtonText() {
    activeButtonText = Text(
      'SEND ALERT',
      style: GoogleFonts.mulish(
          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
    );
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
      if (address == null || _selectedDate == null || !isPickeddropDownValue) {
        customShowDialog(
            context: context,
            titleText: 'Something went wrong',
            contentText:
                'Please check that you have proper inputed alerting area, alert severity and date.');
      } else {
        _sendAlert();
      }
    }
  }

  Future<void> _sendAlert() async {
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
      "locationCoordinates": [lng, lat],
      "alertName": alertNameController.text.toString(),
      "alertSeverity": dropDownValue.toString().toLowerCase(),
      "alertForDate": _selectedDate.toString(),
    };

    try {
      String baseUrl = dotenv.get("BASE_URL");

      var response = await http.post(
        Uri.parse('$baseUrl/api/alert/agency/sendalert'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode(reqBody),
      );

      // var jsonResponse = jsonDecode(response.body);
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
            contentText: serverMessage.toString());
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
    List<String> values = ['High', 'Medium', 'Low'];
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
                text: 'Send Emergency Alert',
                fontSize: 20,
              ),
              const SizedBox(
                height: 31,
              ),
              const CustomTextWidget(
                text: 'ALERTING AREA',
              ),
              const SizedBox(
                height: 5,
              ),
              SelectMapLocationField(
                onTap: openMaps,
                address: address,
                initialText:
                    'Area will be in radius of 2 km from the location point.',
              ),
              const SizedBox(
                height: 21,
              ),
              const CustomTextWidget(
                text: 'ALERT NAME',
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormFieldModal(
                hintText: 'Fire and Safety Drill',
                controller: alertNameController,
                checkValidation: (value) =>
                    validateTextField(value, 'Alert Name'),
              ),
              const SizedBox(
                height: 21,
              ),
              const CustomTextWidget(
                text: 'ALERT SEVERITY',
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    // width: 2,
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextInTextField(
                        selectedText: dropDownValue,
                        initialText: 'Select Severty',
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          underline: null,
                          iconSize: 35,
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
                              isPickeddropDownValue = true;

                              dropDownValue = newValue!;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 21,
              ),
              const CustomTextWidget(
                text: 'DATE',
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  _presentDatePicker(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      // width: 2,
                      color: Colors.grey,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextInTextField(
                          selectedText: (_selectedDate == null)
                              ? null
                              : formatter.format(_selectedDate!),
                          initialText: 'Pick Date',
                        ),
                        const SizedBox(
                          width: 11,
                        ),
                        const Icon(Icons.calendar_month_outlined),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 31,
              ),
              ManageElevatedButton(
                buttonItem: activeButtonText,
                onButtonClick: _submitForm,
                enabled: buttonEnabled,
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
