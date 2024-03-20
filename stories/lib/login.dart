// ignore_for_file: avoid_print, duplicate_ignore, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import 'package:hive/hive.dart';
import 'package:stories/landing.dart';
// import 'package:stories/user.dart';
import 'package:hive/hive.dart';
import 'user.dart'; // Assuming you have defined the User class

// call for the flutter

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isHovered = false;

  // listen for the text controller
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  // // ignore: prefer_final_fields
  // FirebaseAuth _auth = FirebaseAuth.instance;

  void login() async {
    String userEmail = email.text.trim();
    String userPassword = password.text.trim();

    try {
      // Sign in the user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );
      // user id from auth feature
      String uid = userCredential.user!.uid;
      // add the email and and uid in the hive box
      // Open the Hive box for user data (create if not exists)
      final userBox = await Hive.openBox<UserData>('userBox');

      // Create a new User object with the UID and email
      UserData user = UserData(uid: uid, email: email.text);

      // Save the user object to the box
      await userBox.put('user', user);
      await userBox.close();

      // User authenticated successfully, navigate to next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Landing(
            email: userEmail,
            uid: uid,
          ),
        ),
      );
    } catch (e) {
      // An error occurred during sign-in
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Authentication Error',
            style: TextStyle(
                fontFamily: 'ReadexPro',
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          content: Text(
            'An error occurred during sign-in: $e',
            style: const TextStyle(
                fontFamily: 'ReadexPro',
                fontWeight: FontWeight.w400,
                color: Colors.white),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  minimumSize: MaterialStateProperty.all(const Size(100, 50)),
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close',
                  style: TextStyle(
                      fontFamily: 'ReadexPro',
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style:
              TextStyle(fontFamily: 'ReadexPro', fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 150,
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Gmail',
                      style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: 300,
                      height: 50,
                      child: TextField(
                        controller: email,
                        decoration: const InputDecoration(
                            labelText: 'Type gmail...',
                            hintStyle: TextStyle(fontFamily: 'ReadexPro'),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Color.fromARGB(48, 0, 0, 0),
                              width: 0.5,
                            ))),
                      ),
                    ),
                  ]),
              const SizedBox(
                height: 25,
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Password',
                      style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: 300,
                      height: 50,
                      child: TextField(
                        controller: password,
                        decoration: const InputDecoration(
                            labelText: 'Type password...',
                            hintStyle: TextStyle(fontFamily: 'ReadexPro'),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Color.fromARGB(48, 0, 0, 0),
                              width: 0.5,
                            ))),
                      ),
                    ),
                  ]),
              const SizedBox(
                height: 25,
              ),
              Container(
                  width: 200,
                  height: 50,
                  child: MouseRegion(
                      onEnter: (_) => setState(() => isHovered = true),
                      onExit: (_) => setState(() => isHovered = false),
                      child: ElevatedButton(
                          onPressed: () {
                            // calling for the function to login the user
                            login();
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(1),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            minimumSize:
                                MaterialStateProperty.all(const Size(200, 50)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 18,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                                color: isHovered
                                    ? Colors.white
                                    : const Color.fromARGB(179, 255, 255, 255)),
                          ))))
            ],
          ),
        ),
      ),
    );
  }
}
