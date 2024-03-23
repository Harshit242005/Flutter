// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Request extends StatefulWidget {
  Request({
    Key? key,
    required this.uid,
  }) : super(key: key);

  final String uid;
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {
  // variable to hold the documents
  List<DocumentSnapshot> _searchResults = [];
  String DocId = "";
  void load_request() async {
    try {
      // Get the user document to access the friend request list
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: widget.uid)
          .get();

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      DocId = userDoc.id;
      // DocumentSnapshot userDoc = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(widget.uid)
      //     .get();

      List<String> requestIds = List<String>.from(userDoc.get('request'));

      List<DocumentSnapshot> documents = [];

      // Query Firestore to get the user documents for each request ID
      for (String requestId in requestIds) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: requestId)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          documents.add(querySnapshot.docs.first);
        }
      }

      setState(() {
        _searchResults = documents;
      });
    } catch (error) {
      print('Error loading friend requests: $error');
    }
  }

  void add_user(String userId) async {
    try {
      // Get the user document using the provided userId
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(DocId).get();

      // Get the current list of friends from the document data
      List<dynamic> friends = userDoc.get('friend') ?? [];

      // Add the current user's uid to the list of friends if it's not already present
      if (!friends.contains(userId)) {
        friends.add(userId);

        // Update the document with the modified friends list
        await FirebaseFirestore.instance.collection('users').doc(DocId).update({
          'friend': friends,
        });

        print(
            'User ${widget.uid} added successfully to the friends list of user $userId.');

        // Now, add the userId to the current user's friend list
        await addCurrentUserToFriendList(userId);
      } else {
        print(
            'User ${widget.uid} is already in the friends list of user $userId.');
      }
    } catch (e) {
      print('Error adding user to friends list: $e');
    }
  }

  // Function to add the userId to the current user's friend list
  Future<void> addCurrentUserToFriendList(String userId) async {
    try {
      // Get the current user's document using the provided widget.uid
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get a reference to the users collection
      CollectionReference usersCollection = firestore.collection('users');

      QuerySnapshot querySnapshot = await usersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      DocumentSnapshot currentUserDoc = querySnapshot.docs.first;

      // Get the current list of friends from the document data
      List<dynamic> currentUserFriends = currentUserDoc.get('friend') ?? [];

      // Add the userId to the list of friends if it's not already present
      if (!currentUserFriends.contains(widget.uid)) {
        currentUserFriends.add(widget.uid);

        // Update the document with the modified friends list
        await currentUserDoc.reference.update({
          'friend': currentUserFriends,
        });
        // remove the request after accepting from the requests array
        remove_user(userId);

        print(
            'User $userId added successfully to the friends list of current user.');
      } else {
        print('User $userId is already in the friends list of current user.');
      }
    } catch (e) {
      print('Error adding user to current user\'s friends list: $e');
    }
  }

  void remove_user(String userId) async {
    try {
      // Get the user document using the provided docId
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(DocId).get();

      // Get the current list of requests from the document data
      List<dynamic> requests = userDoc.get('request') ?? [];

      // Check if the userId exists in the requests list
      if (requests.contains(userId)) {
        // Remove the userId from the requests list
        requests.remove(userId);
        // load all the request again for refreshing
        load_request();
        // Update the document with the modified requests list
        await FirebaseFirestore.instance.collection('users').doc(DocId).update({
          'request': requests,
        });

        print('User $userId removed successfully from the requests list.');
      } else {
        print('User $userId is not in the requests list.');
      }
    } catch (e) {
      print('Error removing user from requests list: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // call for the load of the requests
    load_request();
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friend Request',
          style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
      ),

      // ignore: prefer_const_literals_to_create_immutables
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(_searchResults[index]['userImage']),
                ),
                title: Text(
                  _searchResults[index]['userName'],
                  style: const TextStyle(fontFamily: 'ReadexPro'),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        // Implement logic to accept friend request
                        add_user(_searchResults[index]['userId']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        // Implement logic to remove friend request
                        remove_user(_searchResults[index]['userId']);
                      },
                    ),
                  ],
                ),

                // here a onpressed effect so
              );
            },
          ),
        ],
      )),
    );
  }
}
