// to handle the landing page
// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stories/createTask.dart';
import 'package:stories/user.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  // ignore: library_private_types_in_public_api
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  // ignore: non_constant_identifier_names
  Uint8List bytes = Uint8List(0);
  late ImagePicker _imagePicker;
  XFile? _imageFile;

  Future<String> printBase64() async {
    if (_imageFile != null) {
      // Read the picked image as bytes
      List<int> imageBytes = await _imageFile!.readAsBytes();

      // Encode the bytes to base64
      String base64String = base64Encode(imageBytes);
      print('user selected image string data is: $base64String');

      return base64String;
    } else {
      return '';
    }
  }

  Future<void> pickImage() async {
    try {
      XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        bool userConfirmation = (await conformation());
        print('user conformation for the profile change is: $userConfirmation');
        if (userConfirmation) {
          // Perform asynchronous work outside setState
          String newUserProfileImage = await printBase64();

          // Open the Hive box
          var box = await Hive.openBox<User>('users');

          // Find the user with the matching email
          User? userToUpdate = box.values.firstWhere(
            (user) => user.email == widget.email,
          );

          // Update the base64Image of the user
          userToUpdate.base64Image = newUserProfileImage;

          // Save the updated user back to the box
          await box.put(userToUpdate.key, userToUpdate);

          // Close the box when done
          await box.close();

          // Synchronously update the state
          setState(() {
            bytes = base64Decode(newUserProfileImage);
          });
        } else {
          // Ignore: avoid_print
          print('User denied the change of profile image');
        }
      }
    } catch (e) {
      // Ignore: avoid_print
      print('Error picking image: $e');
    }
  }

  Future<bool> conformation() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: AlertDialog(
            backgroundColor: Colors.black,
            content: Container(
              height: 100,
              child: Column(
                children: const <Widget>[
                  Text(
                    'Are you sure to change the profile image',
                    style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // User confirmed to change
                },
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontFamily: 'ReadexPro',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // User closed without changing
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'ReadexPro',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Handle the null case by returning false
    return result ?? false;
  }

  Future<void> loadImage() async {
    var box = await Hive.openBox<User>('users');
    User? user = box.values.firstWhere(
      (user) => user.email == widget.email,
    );
    print('user box is: $user');
    setState(() {
      bytes = base64Decode(user.base64Image);
    });

    await box.close();
  }

  @override
  void initState() {
    super.initState();

    loadImage();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    // Uint8List bytes = base64Decode(widget.image);
    // ignore: duplicate_ignore
    return Scaffold(
      // user details
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Container(
                    height: 400,
                    child: AlertDialog(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      backgroundColor: Colors.black,
                      title: const Text(
                        'Profile',
                        style: TextStyle(
                            fontFamily: 'ReadexPro', color: Colors.white),
                      ),
                      content: Container(
                          height: 275,
                          child: Column(
                            children: <Widget>[
                              Container(
                                  height: 150,
                                  width: 150,
                                  child: CircleAvatar(
                                    radius: 50,

                                    backgroundImage: MemoryImage(
                                        bytes), // Replace with your image asset
                                    child: IconButton(
                                      tooltip: 'Change image',
                                      iconSize: 75,
                                      color: const Color.fromARGB(175, 0, 0, 0),
                                      splashColor: Colors.black,
                                      icon: const Icon(Icons.camera_alt),
                                      onPressed: () {
                                        // call for select the new image
                                        pickImage();
                                      },
                                    ),
                                  )),
                              const SizedBox(
                                height: 75,
                              ),
                              ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(0),
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(250, 50)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)))),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(
                                        fontFamily: 'ReadexPro',
                                        color: Colors.red,
                                        fontSize: 18),
                                  ))
                            ],
                          )),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              minimumSize: MaterialStateProperty.all(
                                  const Size(250, 50)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)))),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ));
              },
            );
          },
          child: CircleAvatar(
            backgroundImage: MemoryImage(bytes),
          ),
        ),

        // add a leading person image icon
        automaticallyImplyLeading: false,
        title: const Text(
          'Stories',
          style: TextStyle(fontFamily: 'ReadexPro'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateTask()));
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
            child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[],
        )),
      ),
    );
  }
}
