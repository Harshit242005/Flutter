import 'dart:convert';
import 'dart:io';
// import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stories/landing.dart';
// import 'package:stories/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // listen for the file and the function popup call for the signup
  late ImagePicker _imagePicker;
  XFile? _imageFile;

  bool isHovered = false;

  // a variable to check whether the signup button should become disable or not
  var signupButton = false;
  void changeSignupButton() {
    String userEmail = email.text.trim();
    String userPassword = password.text.trim();

    bool emailIsValid = isEmailValid(userEmail);
    bool passwordIsOptimalLength = optimalLength(userPassword);
    setState(() {
      signupButton = emailIsValid && passwordIsOptimalLength;
    });
  }

  // listen for the text controller
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  // function to check whether the typed text is a gmail or not
  bool isEmailValid(String input) {
    // Regular expression for a simple email validation
    // This regex is a simplified version and may not cover all edge cases.
    // You may want to use a more comprehensive email validation regex.
    RegExp regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return regex.hasMatch(input);
  }

  // function to check whether the length of the password is not an optimal length or not
  bool optimalLength(String password) {
    if (password.length < 6) {
      return false;
    }
    return true;
  }

  // function to get the user image file stored in the firebase storage feature
  Future<String> uploadImage(File imageFile) async {
    // Create a unique filename for the image
    String filename = basename(imageFile.path);

    // Reference to the Firebase Storage bucket
    Reference storageReference = FirebaseStorage.instance.ref().child(filename);

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(imageFile);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String downloadURL = await snapshot.ref.getDownloadURL();

    // Return the download URL
    return downloadURL;
  }

  void save_data(BuildContext context) async {
    print('save data function is called');
    // // Fetch user details
    // String base64Image = await printBase64();
    // Convert XFile to File
    File imageFile = File(_imageFile!.path);

    // get the file downloadUrl from the storage database of the firebase
    String profile_image_url = await uploadImage(imageFile);
    print('profie image url is: $profile_image_url');
    String userEmail = email.text;
    // check for the email regex check
    if (!isEmailValid(userEmail)) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context as BuildContext,
        builder: (context) => AlertDialog(
          title: const Text(
            'Invalid Email',
            style: TextStyle(fontFamily: 'ReadexPro'),
          ),
          content: const Text(
            'The typed text is not a valid email address.',
            style: TextStyle(fontFamily: 'ReadexPro'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close',
                  style: TextStyle(fontFamily: 'ReadexPro')),
            ),
          ],
        ),
      );
    }
    String userPassword = password.text;

    // check for user password
    if (!optimalLength(userPassword)) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context as BuildContext,
        builder: (context) => AlertDialog(
          title: const Text(
            'Invalid password length',
            style: TextStyle(fontFamily: 'ReadexPro'),
          ),
          content: const Text(
            'The typed password length cannot be less than 6',
            style: TextStyle(fontFamily: 'ReadexPro'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close',
                  style: TextStyle(fontFamily: 'ReadexPro')),
            ),
          ],
        ),
      );
    }

    // inserting user in the firebase email password signin methodology
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: userEmail,
      password: userPassword,
    );

    // Access the user's UID (auth_id)
    // ignore: unused_local_variable
    String uid = userCredential.user!.uid;
    print('user uid is: $uid');
    // ignore: unused_local_variable
    await uploadData(context, uid, profile_image_url);
  }

  Future<void> uploadData(
      BuildContext context, String userId, String userImage) async {
    try {
      // Get a Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Specify the collection where you want to add the document
      CollectionReference usersCollection = firestore.collection('users');

      // Data to be uploaded as a document
      Map<String, dynamic> userData = {
        'userId': userId,
        'userImage': userImage,
        'friend': [],
        'request': [],
        'userDescription': '',
        'userName': '',
        'block': [],
        'status': 'online'
      };

      // Add the document to the collection
      DocumentReference documentRef = await usersCollection.add(userData);

      print('Document ID: ${documentRef.id}');
      print('Data uploaded successfully');

      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Landing(email: email.text, uid: userId)));
    } catch (e) {
      print('Error uploading data: $e');
      // Handle the error appropriately
    }
  }

  // Function to handle image picking
  Future<void> pickImage() async {
    try {
      XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // get the base64 of te image as in string format
  Future<String> printBase64() async {
    if (_imageFile != null) {
      // Read the picked image as bytes
      List<int> imageBytes = await _imageFile!.readAsBytes();

      // Encode the bytes to base64
      String base64String = base64Encode(imageBytes);

      return base64String;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Signup',
            style:
                TextStyle(fontFamily: 'ReadexPro', fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: <Widget>[
              // here i would ask for image and a gamil and a password
              const SizedBox(
                height: 75,
              ),
              GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color.fromARGB(55, 0, 0, 0),
                            width: 0.5)),
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(
                              File(_imageFile!.path),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/profilePhoto.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                    ),
                  )),
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
                        onChanged: (value) {
                          // Call the function to update signupButton whenever the text changes
                          changeSignupButton();
                        },
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
                        onChanged: (value) {
                          // Call the function to update signupButton whenever the text changes
                          changeSignupButton();
                        },
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
                            save_data(context);
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
                            'Signup',
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
          )),
        ));
  }
}
