import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stories/landing.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, required this.uid, required this.email})
      : super(key: key);
  final String uid;
  final String email;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  String DocId = "";
  Future<void> get_data(String userId) async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get the user document from Firestore using the userId
      QuerySnapshot userDocument = await firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      DocumentSnapshot userDoc = userDocument.docs.first;
      DocId = userDoc.id;
      // Check if the user document exists
      if (userDoc.exists) {
        // Extract the user data from the document
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Return the user data
        setState(() {
          name.text = userData["userName"];
          description.text = userData["userDescription"];
        });
      }
    } catch (e) {
      // Handle any errors that occur during the data fetching process
      print('Error getting user data: $e');
    }
  }

  Future<bool> update_profile() async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get a reference to the user document
      DocumentReference userRef = firestore.collection('users').doc(DocId);

      // Update the fields in the document
      await userRef.update({
        'userName': name.text,
        'userDescription': description.text,
      });

      // If the update is successful, return true
      return true;
    } catch (e) {
      // If an error occurs, print the error and return false
      print('Error updating profile: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    // load the initial data for the name and description from user document
    get_data(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Type name',
                  style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                    width: 250,
                    height: 50,
                    child: TextField(
                      style: const TextStyle(fontFamily: 'ReadexPro'),
                      controller: name,
                      decoration: const InputDecoration(
                          labelText: 'Type heading...',
                          hintStyle: TextStyle(fontFamily: 'ReadexPro'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(48, 0, 0, 0),
                            width: 0.5,
                          ))),
                    ))
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Type description',
                  style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                    width: 300,
                    height: 250,
                    child: TextField(
                      style: const TextStyle(fontFamily: 'ReadexPro'),
                      controller: description,
                      maxLines: null,
                      maxLength: null,
                      decoration: const InputDecoration(
                          labelText: 'Type description...',
                          hintStyle: TextStyle(fontFamily: 'ReadexPro'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(48, 0, 0, 0),
                            width: 0.5,
                          ))),
                    ))
              ],
            ),
            const SizedBox(
              height: 200,
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                // defining a button to change the details
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () async {
                        bool update = await update_profile();
                        if (update) {
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Landing(
                                      email: widget.email, uid: widget.uid)));
                        }
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          splashFactory: NoSplash.splashFactory,
                          minimumSize:
                              MaterialStateProperty.all(const Size(300, 50)),
                          elevation: MaterialStateProperty.all(0),
                          side: MaterialStateProperty.all(const BorderSide(
                              width: 1,
                              color: Color.fromARGB(255, 82, 255, 88)))),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                            fontFamily: 'ReadexPro',
                            fontSize: 20,
                            color: Color.fromARGB(255, 82, 255, 88)),
                      ))
                ])
          ],
        ),
      ),
    );
  }
}
