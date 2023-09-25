import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shuttle_stalk_driver/view_model/authentication/authentication_view_model.dart';

import '../../res/colors.dart';
import '../authentication/login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  AuthenticationVM authVM = AuthenticationVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 75,
          automaticallyImplyLeading: false,
          title: Center(child: Text("Driver Profile",style: TextStyle(color:Colors.white,fontSize:20, fontWeight: FontWeight.bold))),
          backgroundColor: lightblue
      ),
      body: Container(
        margin: new EdgeInsets.all(15.0),
        child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text("Email",
                //     style: TextStyle(height: 3, fontSize: 20, fontWeight: FontWeight.bold, color: darkblue)
                // ),
                // Container(
                //   margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                //   child: TextFormField(
                //       readOnly: true,
                //       obscureText: false,
                //       controller: email,
                //       decoration: const InputDecoration(
                //           labelText: 'Email',
                //           filled: true, //<-- SEE HERE
                //           fillColor: Color(0xFFD2D2D2)
                //       )
                //   ),
                // ),

                const Text("New Password",
                    style: TextStyle(height: 3, fontSize: 20, fontWeight: FontWeight.bold, color: darkblue)
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                  child: TextFormField(
                      obscureText: true,
                      controller: password,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          filled: true, //<-- SEE HERE
                          fillColor: Color(0xFFD2D2D2)
                      )
                  ),
                ),

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: lightblue,
                      minimumSize: Size.fromHeight(40), // fromHeight use double.infinity as width and 40 is the height
                    ),
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text("This will change your account password."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => {
                                authVM.updatePassword(context, password.text)
                              },
                              child: const Text("Yes, I'm sure"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Change Password")
                ),

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: red,
                      minimumSize: Size.fromHeight(40), // fromHeight use double.infinity as width and 40 is the height
                    ),
                    onPressed: () {
                      authVM.signOut().then((value) => {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Logged out successfully!"),
                        )),
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                        )
                      });
                    },
                    child: const Text("Logout")
                )
              ],
            )
        ),
      )
    );
  }
}
