import 'package:flash_chat/screens/all_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

var email;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  email = prefs.getString('email');
  print(email);
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     initialRoute: email == null ? 'welcome_screen' : 'all_users_screen' ,
     routes: {
       'welcome_screen':(context)=>WelcomeScreen(),
       'login_screen':(context)=>LoginScreen(),
       'registration_screen':(context)=>RegistrationScreen(),
       'all_users_screen':(context)=>AllUsersScreen(),
     },
    );
  }
}
