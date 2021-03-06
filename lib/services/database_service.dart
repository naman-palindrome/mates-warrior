import 'package:covid_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FirestoreDatabaseService {
  /// Firestore instance variable
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  /// Create a new user in db
  static Future<void> createNewUser(UserModel newUser) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .set(newUser.toJson());
  }

  /// Update existing user
  static Future<void> updateUser(UserProfile userProfile, String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(userProfile.toJson());
  }

  /// Stream user from firestore
  static Stream<UserProfile> streamUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((event) => UserProfile.fromJson(event.data()));
  }

  /// Return object of user profile.
  static Future<UserProfile> getUser(String userId) async {
    DocumentSnapshot data =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return UserProfile.fromJson(data.data());
  }

  /// Create a new user profile in db
  static Future<void> createNewUserProfile( String uid , UserProfile newUser) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(newUser.toJson());
  }

  static Stream<QuerySnapshot> streamDonors(
      {String city, String state, @required String donorType , @required String timestampType}) {
    if (city != null && state == null) {
      return FirebaseFirestore.instance
          .collection('users')
          .where(donorType, isEqualTo: true)
          .where("city", isEqualTo: city)
          .snapshots();
    }
    if (city == null && state != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .where(donorType, isEqualTo: true)
          .where("state", isEqualTo: state)
          .snapshots();
    } 
    else if (city != null && state != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .where(donorType, isEqualTo: true)
          .where("city", isEqualTo: city)
          .where("state", isEqualTo: state)
          .snapshots();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .where(donorType, isEqualTo: true)
        .snapshots();
    
  }
}
