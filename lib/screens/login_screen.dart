// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:agencies_app/constants/sizes.dart';
import 'package:agencies_app/functions/validate_textfield.dart';
import 'package:agencies_app/screens/tabs.dart';
import 'package:agencies_app/small_widgets/custom_dialogs/custom_show_dialog.dart';
import 'package:agencies_app/screens/register_screen.dart';
import 'package:agencies_app/transitions_animations/custom_page_transition.dart';
import 'package:agencies_app/small_widgets/custom_textfields/text_form_field_login_register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController agencyLoginEmail = TextEditingController();
  TextEditingController agencyPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool buttonPressed = false;
  Widget activeButtonWidget = const Text('Login');
  bool buttonEnabled = true;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPrefs();
  }

  @override
  void dispose() {
    super.dispose();
    agencyLoginEmail.dispose();
    agencyPassword.dispose();
  }

  void initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _goToRegisterPage() {
    Navigator.of(context).pushReplacement(
      CustomSlideTransition(
        direction: AxisDirection.up,
        child: const RegisterScreen(),
      ),
    );
  }

  void _navigateToHomeScreen(final myToken) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => TabsBottom(myToken: myToken),
      ),
    );
  }

  void _submitButton() {
    if (_formKey.currentState!.validate()) {
      if (!buttonPressed) {
        buttonPressed = true;
        _loginUser();
      }
    }
  }

  void _loginUser() async {
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

    var reqBody = {
      "username": agencyLoginEmail.text,
      "password": agencyPassword.text,
    };

    String serverMessage;

    var baseUrl = dotenv.get("BASE_URL");

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/api/agency/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      // print(response.statusCode);
      // var jsonResponse = jsonDecode(response.body);
      var jsonResponse = jsonDecode(response.body);
      serverMessage = jsonResponse['message'];

      if (response.statusCode == 200) {
        //storin user login data in local variable
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);

        // Navigator.of(context).pop();
        _navigateToHomeScreen(myToken);
        //success
      } else {
        // something went wrong
        setState(() {
          activeButtonWidget = const Text('Login');
        });

        buttonPressed = await customShowDialog(
          context: context,
          titleText: 'Ooops!',
          contentText: serverMessage.toString(),
        );
      }
    } catch (error) {
      debugPrint("Error occured while logging in: ${error.toString()}");
    }

    setState(() {
      buttonEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    bool kIsMobile = (screenWidth <= mobileScreenWidth);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/images/disasterImage2.jpg'),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Life Guardian',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      shadows: const [
                        Shadow(
                          offset: Offset(0.0, 7.0),
                          blurRadius: 15.0,
                          color: Color.fromARGB(57, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'For Agencies',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      shadows: const [
                        Shadow(
                          offset: Offset(0.0, 7.0),
                          blurRadius: 15.0,
                          color: Color.fromARGB(57, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 31,
                  ),
                  Text(
                    'Welcome back! Glad to see you, team!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 31,
                  ),
                  SizedBox(
                    width: !kIsMobile ? screenWidth / 2 : null,
                    child: TextFormFieldLoginRegister(
                      labelText: 'Email / Phone',
                      controllerText: agencyLoginEmail,
                      checkValidation: (value) =>
                          validateTextField(value, 'Email / Phone'),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: !kIsMobile ? screenWidth / 2 : null,
                    child: TextFormFieldLoginRegister(
                      labelText: 'Password',
                      controllerText: agencyPassword,
                      checkValidation: (value) =>
                          validateTextField(value, 'Password'),
                      obsecureIcon: true,
                      hideText: true,
                    ),
                  ),
                  const SizedBox(
                    height: 42,
                  ),
                  SizedBox(
                    width: !kIsMobile ? screenWidth / 4 : double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: buttonEnabled ? _submitButton : () {},
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
                          'Don\'t have an account?',
                          style: TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: _goToRegisterPage,
                          child: const Text(
                            'Register Now',
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
            ),
          ),
        ),
      ),
    );
  }
}
