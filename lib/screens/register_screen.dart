// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:agencies_app/constants/sizes.dart';
import 'package:agencies_app/screens/login_screen.dart';
import 'package:agencies_app/screens/register_succesful.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_show_dialog.dart';
import 'package:agencies_app/transitions_animations/custom_page_transition.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:agencies_app/small_widgets/custom_textfields/text_form_field_login_register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;

  TextEditingController agencyName = TextEditingController();
  TextEditingController agencyEmail = TextEditingController();
  TextEditingController agencyPhone = TextEditingController();
  TextEditingController agencyAddress = TextEditingController();
  TextEditingController representativeName = TextEditingController();
  TextEditingController agencyPassword = TextEditingController();
  TextEditingController agencyConfirmPassword = TextEditingController();
  bool registeredButtonPressed = false;
  bool buttonEnabled = true;
  Widget activeButtonWidget = const Text('Register');

  @override
  void initState() {
    super.initState();
    initSharedPrefs();
  }

  @override
  void dispose() {
    super.dispose();
    agencyName.dispose();
    agencyEmail.dispose();
    agencyPhone.dispose();
    agencyAddress.dispose();
    representativeName.dispose();
    agencyPassword.dispose();
    agencyConfirmPassword.dispose();
  }

  void popScreen() {
    Navigator.of(context).pop();
  }

  void initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void goToLoginPage() {
    Navigator.of(context).pushReplacement(
      CustomSlideTransition(
        direction: AxisDirection.up,
        child: const LoginScreen(),
      ),
    );
  }

  String? validateEmail(value, String? label) {
    if (value.isEmpty) {
      return 'Please enter an $label';
    }
    RegExp emailRegx = RegExp(r'^.+@[a-zA-Z]+\.[a-zA-Z]+$');
    if (!emailRegx.hasMatch(value)) {
      return 'Please enter a valid $label';
    }
    return null;
  }

  String? validatePhoneNo(value, String? label) {
    var no = int.tryParse(value);
    if (no == null) {
      return 'Please enter a valid $label';
    }
    if (value.isEmpty) {
      return 'Please enter a $label';
    }
    if (value.length != 10) {
      return 'Please enter a 10-digit $label';
    }
    return null;
  }

  String? validateTextField(value, String? label) {
    if (value.isEmpty) {
      return 'Please enter a $label';
    }
    return null;
  }

  String? validatePassword(value, String? label) {
    if (value.isEmpty) {
      return 'Please enter a $label';
    }
    if (value.length < 8 || value.length > 16) {
      return 'Please enter $label between 8 to 16 digits';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).*$').hasMatch(value)) {
      return 'Password must contains at least one upper case, lower case, number & special symbol';
    }

    return null;
  }

  String? validateConfirmPassword(value, String? label) {
    if (value.isEmpty) {
      return 'Please enter a $label';
    }
    String agPass = agencyPassword.text.toString();
    if (agPass != value.toString()) {
      return 'Password and confirm password did\'t match';
    }

    return null;
  }

  String? validateName(value, String? label) {
    var no = int.tryParse(value);
    if (no != null) {
      return 'Please enter a valid $label';
    }
    if (value.isEmpty) {
      return 'Please enter a $label';
    }
    return null;
  }

  void registerUser() async {
    //check validation of texts

    setState(() {
      buttonEnabled = false;
      activeButtonWidget = const Center(
        child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(),
        ),
      );
    });

    String serverMessage;

    var regBody = {
      "agencyName": agencyName.text.toString(),
      "agencyPhNo": agencyPhone.text.toString(),
      "agencyEmail": agencyEmail.text.toString(),
      "password": agencyPassword.text.toString(),
      "address": agencyAddress.text.toString(),
      "representativeName": representativeName.text.toString(),
    };

    String baseUrl = dotenv.get("BASE_URL");

    var response = await http.post(
      Uri.parse('$baseUrl/api/agency/register'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(regBody),
    );

    var jsonResponse = jsonDecode(response.body);
    serverMessage = jsonResponse['message'];

    if (response.statusCode == 200) {
      var myToken = jsonResponse['token'];
      prefs.setString('token', myToken);
      Navigator.of(context).pushReplacement(
        CustomSlideTransition(
          direction: AxisDirection.left,
          child: RegisterSuccessfullScreen(token: myToken),
        ),
      );
    } else {
      setState(() {
        activeButtonWidget = const Text('Register');
      });

      registeredButtonPressed = await customShowDialog(
        context: context,
        titleText: 'Something went wrong!',
        contentText: serverMessage.toString(),
      );
      registeredButtonPressed = false;
    }
    buttonEnabled = true;
  }

  void submitForm() {
    if (formKey.currentState!.validate()) {
      if (!registeredButtonPressed) {
        registeredButtonPressed = true;
        registerUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool kIsMobile = (screenWidth <= mobileScreenWidth);

    return Scaffold(
      resizeToAvoidBottomInset: kIsMobile ? true : false,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              foregroundColor: (themeData.brightness == Brightness.light)
                  ? const Color.fromARGB(185, 30, 35, 44)
                  : const Color(0xffe1dcd3),
              side: BorderSide(
                color: (themeData.brightness == Brightness.light)
                    ? const Color.fromARGB(32, 30, 35, 44)
                    : const Color(0xffE1DCD3),
              ),
            ),
            onPressed: popScreen,
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: !kIsMobile
            ? SingleChildScrollView(
                child: registerScreenWidget(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    kIsMobile: kIsMobile),
              )
            : registerScreenWidget(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                kIsMobile: kIsMobile,
              ),
      ),
    );
  }

  Widget registerScreenWidget(
      {required double screenHeight,
      required double screenWidth,
      required bool kIsMobile}) {
    return SizedBox(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello! Register agency to get started',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(
            height: 21,
          ),
          kIsMobile
              ? Expanded(
                  child: registerScreenFormWidget(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    kIsMobile: kIsMobile,
                  ),
                )
              : registerScreenFormWidget(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  kIsMobile: kIsMobile,
                ),
          !kIsMobile
              ? const SizedBox(
                  height: 91,
                )
              : const SizedBox(
                  height: 11,
                ),
          SizedBox(
            width: !kIsMobile
                ? screenWidth / 4
                : MediaQuery.of(context).size.width,
            height: 55,
            child: ElevatedButton(
              onPressed: buttonEnabled ? submitForm : () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: activeButtonWidget,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: goToLoginPage,
                  child: const Text(
                    'Login Now',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
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

  Widget registerScreenFormWidget(
      {required double screenHeight,
      required double screenWidth,
      required bool kIsMobile}) {
    return SizedBox(
      height: screenHeight / 2,
      child: SingleChildScrollView(
        child: SizedBox(
          width: !kIsMobile ? screenWidth / 2 : null,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormFieldLoginRegister(
                  labelText: 'Agency Name',
                  controllerText: agencyName,
                  checkValidation: (value) => validateName(value, 'Name'),
                ),
                const SizedBox(
                  height: 21,
                ),
                TextFormFieldLoginRegister(
                  labelText: 'Agency Email',
                  controllerText: agencyEmail,
                  checkValidation: (value) => validateEmail(value, 'Email'),
                ),
                const SizedBox(
                  height: 21,
                ),
                TextFormFieldLoginRegister(
                  labelText: 'Agency Ph No',
                  controllerText: agencyPhone,
                  checkValidation: (value) =>
                      validatePhoneNo(value, 'Phone Number'),
                ),
                const SizedBox(
                  height: 21,
                ),
                TextFormFieldLoginRegister(
                  labelText: 'Agency Address',
                  controllerText: agencyAddress,
                  checkValidation: (value) =>
                      validateTextField(value, 'Address'),
                ),
                const SizedBox(
                  height: 21,
                ),
                TextFormFieldLoginRegister(
                  labelText: 'Representative Name',
                  controllerText: representativeName,
                  checkValidation: (value) =>
                      validateName(value, 'Representative name'),
                ),
                const SizedBox(
                  height: 21,
                ),
                TextFormFieldLoginRegister(
                  labelText: 'Password',
                  controllerText: agencyPassword,
                  checkValidation: (value) =>
                      validatePassword(value, 'Password'),
                  hideText: true,
                ),
                const SizedBox(
                  height: 21,
                ),
                TextFormFieldLoginRegister(
                  labelText: 'Confirm Password',
                  controllerText: agencyConfirmPassword,
                  checkValidation: (value) =>
                      validateConfirmPassword(value, 'Confirm Password'),
                  hideText: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
