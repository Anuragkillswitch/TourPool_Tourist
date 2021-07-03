import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourist_app/DifferentScreens/home_screen.dart';
import 'package:tourist_app/DifferentScreens/login_screen.dart';
import 'package:tourist_app/DifferentScreens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'DataHandler/app_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

DatabaseReference userReference =
    FirebaseDatabase.instance.reference().child("Users");

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'TourPool',
        theme: ThemeData(
          fontFamily: 'Bolt-Semibold',
          primarySwatch: Colors.lightGreen,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.idString
            : HomeScreen.idString,
        routes: {
          RegistrationScreen.idString: (context) => RegistrationScreen(),
          LoginScreen.idString: (context) => LoginScreen(),
          HomeScreen.idString: (context) => HomeScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
