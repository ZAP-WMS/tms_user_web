import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<bool> checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('isLogin') ?? false;
    return isLogin;
  }

  Future<String> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userID') ?? '';

    return userId;
  }

  getUserName(String userId) async {
    List<String> memberRole = [];
    try {
      // Fetch all documents from the 'members' collection
      QuerySnapshot querySnapshot = await _firestore
          .collection('members')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<dynamic> roles = querySnapshot.docs[0]['role'];
        for (var role in roles) {
          print(role);
          memberRole.add(role);
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return memberRole;
  }

  void removeLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
  }

  Future<bool> checkUserRole(String userId) async {
    try {
      // Get the user document from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('members').doc(userId).get();

      if (userDoc.exists) {
        // Check if 'role' field exists and is a non-empty array
        List? role = userDoc.get('role') as List<dynamic>?;
        return role != null && role.isNotEmpty;
      } else {
        print('User not found');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
