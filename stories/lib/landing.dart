// to handle the landing page
// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:stories/addFriend.dart';
import 'package:stories/main.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:stories/profile.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key, required this.email, required this.uid})
      : super(key: key);

  final String email;
  final String uid;

  @override
  // ignore: library_private_types_in_public_api
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  late ImagePicker _imagePicker;
  XFile? _imageFile;

  // to hold the network url for the image
  String user_profile_image = '';

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

  // Function to upload a new profile image for the user
  Future<void> updateProfileImage(String userId, File newImage) async {
    // Upload the new image file to Firebase Storage
    String newImageUrl = await uploadImage(newImage);
    print('new image url is: $newImageUrl');
    // Update the user's document in Firestore with the new image URL

    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query the collection to find the document with the matching userId
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Get the reference to the first document from the query result
        DocumentSnapshot document = querySnapshot.docs.first;

        // Update the userImage field in the document
        await document.reference.update({
          'userImage': newImageUrl,
        });

        print('User image updated successfully!');
      } else {
        // No document found with the matching userId
        print('No document found for user with userId: $userId');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error updating user image: $e');
    }

    setState(() {
      user_profile_image = newImageUrl;
    });

    print('Profile image updated successfully!');
  }

  // function to get the user image file stored in the firebase storage feature
  Future<String> uploadImage(File imageFile) async {
    // Create a unique filename for the image
    String filename = path.basename(imageFile.path);
    print('file name is: $filename');

    // Reference to the Firebase Storage bucket
    Reference storageReference = FirebaseStorage.instance.ref().child(filename);

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(imageFile);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String downloadURL = await snapshot.ref.getDownloadURL();
    print('image url: $downloadURL');
    // Return the download URL
    return downloadURL;
  }

  Future<void> pickImage() async {
    try {
      XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        bool userConfirmation = (await conformation());
        print('user conformation for the profile change is: $userConfirmation');
        File imageFile = File(pickedFile.path);
        print('image file is: $imageFile');
        // change the image in the retrieval form
        if (userConfirmation) {
          await updateProfileImage(widget.uid, imageFile);
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

  Future<void> loadImage(String userId) async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get a reference to the users collection
      CollectionReference usersCollection = firestore.collection('users');

      // Query the collection to find the document with the matching userId
      QuerySnapshot querySnapshot = await usersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      print('query snapshot is: $querySnapshot');
      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query result
        DocumentSnapshot document = querySnapshot.docs.first;

        // Extract the userImage URL from the document
        String userImage = document.get('userImage');
        print('user image url from the load image function: $userImage');
        // Set the userImage URL in the user_profile_image variable using setState
        setState(() {
          user_profile_image = userImage;
        });
      } else {
        // No document found with the matching userId
        print('No document found for user with userId: $userId');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error loading image: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    loadImage(widget.uid);
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
                                    backgroundImage:
                                        NetworkImage(user_profile_image),
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
                                  onPressed: () {
                                    // this will logout the user
                                    FirebaseAuth.instance.signOut();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                  },
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Profile(
                                          uid: widget.uid,
                                          email: widget.email,
                                        )));
                          },
                          child: const Text(
                            'Profile',
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
            backgroundImage: NetworkImage(user_profile_image),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddFriend(
                            uid: widget.uid,
                          )));
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
