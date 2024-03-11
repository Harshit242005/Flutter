import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:stories/landing.dart';
import 'package:stories/user.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isHovered = false;

  // listen for the text controller
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  // ignore: prefer_final_fields
  FirebaseAuth _auth = FirebaseAuth.instance;

  // ignore: non_constant_identifier_names
  void login_user() async {
    String userEmail = email.text.trim();
    String userPassword = password.text.trim();

    // ignore: unused_local_variable
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: userEmail,
      password: userPassword,
    );

    // User authenticated successfully
    String base64Image = '';
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Landing(
          email: userEmail,
          image: base64Image,
        ),
      ),
    );

    // // Open the Hive box
    // var box = await Hive.openBox<User>('users');
    // // ignore: avoid_print
    // print('box values are: ${box.values}');

    // // Get user input
    // String userEmail = email.text;
    // String userPassword = password.text;

    // if (box.values.any((user) => user.email == userEmail)) {
    //   // Retrieve the user object
    //   User existingUser =
    //       box.values.firstWhere((user) => user.email == userEmail);

    //   // Hash the entered password
    //   String enteredPasswordHash =
    //       sha256.convert(utf8.encode(userPassword)).toString();

    //   // Compare the hashed passwords
    //   if (existingUser!.passwordHash == enteredPasswordHash) {
    //     // Passwords match, user is authenticated
    //     String base64Image = existingUser.base64Image;

    //     // ignore: use_build_context_synchronously
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) =>
    //                 Landing(email: userEmail, image: base64Image)));
    //   } else {
    //     // Passwords do not match
    //     print('Incorrect password for user: $userEmail');
    //     // ignore: use_build_context_synchronously
    //     showDialog(
    //         context: context,
    //         builder: (context) => AlertDialog(
    //               title: const Text(
    //                 'Incorrect pasword',
    //                 style: TextStyle(fontFamily: 'ReadexPro'),
    //               ),
    //               content: Text('Incorrect password for user: $userEmail'),
    //               actions: <Widget>[
    //                 TextButton(
    //                   onPressed: () {
    //                     Navigator.of(context).pop();
    //                   },
    //                   child: const Text(
    //                     'Close',
    //                     style: TextStyle(fontFamily: 'ReadexPro'),
    //                   ),
    //                 ),
    //               ],
    //             ));
    //   }
    // } else {
    //   // User with the entered email does not exist
    //   // ignore: avoid_print
    //   print('User with email $userEmail does not exist.');
    //   // ignore: use_build_context_synchronously
    //   showDialog(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //             title: const Text(
    //               'Email not found',
    //               style: TextStyle(fontFamily: 'ReadexPro'),
    //             ),
    //             content: Text(
    //               'User with email $userEmail does not exist.',
    //               style: const TextStyle(fontFamily: 'ReadexPro'),
    //             ),
    //             actions: <Widget>[
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.of(context).pop(); // Close the dialog
    //                 },
    //                 child: const Text('Close'),
    //               ),
    //             ],
    //           ));
    // }

    // // Close the box when done
    // await box.close();
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
                            login_user();
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
