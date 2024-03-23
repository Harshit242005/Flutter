import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<AddFriend> {
  bool isAdding = true;
  // controllers for the input field
  final TextEditingController userName = TextEditingController();
  // variable to hold the documents
  List<DocumentSnapshot> _searchResults = [];

  void checkName(String query) async {
    if (query.isEmpty) {
      // Handle empty query
      return;
    }

    // Query Firestore to search for users with matching names
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    print('query docs are: ${querySnapshot.docs}');
    // Process the query results
    List<DocumentSnapshot> searchResults = querySnapshot.docs;
    searchResults.removeWhere((doc) => doc['userId'] == widget.uid);
    // get my friends list as well and remove those docuemnt also from the results
    List friendList = await getFriendList();
    for (String friendId in friendList) {
      searchResults.removeWhere((doc) => doc['userId'] == friendId);
    }

    // Update the UI with the search results
    updateSearchResults(searchResults);
  }

  Future<List> getFriendList() async {
    try {
      // Get the user document where userId matches widget.uid
      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: widget.uid)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first;
        } else {
          throw Exception("User document not found");
        }
      });

      // Extract the friend array from the user document
      dynamic userData = userDocSnapshot.data();
      List<String> friendList = userData?['friend'] != null
          ? List<String>.from(userData['friend'])
          : [];

      // Now you have the friend list array, you can use it as needed
      print("Friend List: $friendList");
      return friendList;
    } catch (error) {
      print('Error retrieving friend list: $error');
      return [];
    }
  }

  void updateSearchResults(List<DocumentSnapshot> searchResults) {
    print('search results are: $searchResults');
    setState(() {
      _searchResults = searchResults;
    });
  }

  void removePerson(String userId) async {
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

      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query result
        DocumentSnapshot document = querySnapshot.docs.first;

        // Get the current list of friend requests
        List<dynamic> requests = document.get('request') ?? [];

        // Check if the current user's UID is in the requests list
        if (requests.contains(widget.uid)) {
          // Remove the current user's UID from the requests list
          requests.remove(widget.uid);

          // Update the document with the updated requests list
          await document.reference.update({'request': requests});

          // Person removed successfully
          print('Person removed successfully from user with ID: $userId');
        } else {
          // User's UID is not in the requests list
          print('Person is not in the requests list for user with ID: $userId');
        }
      } else {
        // No document found with the matching userId
        print('No document found for user with ID: $userId');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error removing person: $e');
    }
  }

  void sendFriendRequest(String userId) async {
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

      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query result
        DocumentSnapshot document = querySnapshot.docs.first;

        // Get the current list of friend requests
        List<dynamic> requests = document.get('request') ?? [];

        // Check if the current user's UID is not already in the requests list
        if (!requests.contains(widget.uid)) {
          // Add the current user's UID to the requests list
          requests.add(widget.uid);

          // Update the document with the updated requests list
          await document.reference.update({'request': requests});

          // Friend request sent successfully
          print('Friend request sent successfully to user with ID: $userId');
        } else {
          // User is already in the requests list
          print('Friend request already sent to user with ID: $userId');
        }
      } else {
        // No document found with the matching userId
        print('No document found for user with ID: $userId');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error sending friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add User',
          style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // add a search field for serach the users
            const SizedBox(
              height: 50,
            ),
            Container(
                width: 300,
                height: 150,
                child: TextField(
                  onChanged: (value) {
                    checkName(value);
                  },
                  style: const TextStyle(
                      fontFamily: 'ReadexPro',
                      color: Color.fromARGB(141, 0, 0, 0)),
                  controller: userName,
                  decoration: const InputDecoration(
                      labelText: 'Serach user',
                      hintStyle: TextStyle(fontFamily: 'ReadexPro'),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Color.fromARGB(40, 0, 0, 0),
                        width: 1,
                      ))),
                )),
            // a column view which would be scrollable to view the users in it
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                    visible: _searchResults.isNotEmpty,
                    replacement: const Text(
                      '',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ReadexPro'),
                    ),
                    child: Container(
                      width: 300,
                      height: 300, // Adjust the height as needed
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          // Build the UI for each search result
                          // For example, display user information like name, email, etc.
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  _searchResults[index]['userImage']),
                            ),
                            title: Text(
                              _searchResults[index]['userName'],
                              style: const TextStyle(fontFamily: 'ReadexPro'),
                            ),
                            trailing: IconButton(
                              icon: isAdding
                                  ? Icon(Icons.add)
                                  : Icon(Icons.remove),
                              onPressed: () {
                                // function to send a friend request and change the icon to - or remove button
                                if (!isAdding) {
                                  // Run function to remove the person from the request list
                                  removePerson(_searchResults[index]["userId"]);
                                } else {
                                  // Run function to send a friend request
                                  sendFriendRequest(
                                      _searchResults[index]["userId"]);
                                }
                                setState(() {
                                  isAdding = !isAdding;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}
