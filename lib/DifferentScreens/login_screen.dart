import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tourist_app/DifferentScreens/registration_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tourist_app/DifferentWidgets/progress_dialog.dart';

import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String idString = 'login';

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3a837a),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 35,
              ),
              const Image(
                image: AssetImage("images/logo.png"),
                alignment: Alignment.center,
              ),
              const SizedBox(
                height: 35,
              ),
              Text(
                'Login as a Tourist',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Bolt-Semibold"),
              ),
              Padding(
                padding: EdgeInsets.all(17.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    ElevatedButton(
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Log-In",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Bolt-Semibold",
                            ),
                          ),
                        ),
                      ),
                      // shape: new RoundedRectangleBorder(
                      //     borderRadius: new BorderRadius.circular(24.0)),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains("@")) {
                          displayErrorMessage("Email is Invalid!", context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayErrorMessage(
                              "Password should be atleast 6 characters",
                              context);
                        } else {
                          loginAndAuthenticateUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RegistrationScreen.idString, (route) => false);
                },
                child: const Text('First Time? Register!'),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Authenticating,Please wait...",
          );
        });
    final User? firebaseUser = //User?  is basically a null check
        (await _firebaseAuth
                .signInWithEmailAndPassword(
                    email: emailTextEditingController.text,
                    password: passwordTextEditingController.text)
                .catchError((errMsg) {
      Navigator.pop(context);
      displayErrorMessage("Error " + errMsg.toString(), context);
    }))
            .user;

    if (firebaseUser != null) //User successfully created
    {
      //Save the user information to the database!

      userReference.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, HomeScreen.idString, (route) => false);
          displayErrorMessage(
              "Congratulations! logged-in Successfully", context);
        } else {
          //Error occurred,Display error message
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayErrorMessage(
              "No account found with this email.Please register for a new account!",
              context);
        }
      });
    } else {
      Navigator.pop(context);
      displayErrorMessage("Error occurred! Cannot log-in.", context);
    }
  }

  void displayErrorMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
