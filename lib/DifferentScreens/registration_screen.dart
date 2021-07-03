import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tourist_app/DifferentScreens/home_screen.dart';
import 'package:tourist_app/DifferentWidgets/progress_dialog.dart';
import 'package:tourist_app/main.dart';
import 'login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatelessWidget {
  static const String idString = 'register';
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  RegistrationScreen({Key? key}) : super(key: key);

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
                width: 230,
                height: 230,
                alignment: Alignment.center,
              ),
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Create new tourist account!',
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
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
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
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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
                            "Sign-up",
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
                        if (nameTextEditingController.text.length < 3) {
                          displayErrorMessage(
                              "Name must be atleast 3 characters!", context);
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          displayErrorMessage("Email is Invalid!", context);
                        } else if (phoneTextEditingController.text.isEmpty) {
                          displayErrorMessage(
                              "Please enter your phone number", context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayErrorMessage(
                              "Password should be atleast 6 characters",
                              context);
                        } else {
                          registerNewUser(context);
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
                      context, LoginScreen.idString, (route) => false);
                },
                child: const Text('Already have an Account? Log-in'),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registering,Please wait...",
          );
        });
    final User? firebaseUser = //User?  is basically a null check
        (await _firebaseAuth
                .createUserWithEmailAndPassword(
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

      Map userDataMap = {
        "name": nameTextEditingController.text
            .trimRight(), //.trim() to ensure whitespaces after are allowed
        "email": emailTextEditingController.text.trimRight(),
        "phone": phoneTextEditingController.text.trimRight(),
      };

      userReference.child(firebaseUser.uid).set(userDataMap);
      displayErrorMessage(
          "Congratulations! Your account has been created", context);
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.idString, (route) => false);
    } else {
      //Error occurred,Display error message
      Navigator.pop(context);
      displayErrorMessage("new User couldn't be created :(", context);
    }
  }

  displayErrorMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
