import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shuttle_stalk_driver/view_model/report/report_view_model.dart';

import '../../res/colors.dart';
import '../../view_model/journey/journey_view_model.dart';

class ReportView extends StatefulWidget {
  String journeyId;
  String date;
  String time;
  String routeId;
  String driverId;
  String routeName;

  Function onSubmittedReport;

  ReportView({Key? key, required this.journeyId, required this.date, required this.time, required this.routeId, required this.driverId, required this.routeName, required this.onSubmittedReport}) : super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final content = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String dropdownValue = "";
  List items = ["Accident", "Traffic Issues", "Shuttle Maintenance", "Others"];

  ReportVM reportVM = ReportVM();
  JourneyVM journeyVM = JourneyVM();

  @override
  void initState() {
    dropdownValue = items[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 75,
          automaticallyImplyLeading: false,
          title: Text("Emergency Reporting",style: TextStyle(color:Colors.white,fontSize:20, fontWeight: FontWeight.bold)),
          backgroundColor: lightblue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
                  const Text("Tell us why you're cancelling",
                      style: TextStyle(height: 3, fontSize: 20, fontWeight: FontWeight.bold, color: darkblue)
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        value: dropdownValue,
                        elevation: 16,
                        style: const TextStyle(color: darkblue),
                        onChanged: (value) {

                          setState(() {
                            dropdownValue = value!.toString();
                          });
                        },
                        items: items.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                    child: TextFormField(
                        maxLines: 10,
                        obscureText: false,
                        controller: content,
                        decoration: const InputDecoration(
                            labelText: 'Enter more information',
                            filled: true,
                            fillColor: Color(0xFFD2D2D2)
                        )
                    ),
                  ),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: lightblue,
                        minimumSize: Size.fromHeight(40),
                      ),
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Submit report?'),
                            content: const Text("This will cancel your current journey and notify students and admins."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => {

                                  reportVM.createNotification(dropdownValue, content.text, widget.driverId, widget.routeName).then((value) async => {
                                    Navigator.pop(context),
                                    journeyVM.endJourney(widget.journeyId, widget.date, widget.time, widget.routeId).then((value) => {
                                      Navigator.pop(context),
                                    }),

                                    reportVM.sendCancellationNotification(widget.date, widget.time, widget.routeName, dropdownValue).then((value) => {

                                    }),


                                    content.text = "",
                                    widget.onSubmittedReport()
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
                      child: const Text("Submit Report and Cancel Journey")
                  ),

                ],
              ),
            )
        ),
      )
    );
  }
}
