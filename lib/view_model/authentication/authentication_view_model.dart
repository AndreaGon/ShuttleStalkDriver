import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../view/main_view.dart';

class AuthenticationVM {

  CollectionReference drivers = FirebaseFirestore.instance.collection('drivers');

  Future<void> loginUser(BuildContext context, String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Logged IN!"),
      ));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainView(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("User doesn't exist! Please register yourself."),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wrong password!"),
        ));
      }
    }
  }


  Future getCurrentUserWithEmail(String email) async{
    return await drivers.where('email', isEqualTo: email)
        .get();
  }

  void updatePassword(BuildContext context, String password) async{
    //Create an instance of the current user.
    final user = await FirebaseAuth.instance.currentUser;

    //Pass in the password to updatePassword.
    user?.updatePassword(password).then((_){
      Navigator.pop(context, "Yes, I'm sure");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Successfully changed password. Please log in again using your new password."),
      ));

      print("Successfully changed password");
    }).catchError((error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: " + error.toString()),
      ));
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }


  Future signOut() async{
    await FirebaseAuth.instance.signOut();
  }
}