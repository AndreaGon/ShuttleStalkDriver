import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shuttle_stalk_driver/view_model/report/report_view_model.dart';

import '../../res/colors.dart';

class ReportView extends StatefulWidget {
  const ReportView({Key? key}) : super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final title = TextEditingController();
  final content = TextEditingController();
  final formKey = GlobalKey<FormState>();

  ReportVM reportVM = ReportVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 75,
          automaticallyImplyLeading: false,
          title: Center(child: Text("Emergency Reporting",style: TextStyle(color:Colors.white,fontSize:20, fontWeight: FontWeight.bold))),
          backgroundColor: lightblue
      ),
      body: Container(
        margin: new EdgeInsets.all(15.0),
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Notify Students",
                      style: TextStyle(height: 3, fontSize: 20, fontWeight: FontWeight.bold, color: darkblue)
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                    child: TextFormField(
                        obscureText: false,
                        controller: title,
                        decoration: const InputDecoration(
                            labelText: 'Enter title',
                            filled: true, //<-- SEE HERE
                            fillColor: Color(0xFFD2D2D2)
                        )
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                    child: TextFormField(
                        maxLines: 10,
                        obscureText: false,
                        controller: content,
                        decoration: const InputDecoration(
                            labelText: 'Enter content',
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
                            title: const Text('Submit notification?'),
                            content: const Text("This will notify all the students."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => {

                                  reportVM.createNotification(title.text, content.text).then((value) => {
                                    Navigator.pop(context, 'Yes'),
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Notification sent"),
                                    )),

                                    title.text = "",
                                    content.text = ""
                                  })
                                  .catchError((error)=>{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Error: " + error.toString()),
                                    ))
                                  })

                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Submit")
                  ),

                ],
              ),
            )
        ),
      )
    );
  }
}
