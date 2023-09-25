import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../res/colors.dart';
import '../../view_model/authentication/authentication_view_model.dart';

class Login extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  AuthenticationVM authVM = AuthenticationVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: darkblue,
        appBar: null,
        body: Container(
            margin: new EdgeInsets.all(15.0),
            child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Login to Shuttle Stalk (Driver)",
                        style: TextStyle(height: 5, fontSize: 25, color: white)
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: TextFormField(
                          obscureText: false,
                          controller: email,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              filled: true, //<-- SEE HERE
                              fillColor: white
                          )
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: password,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            filled: true,
                            fillColor: white
                        ),
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: lightblue,
                          minimumSize: Size.fromHeight(40), // fromHeight use double.infinity as width and 40 is the height
                        ),
                        onPressed: () {
                          if(formKey.currentState!.validate()){
                            var driverInfo;
                            authVM.getCurrentUserWithEmail(email.text.trim()).then((value) => {
                              driverInfo = value.docs.map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>).toList(),
                              if(driverInfo.length != 0){
                                authVM.loginUser(context, email.text.trim(), password.text.trim())
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Driver Not Found! Please see AFM office."),
                                ))
                              }
                            });
                          }
                        },
                        child: const Text("Login")
                    )
                  ],
                )
            )
        )
    );
  }
}
