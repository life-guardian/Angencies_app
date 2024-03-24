// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, no_logic_in_create_state
import 'dart:convert';

import 'package:agencies_app/constants/sizes.dart';
import 'package:agencies_app/providers/agencydetails_providers.dart';
import 'package:agencies_app/providers/alert_history_provider.dart';
import 'package:agencies_app/providers/event_history_provider.dart';
import 'package:agencies_app/providers/location_provider.dart';
import 'package:agencies_app/providers/manage_events_provider.dart';
import 'package:agencies_app/providers/rescue_history_provider.dart';
import 'package:agencies_app/screens/home_screen.dart';
import 'package:agencies_app/screens/login_screen.dart';
import 'package:agencies_app/screens/user_account_details.dart';
import 'package:agencies_app/screens/welcome_screen.dart';
import 'package:agencies_app/small_widgets/custom_text_widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TabsBottom extends ConsumerStatefulWidget {
  const TabsBottom({super.key, this.myToken});
  final myToken;

  @override
  ConsumerState<TabsBottom> createState() => _TabsBottomState();
}

class _TabsBottomState extends ConsumerState<TabsBottom> {
  bool dataLoaded = false;
  late SharedPreferences prefs;
  Widget activePage = const Center(
    child: CircularProgressIndicator(
      color: Colors.grey,
    ),
  );
  int _currentIndx = 0;
  double _screenWidth = 0;

  @override
  void initState() {
    super.initState();
    getDeviceLocation();
    addTokenProvider();
  }

  Future<void> getRescueOperationDetails() async {
    var baseUrl = dotenv.get("BASE_URL");

    var response = await http.get(
      Uri.parse('$baseUrl/api/rescueops/agency/isongoing'),
      headers: {"Authorization": "Bearer ${widget.myToken}"},
    );

    debugPrint("Status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      ref.read(isRescueOperationOnGoingProvider.notifier).state =
          jsonResponse["isRescueOperationOnGoing"];
      ref.read(rescueOperationIdProvider.notifier).state =
          jsonResponse["rescueOpsId"];
    }

    return;
  }

  void addTokenProvider() {
    Future.delayed(const Duration(seconds: 3), () {
      ref.read(tokenProvider.notifier).state = widget.myToken;
    });
  }

  void onSelectedTab(int index) {
    setState(
      () {
        _currentIndx = index;
      },
    );
  }

  Future<void> getDeviceLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permission denied");
      }
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      ref.read(deviceLocationProvider.notifier).state = [
        currentPosition.latitude,
        currentPosition.longitude
      ];

      debugPrint(
          "Current Latitude: ${currentPosition.latitude.toString()} ,current Longitude: ${currentPosition.longitude.toString()}");
    }

    await getRescueOperationDetails();

    setState(() {
      dataLoaded = true;
    });
  }

  void cleanAllProviders() {
    // resetting all the provider when logging out
    ref.read(agencyNameProvider.notifier).state = "Loading...";
    ref.read(eventsCountProvider.notifier).state = ['0', '0'];
    ref.read(alertHistoryProvider.notifier).reset();
    ref.read(eventHistoryProvider.notifier).reset();
    ref.read(manageEventsProvider.notifier).reset();
    ref.read(rescueHistoryProvider.notifier).reset();
  }

  void _logoutUser() async {
    showDialog(
      context: context,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          color: Colors.grey,
        ),
      ),
    );

    prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

    // reset all provider to intial state
    cleanAllProviders();

    while (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const WelcomeScreen(),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const LoginScreen(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        // content: Text(message),
        content: Text("Logged out succesfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    if (dataLoaded) {
      if (_currentIndx == 1) {
        activePage = UserAccountDetails(
          logoutUser: _logoutUser,
        );
      } else if (_currentIndx == 0) {
        activePage = HomeScreen(token: widget.myToken);
      }
    }

    return Scaffold(
      body: _screenWidth > mobileScreenWidth
          ? activeScreenWeb(context: context)
          : SafeArea(
              child: activeScreen(),
            ),
      bottomNavigationBar: _screenWidth > mobileScreenWidth || !dataLoaded
          ? null
          : Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  unselectedItemColor: const Color.fromARGB(175, 158, 158, 158),
                  currentIndex: _currentIndx,
                  iconSize: 25,
                  onTap: onSelectedTab,
                  elevation: 5,
                  selectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      activeIcon: Icon(Icons.account_circle_rounded),
                      label: 'Account',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget activeScreenWeb({required BuildContext context}) {
    return Row(
      children: [
        navigationBarWeb(context: context),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: activeScreen(),
          ),
        ),
      ],
    );
  }

  Widget navigationBarWeb({required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndx = 0;
                      });
                    },
                    icon: Icon(
                      _currentIndx == 0
                          ? Icons.home_rounded
                          : Icons.home_outlined,
                      color: Colors.grey,
                      size: _currentIndx == 0 ? 50 : 40,
                    ),
                  ),
                  const CustomTextWidget(
                    text: "Home",
                    color: Colors.grey,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentIndx = 1;
                      });
                    },
                    icon: Icon(
                      _currentIndx == 0
                          ? Icons.account_circle_outlined
                          : Icons.account_circle_rounded,
                      color: Colors.grey,
                      size: _currentIndx == 1 ? 50 : 40,
                    ),
                  ),
                  const CustomTextWidget(
                    text: "Account",
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget activeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.background,
          ],
          stops: const [
            0.5,
            1,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: activePage,
    );
  }
}
