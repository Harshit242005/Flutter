import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyAppLifecycleObserver with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid;

  MyAppLifecycleObserver(this.uid);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _updateUserStatus(uid, 'online');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _updateUserStatus(uid, 'offline');
        break;
      default:
        break;
    }
  }

  void _updateUserStatus(String userId, String status) async {
    try {
      // Query Firestore for the user document matching the provided userId
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        // Update the status field of the first matching document
        await _firestore
            .collection('users')
            .doc(querySnapshot.docs.first.id)
            .update({'status': status});
        print(
            'user with id: $userId status has now been updated with new status: $status');
      } else {
        // Handle the case where no matching user document is found
        print('No user document found for userId: $userId');
      }
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating user status: $error');
    }
  }
}
