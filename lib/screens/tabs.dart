// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously, no_logic_in_create_state
import 'package:agencies_app/api_urls/config.dart';
import 'package:agencies_app/constants/sizes.dart';
import 'package:agencies_app/screens/home_screen.dart';
import 'package:agencies_app/screens/login_screen.dart';
import 'package:agencies_app/screens/user_account_details.dart';
import 'package:agencies_app/screens/welcome_screen.dart';
import 'package:agencies_app/small_widgets/custom_text_widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabsBottom extends StatefulWidget {
  const TabsBottom({super.key, this.myToken});
  final myToken;

  @override
  State<TabsBottom> createState() => _TabsBottomState();
}

class _TabsBottomState extends State<TabsBottom> {
  late Widget activePage;
  int _currentIndx = 0;
  double _screenWidth = 0;

  @override
  void initState() {
    super.initState();
    activePage = HomeScreen(token: widget.myToken);
    getDeviceLocation();
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

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Location Access Denied');
      await Geolocator.requestPermission();
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      globalLat = currentPosition.latitude;
      globallng = currentPosition.longitude;
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      globalLat = currentPosition.latitude;
      globallng = currentPosition.longitude;
      debugPrint(
          "Latitude: ${globalLat.toString()} , Longitude: ${globallng.toString()}");
    }
    // Navigator.of(context).pop();
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
    // Map<String, String> headers = {
    //   "Content-Type": "application/json",
    //   'Authorization': 'Bearer ${widget.myToken}'
    // };

    // var response = await http.delete(
    //   Uri.parse(logoutUserUrl),
    //   headers: headers,
    // );

    // var jsonResponse = jsonDecode(response.body);

    // String message = jsonResponse['message'];

    // if (response.statusCode == 200 || response.statusCode != 200) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

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
    // } else {
    //   customShowDialog(
    //       context: context, titleText: 'Ooops!', contentText: message);
    // }
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    if (_currentIndx == 1) {
      activePage = UserAccountDetails(
        logoutUser: _logoutUser,
      );
    } else if (_currentIndx == 0) {
      activePage = HomeScreen(token: widget.myToken);
    }

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      // kIsWeb
      //     ? Padding(
      //         padding: const EdgeInsets.all(12.0),
      //         child: activeScreenWeb(context: context),
      //       )
      //     : activeScreenMobile(),
      body: _screenWidth > mobileScreenWidth
          ? activeScreenWeb(context: context)
          : Expanded(
              child: activeScreenMobile(),
            ),
      bottomNavigationBar: _screenWidth > mobileScreenWidth
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

  Widget navigationBarWeb({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
      child: SizedBox(
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
            child: activeScreenMobile(),
          ),
        ),
      ],
    );
  }

  Widget activeScreenMobile() {
    return SafeArea(
      child: Container(
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
      ),
    );
  }
}
