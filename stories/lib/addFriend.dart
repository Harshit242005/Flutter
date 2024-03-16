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
  // controllers for the input field
  final TextEditingController userName = TextEditingController();
  // variable to hold the documents
  List<DocumentSnapshot> _searchResults = [];

  void checkName(String query) async {
    if (query.isEmpty) {
      // Handle empty query
      return;
    }

    // // Query Firestore to search for users with matching names
    // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('userName', isGreaterThanOrEqualTo: query)
    //     .where('userName', isLessThanOrEqualTo: '$query\uf8ff')
    //     .get();
    String lowercaseQuery = query.toLowerCase();

    // Query Firestore to search for users with matching names (case-insensitive)
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('userName', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .get();
    print('query docs are: ${querySnapshot.docs}');
    // Process the query results
    List<DocumentSnapshot> searchResults = querySnapshot.docs;
    searchResults.removeWhere((doc) => doc['userId'] == widget.uid);
    // Update the UI with the search results
    updateSearchResults(searchResults);
  }

  void updateSearchResults(List<DocumentSnapshot> searchResults) {
    print('search results are: $searchResults');
    setState(() {
      _searchResults = searchResults;
    });
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
                              icon: Icon(Icons.add),
                              onPressed: () {
                                // function to send a friend request and change the icon to - or remove button
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
