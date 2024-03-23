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
  // ignore: prefer_final_fields
  ScrollController _scrollController = ScrollController();
  // ignore: prefer_final_fields
  FocusNode _focusNode = FocusNode();

  // ignore: non_constant_identifier_names
  String user_profile_image = '';
  bool isDeleteButtonVisible = false;

  // ignore: non_constant_identifier_names
  String user_name = '';
  String deleteDocumentId = '';

  String currentChatId = '';
  List<String> visibleChatIds = [];

  bool isBlocked = false;
  bool other_blocked = false;

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
          'timestamp': DateTime.now(),
          'isRead': false
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
    // String formattedDate =
    //     DateFormat('dd/MM/yy').format(dateTime); // Format date as "dd/MM/yy"
    return formattedTime; // Combine time and date  [ - $formattedDate ]
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
      _scrollToBottom();
    } catch (e) {
      // An error occurred while deleting the document
      print('Error deleting chat document: $e');
    }
  }

  @override
  initState() {
    super.initState();
    // to scroll down at the bottom
    // _scrollToBottom();
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

    _scrollController.addListener(_onScroll);
    // check for if the user is blocked or not
    check_for_block();
    check_for_other_block();
  }

  void _onScroll() {
    // Check if the user has scrolled to the bottom of the chat
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // update the next added chat message isRead as well
      updateIsRead(currentChatId);
    }
  }

  List<String> getVisibleChatIds(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<String> visibleChatIds = [];

    // Get the position of the first and last visible items in the viewport
    double topPosition = _scrollController.position.pixels;
    double bottomPosition = _scrollController.position.pixels +
        _scrollController.position.viewportDimension;

    // Iterate over the chat messages and check if they are within the viewport
    for (int i = 0; i < snapshot.data!.docs.length; i++) {
      double itemPosition = _getItemPosition(i);
      if (itemPosition >= topPosition && itemPosition <= bottomPosition) {
        // send the other person id chats only
        if (snapshot.data!.docs[i]['from'] != widget.uid) {
          visibleChatIds.add(snapshot.data!.docs[i].id);
        }
      }
    }

    return visibleChatIds;
  }

  double _getItemPosition(int index) {
    // Calculate the position of the item at the given index
    RenderBox itemRenderBox = _getItemRenderBox(index);
    return itemRenderBox.localToGlobal(Offset.zero).dy;
  }

  RenderBox _getItemRenderBox(int index) {
    // Get the render box of the item at the given index
    GlobalKey itemKey = _getItemKey(index);
    return itemKey.currentContext!.findRenderObject() as RenderBox;
  }

  GlobalKey _getItemKey(int index) {
    // Create a unique key for each item
    return GlobalKey();
  }

  Future<void> updateIsRead(String chatId) async {
    try {
      // Reference to the chat document in Firestore
      DocumentReference chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

      // Update the isRead field to true
      await chatDocRef.update({'isRead': true});
      print('isRead updated successfully');
    } catch (e) {
      print('Error updating isRead: $e');
    }
  }

  void show_block_dialog(String block_status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // ignore: prefer_const_constructors, avoid_unnecessary_containers
        return Container(
          child: Column(children: <Widget>[
            AlertDialog(
                backgroundColor: Colors.black,
                // ignore: prefer_const_constructors
                title: Text("Blocked",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'ReadexPro',
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                // ignore: prefer_const_literals_to_create_immutables
                content: Text(
                  textAlign: TextAlign.center,
                  block_status == 'other_blocked'
                      ? 'You have been blocked'
                      : 'You have blocked \n this user',
                  style: const TextStyle(
                      fontFamily: 'ReadexPro',
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ))
          ]),
        );
      },
    );
  }

  void removeFriend(String userIdToRemove, String currentUserUid) async {
    try {
      // Get the reference to the document where 'userId' matches 'currentUserUid'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUserUid)
          .get();

      // Ensure there is a matching document
      if (querySnapshot.docs.isNotEmpty) {
        // Get the reference to the first document in the query result
        DocumentReference currentUserRef = querySnapshot.docs.first.reference;

        // Update the document to remove the userIdToRemove from the 'friend' array
        await currentUserRef.update({
          'friend': FieldValue.arrayRemove([userIdToRemove]),
        });

        print('Friend removed successfully.');
      } else {
        print('No document found with userId: $currentUserUid');
      }
    } catch (error) {
      print('Error removing friend: $error');
    }
  }

  void check_for_block() async {
    // check if the user is blocked or not and then set a boolean value according to that
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.uid)
        .limit(1)
        .get();

    // Check if any documents are found with the matching userId
    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve the first document (since we used limit(1))
      DocumentSnapshot userSnapshot = querySnapshot.docs.first;

      // Check if the user exists and get their current block list
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Check if userData is not null and contains the 'block' key
      if (userData != null && userData.containsKey('block')) {
        List<dynamic>? blockList = userData['block'];
        if (blockList!.contains(widget.userId)) {
          setState(() {
            // change the value of the block boolean variable
            isBlocked = true;
          });
        }
      }
    }
  }

  // check for other person block as well
  void check_for_other_block() async {
    // check if the user is blocked or not and then set a boolean value according to that
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.userId)
        .limit(1)
        .get();

    // Check if any documents are found with the matching userId
    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve the first document (since we used limit(1))
      DocumentSnapshot userSnapshot = querySnapshot.docs.first;

      // Check if the user exists and get their current block list
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Check if userData is not null and contains the 'block' key
      if (userData != null && userData.containsKey('block')) {
        List<dynamic>? blockList = userData['block'];
        if (blockList!.contains(widget.uid)) {
          setState(() {
            // change the value of the block boolean variable
            isBlocked = true;
            other_blocked = true;
          });
        }
      }
    }
  }

  void add_in_block() async {
    // Query the Firestore collection to find the document with the matching userId
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.uid)
        .limit(1)
        .get();

    // Check if any documents are found with the matching userId
    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve the first document (since we used limit(1))
      DocumentSnapshot userSnapshot = querySnapshot.docs.first;

      // Check if the user exists and get their current block list
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Check if userData is not null and contains the 'block' key
      if (userData != null && userData.containsKey('block')) {
        List<dynamic>? blockList = userData['block'];
        blockList?.add(widget.userId);

        // Update the blockList in the user document
        await userSnapshot.reference.update({'block': blockList});
      }
    }
  }

  void remove_from_block() async {
    // Query the Firestore collection to find the document with the matching userId
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: widget.uid)
        .limit(1)
        .get();

    // Check if any documents are found with the matching userId
    if (querySnapshot.docs.isNotEmpty) {
      // Retrieve the first document (since we used limit(1))
      DocumentSnapshot userSnapshot = querySnapshot.docs.first;

      // Check if the user exists and get their current block list
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // Check if userData is not null and contains the 'block' key
      if (userData != null && userData.containsKey('block')) {
        List<dynamic>? blockList = userData['block'];

        // Remove widget.userId from the blockList if it exists
        blockList?.remove(widget.userId);

        // Update the blockList in the user document
        await userSnapshot.reference.update({'block': blockList});
        setState(() {
          isBlocked = false;
        });
      }
    }
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionButton(
                icon: Icons.delete,
                text: "Remove",
                onPressed: () {
                  // remove this user from my friend list
                  removeFriend(widget.userId, widget.uid);
                  Navigator.pop(context); // Close the dialog
                },
              ),
              _buildOptionButton(
                icon: Icons.block,
                text: isBlocked || other_blocked ? 'Unblock' : 'Block',
                onPressed: () {
                  print('block button has been called');
                  if (isBlocked) {
                    // change the block status
                    remove_from_block();
                  } else {
                    add_in_block();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
      {required IconData icon,
      required String text,
      required Function() onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.red,
            size: 25,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
                fontFamily: 'ReadexPro', color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> groupMessagesByDate(
      QuerySnapshot snapshot) {
    Map<String, List<Map<String, dynamic>>> groupedMessages = {};

    snapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String documentId = document.id; // Get the document ID
      DateTime timestamp = data['timestamp'].toDate();
      String date =
          DateFormat.yMMMMd().format(timestamp); // Format date as desired
      // Add document ID to the message data
      data['documentId'] = documentId;
      groupedMessages.putIfAbsent(date, () => []).add(data);
    });

    return groupedMessages;
  }

  @override
  void dispose() {
    // Dispose the controllers
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // scroll down to the bottom

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(); // Call the scroll to bottom method
    });
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
          // IconButton(
          //     onPressed: () {
          //       _scrollToBottom(); // Call the scroll to bottom method
          //     },
          //     icon: Icon(Icons.vertical_align_bottom)),
          // conditionally
          if (isDeleteButtonVisible)
            isDeleteButtonVisible
                ? IconButton(
                    onPressed: () {
                      deletechat(deleteDocumentId);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
                : SizedBox(),
          // show a popup dialog to user to show his
          IconButton(
              onPressed: () {
                _showOptionsDialog(context); // Open the dialog
              },
              icon: const Icon(Icons.more_vert))
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      Map<String, List<Map<String, dynamic>>> groupedMessages =
                          groupMessagesByDate(snapshot.data!);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: groupedMessages.entries.map((entry) {
                          String date = entry.key;
                          List<Map<String, dynamic>> messages = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  date,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'ReadexPros'),
                                ),
                              ),
                              ...messages.map((messageData) {
                                String fromId = messageData['from'];
                                String documentId = messageData['documentId'];

                                bool isRead = messageData['isRead'] ?? false;

                                if (!isRead && fromId == widget.userId) {
                                  // Update the isRead field for the current document
                                  FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(documentId)
                                      .update({'isRead': true});
                                }

                                // should be scroll down at the bottom
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 1),
                                  curve: Curves.easeOut,
                                );

                                return Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width,
                                      minWidth: 100),
                                  margin: EdgeInsets.only(
                                    top: 10,
                                    left: fromId == widget.uid ? 135 : 0,
                                    right: fromId == widget.uid ? 0 : 135,
                                  ),
                                  width: 100,
                                  child: ListTile(
                                    title: Text(
                                      messageData['message'],
                                      textAlign: fromId == widget.uid
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: 'ReadexPro',
                                        color: fromId == widget.uid
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment: fromId == widget.uid
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          formatTimestamp(
                                              messageData['timestamp']
                                                  as Timestamp),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(
                                                153, 255, 255, 255),
                                            fontFamily: 'ReadexPro',
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        // read recipt
                                        if (fromId ==
                                            widget
                                                .uid) // Only show read receipt for messages sent by the user
                                          Text(
                                            messageData['isRead'] == true
                                                ? 'Seen'
                                                : 'Sent',
                                            // ignore: prefer_const_constructors
                                            style: TextStyle(
                                              fontFamily: 'ReadexPro',
                                              color: messageData['isRead'] ==
                                                      true
                                                  ? Colors.green
                                                  : Colors
                                                      .blue, // Customize color as needed
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.only(
                                      top: 20,
                                      bottom: 20,
                                      right: fromId == widget.uid ? 20 : 0,
                                      left: fromId == widget.uid ? 0 : 20,
                                    ),
                                    tileColor: fromId == widget.uid
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : const Color.fromARGB(
                                            255, 247, 219, 219),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            fromId == widget.uid ? 50.0 : 0.0),
                                        topRight: Radius.circular(
                                            fromId != widget.uid ? 50.0 : 0.0),
                                        bottomLeft: Radius.circular(50.0),
                                        bottomRight: Radius.circular(50.0),
                                      ),
                                    ),
                                    trailing: fromId == widget.uid
                                        ? null
                                        : SizedBox(width: 0),
                                    leading: fromId == widget.uid
                                        ? SizedBox(width: 25)
                                        : null,
                                    onLongPress: () {
                                      if (fromId == widget.uid) {
                                        setState(() {
                                          isDeleteButtonVisible = true;
                                          deleteDocumentId = documentId;
                                        });
                                      }
                                    },
                                    onTap: () {
                                      setState(() {
                                        isDeleteButtonVisible = false;
                                        deleteDocumentId = '';
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                          constraints: const BoxConstraints(maxHeight: 100),
                          child: TextField(
                            onTap: () {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            // focusNode: _focusNode,
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
                        print(
                            '$other_blocked and $isBlocked for send message button click');
                        // if the user is not block then send message only
                        if (!isBlocked && !other_blocked) {
                          sendMessage();
                        }
                        // check if you have been blocked out by other gus
                        if (other_blocked) {
                          show_block_dialog('other_blocked');
                        }
                        if (isBlocked) {
                          show_block_dialog('me_blocked');
                        }
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
          )
        ],
      ),
    );
  }
}
