import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key, required this.userId, required this.uid})
      : super(key: key);

  final String userId;
  final String uid;

  @override
  // ignore: library_private_types_in_public_api
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController chatMessage = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();

  String user_profile_image = '';
  bool isDeleteButtonVisible = false;

  String user_name = '';
  String deleteDocumentId = '';
  void sendMessage() async {
    if (chatMessage.text.isNotEmpty) {
      try {
        // Get a reference to the Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Get a reference to the chats collection
        CollectionReference chatsCollection = firestore.collection('chats');

        // Construct the chat message document
        Map<String, dynamic> messageData = {
          'from': widget.uid,
          'to': widget.userId,
          'message': chatMessage.text,
          'timestamp': DateTime.now(), // Add a timestamp for sorting
        };

        // Add the message document to the chats collection
        await chatsCollection.add(messageData);

        // Clear the text field after sending the message
        chatMessage.clear();
        _scrollToBottom();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  // to scroll donw automatically
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Stream<QuerySnapshot> _messageStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void load_user_data() async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get a reference to the users collection
      CollectionReference usersCollection = firestore.collection('users');

      // Query the collection to find the document with the matching userId
      QuerySnapshot querySnapshot = await usersCollection
          .where('userId', isEqualTo: widget.userId)
          .limit(1)
          .get();
      print('query snapshot is: $querySnapshot');
      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document from the query result
        DocumentSnapshot document = querySnapshot.docs.first;

        // Extract the userImage URL from the document
        String userImage = document.get('userImage');
        String userName = document.get('userName');
        print('user image url from the load image function: $userImage');
        // Set the userImage URL in the user_profile_image variable using setState
        setState(() {
          user_profile_image = userImage;
          user_name = userName;
        });
      } else {
        // No document found with the matching userId
        print('No document found for user with userId: ${widget.userId}');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error loading image: $e');
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        DateFormat('HH:mm').format(dateTime); // Format time as "HH:mm"
    String formattedDate =
        DateFormat('dd/MM/yy').format(dateTime); // Format date as "dd/MM/yy"
    return '$formattedTime - $formattedDate'; // Combine time and date
  }

  void deletechat(String documentId) async {
    try {
      // Get the reference to the document in the chats collection
      DocumentReference chatRef =
          FirebaseFirestore.instance.collection('chats').doc(documentId);

      // Delete the document
      await chatRef.delete();

      // Document successfully deleted
      print('Chat document deleted successfully');
      setState(() {
        isDeleteButtonVisible = false;
      });
    } catch (e) {
      // An error occurred while deleting the document
      print('Error deleting chat document: $e');
    }
  }

  @override
  initState() {
    super.initState();

    load_user_data();
    // listen for the focus on the text field and scroll donw in the scroll view
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Scroll down to the end of the ScrollView
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controllers
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading:
            CircleAvatar(backgroundImage: NetworkImage(user_profile_image)),
        title: Text(
          user_name,
          style: const TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          // conditionally
          if (isDeleteButtonVisible)
            isDeleteButtonVisible
                ? IconButton(
                    onPressed: () {
                      deletechat(deleteDocumentId);
                    },
                    icon: const Icon(Icons.delete),
                  )
                : SizedBox(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      // ignore: prefer_const_constructors
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      switch (snapshot.connectionState) {
                        default:
                          return Column(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              String documentId = document.id;
                              String fromId = document['from'];
                              return Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width,
                                ),
                                margin: EdgeInsets.only(
                                  top: 10,
                                  left: data['from'] == widget.uid ? 135 : 0,
                                  right: data['from'] == widget.uid ? 0 : 135,
                                ),
                                width: 225,
                                child: ListTile(
                                  title: Text(
                                    data['message'],
                                    textAlign: data['from'] == widget.uid
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: TextStyle(
                                        fontFamily: 'ReadexPro',
                                        color: data['from'] == widget.uid
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  subtitle: Text(
                                    formatTimestamp(
                                        data['timestamp'] as Timestamp),
                                    textAlign: data['from'] == widget.uid
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromARGB(153, 98, 255, 103),
                                        fontFamily: 'ReadexPro'),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      top: 20,
                                      bottom: 20,
                                      right:
                                          data['from'] == widget.uid ? 20 : 0,
                                      left:
                                          data['from'] == widget.uid ? 0 : 20),
                                  tileColor: data['from'] == widget.uid
                                      ? const Color.fromARGB(255, 0, 0, 0)
                                      : const Color.fromARGB(
                                          255, 247, 219, 219),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          data['from'] == widget.uid
                                              ? 50.0
                                              : 0.0),
                                      topRight: Radius.circular(
                                          data['from'] != widget.uid
                                              ? 50.0
                                              : 0.0),
                                      bottomLeft: Radius.circular(50.0),
                                      bottomRight: Radius.circular(50.0),
                                    ),
                                  ),
                                  trailing: data['from'] == widget.uid
                                      ? null
                                      : SizedBox(
                                          width: 0,
                                        ),
                                  leading: data['from'] == widget.uid
                                      ? SizedBox(
                                          width: 25,
                                        )
                                      : null,
                                  onLongPress: () {
                                    if (fromId == widget.uid) {
                                      deleteDocumentId = documentId;
                                      setState(() {
                                        isDeleteButtonVisible = true;
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: TextField(
                          focusNode: _focusNode,
                          scrollPadding: const EdgeInsets.all(50),
                          maxLines: null,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(25),
                              labelText: 'Type message...',
                              labelStyle: const TextStyle(
                                  fontFamily: 'ReadexPro',
                                  color: Color.fromARGB(157, 0, 0, 0)),
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 0.1,
                                      color: Color.fromARGB(54, 0, 0, 0)),
                                  borderRadius: BorderRadius.circular(50))),
                          controller: chatMessage,
                        ))),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(
                        50,
                      )),
                  child: IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
