import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:image_picker/image_picker.dart';

import 'l10n/app_en.arb.dart' as en;
import 'l10n/app_fr.arb.dart' as fr;

void main() {
  runApp(SimpleCalculatorApp());
}

class SimpleCalculatorApp extends StatefulWidget {
  @override
  _SimpleCalculatorAppState createState() => _SimpleCalculatorAppState();
}

class _SimpleCalculatorAppState extends State<SimpleCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;
  static const MethodChannel _batteryChannel =
  MethodChannel('com.example.flutter/battery');
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _initConnectivity();
    _initBatteryChannel();
  }

  void _loadThemeMode() async {
    var themePreference = await ThemePreferences().getThemeMode();
    setState(() {
      _themeMode = _getThemeMode(themePreference);
    });
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      bool isConnected = result != ConnectivityResult.none;
      _showConnectivityToast(isConnected);
    });
  }

  void _initBatteryChannel() {
    _batteryChannel.setMethodCallHandler((call) async {
      if (call.method == "batteryLevel") {
        String message = call.arguments as String;
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[800]!,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  void _showConnectivityToast(bool isConnected) {
    String message = isConnected
        ? en.app['connected_to_internet'] ?? 'Connected to Internet'
        : en.app['no_internet_connection'] ?? 'No Internet Connection';
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[800]!,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  ThemeMode _getThemeMode(ThemeModePreference themePreference) {
    switch (themePreference) {
      case ThemeModePreference.Light:
        return ThemeMode.light;
      case ThemeModePreference.Dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  void updateTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: en.app['app_title'] ?? 'Simple Calculator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: TabNavigation(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('fr', ''), // French
      ],
    );
  }
}

class TabNavigation extends StatefulWidget {
  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SignInScreen(),
    SignUpScreen(),
    Calculation(),
    SettingsScreen(),
    HelpScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
    context.findAncestorStateOfType<_SimpleCalculatorAppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800]!,
        title: Text(
          en.app['app_title'] ?? 'Simple Calculator',
          style: TextStyle(color: Colors.white!, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                en.app['user_name'] ?? 'User',
                style: TextStyle(color: Colors.white!),
              ),
              accountEmail: Text(
                en.app['user_email'] ?? 'user@example.com',
                style: TextStyle(color: Colors.white!),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(en.app['profile_picture'] ?? 'Profile Picture'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              GestureDetector(
                                child: Text(en.app['select_from_gallery'] ?? 'Select from Gallery'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  state?._pickImage(ImageSource.gallery);
                                },
                              ),
                              Padding(padding: EdgeInsets.all(8.0)),
                              GestureDetector(
                                child: Text(en.app['take_a_picture'] ?? 'Take a Picture'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  state?._pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: state?._profileImage != null ? FileImage(state!._profileImage!) : null,
                  child: state?._profileImage == null
                      ? Text(
                    'U',
                    style: TextStyle(fontSize: 40.0, color: Colors.red[300]!),
                  )
                      : null,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
            ),
            ListTile(
              leading: Icon(Icons.login, color: Colors.green[900]),
              title: Text(en.app['sign_in'] ?? 'Sign In'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration, color: Colors.blue[900]),
              title: Text(en.app['sign_up'] ?? 'Sign Up'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate, color: Colors.yellow),
              title: Text(en.app['calculator'] ?? 'Calculator'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(en.app['settings'] ?? 'Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.blue),
              title: Text(en.app['help'] ?? 'Help'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 4;
                });
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.login, color: Colors.yellow),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration, color: Colors.blue),
            label: 'Sign Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate, color: Colors.yellow),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help, color: Colors.blue),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fr.app['sign_in'] ?? 'Sign In', style: TextStyle(color: Colors.teal[900])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: fr.app['username'] ?? 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: fr.app['password'] ?? 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle sign in logic here
                String username = _usernameController.text;
                String password = _passwordController.text;
                print('Username: $username, Password: $password');
              },
              child: Text(fr.app['sign_in'] ?? 'Sign In', style: TextStyle(color: Colors.teal[900])),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fr.app['sign_up'] ?? 'Sign Up', style: TextStyle(color: Colors.teal[900])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: fr.app['username'] ?? 'Username'),

            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: fr.app['email'] ?? 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: fr.app['password'] ?? 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle sign up logic here
                String username = _usernameController.text;
                String email = _emailController.text;
                String password = _passwordController.text;
                print('Username: $username, Email: $email, Password: $password');
              },
              child: Text(fr.app['sign_up'] ?? 'Sign Up', style: TextStyle(color: Colors.teal[900])),
            ),
          ],
        ),
      ),
    );
  }
}

class Calculation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fr.app['calculator'] ?? 'Calculator'),
      ),
      body: Center(
        child: Text(fr.app['calculator_screen'] ?? 'Calculator Screen'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fr.app['settings'] ?? 'Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                ThemePreferences()
                    .setThemeMode(ThemeModePreference.Light)
                    .then((_) {
                  final state =
                  context.findAncestorStateOfType<_SimpleCalculatorAppState>();
                  state?.updateTheme(ThemeMode.light);
                });
              },
              child: Text(fr.app['switch_to_light_mode'] ?? 'Switch to Light Mode'),
            ),
            ElevatedButton(
              onPressed: () {
                ThemePreferences()
                    .setThemeMode(ThemeModePreference.Dark)
                    .then((_) {
                  final state =
                  context.findAncestorStateOfType<_SimpleCalculatorAppState>();
                  state?.updateTheme(ThemeMode.dark);
                });
              },
              child: Text(fr.app['switch_to_dark_mode'] ?? 'Switch to Dark Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fr.app['help'] ?? 'Help'),
      ),
      body: Center(
        child: Text(fr.app['help_screen'] ?? 'Help Screen'),
      ),
    );
  }
}

enum ThemeModePreference { Light, Dark }

class ThemePreferences {
  static const _themeModeKey = 'theme_mode';

  Future<void> setThemeMode(ThemeModePreference themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.toString());
  }

  Future<ThemeModePreference> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString =
        prefs.getString(_themeModeKey) ?? 'ThemeModePreference.Light';
    return _getThemeModePreference(themeModeString);
  }

  ThemeModePreference _getThemeModePreference(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeModePreference.Light':
        return ThemeModePreference.Light;
      case 'ThemeModePreference.Dark':
        return ThemeModePreference.Dark;
      default:
        return ThemeModePreference.Light;
    }
  }
}