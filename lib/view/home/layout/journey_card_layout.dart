
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shuttle_stalk_driver/view_model/journey/journey_view_model.dart';

import '../../../res/colors.dart';
import '../../journey/journey_view.dart';
import '../../report/report_view.dart';

class JourneyCardLayout extends StatefulWidget {
  String routeName;
  String pickupDropoff;
  String bookingTime;
  String bookingDate;
  String journeyId;
  bool isJourneyStarted;
  String driverId;
  String routeId;
  List<dynamic> allLocationPoints;
  Function onJourneyPressed;

  JourneyCardLayout({Key? key, required this.routeName, required this.pickupDropoff, required this.bookingTime, required this.bookingDate, required this.journeyId, required this.isJourneyStarted, required this.onJourneyPressed, required this.driverId, required this.allLocationPoints, required this.routeId}) : super(key: key);

  @override
  State<JourneyCardLayout> createState() => _JourneyCardLayoutState();
}

class _JourneyCardLayoutState extends State<JourneyCardLayout> {
  String latitude = 'waiting...';
  String longitude = 'waiting...';

  JourneyVM journeyVM = JourneyVM();

  bool showStartJourney = true;
  bool showEndJourney = false;

  var timer;
  bool isJourneyStopped = true;
  LatLng shuttleLocation = LatLng(0.0, 0.0);
  LatLng defaultSchoolLocation = LatLng(5.3416, 100.2819);
  //LatLng defaultSchoolLocation = LatLng(5.3180, 100.2697);

  void initState() {
    super.initState();

    if(widget.isJourneyStarted){
      journeyVM.getStartedJourneys(widget.driverId).then((value) => {
        if(value.docs.length == 0){
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Start Journey?'),
              content: const Text("This will start your journey and send your real time location to the students."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    determinePosition().then((currentPosition) async => {
                      await journeyVM.updateStartJourney(widget.journeyId, true).then((value) => {}),
                      shuttleLocation = LatLng(currentPosition.latitude, currentPosition.longitude),
                      journeyVM.updateDriverLocation(widget.journeyId, shuttleLocation).then((value) => {}),
                      isJourneyStopped = false,
                      refreshState(),
                      runLocationTimer(),
                    }).catchError((onError)=>{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please turn on your location!"),
                      ))
                    }),
                  },
                  child: const Text("Yes, I'm sure"),
                ),
              ],
            ),
          )
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("You cannot start another journey without ending your previous journey!"),
          ))
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(25.0),
        child:  Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 15.0),
                child: Text(widget.routeName + " (" + widget.pickupDropoff.toUpperCase() + ")", style: TextStyle(color: darkblue, fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 15.0),
                child: Text("Date: " + widget.bookingDate, style: TextStyle(fontSize: 15.0, color: darkblue)),
              ),

              Padding(
                padding: EdgeInsets.only(top: 15.0, left: 15.0),
                child: Text("Time: " + widget.bookingTime, style: TextStyle(fontSize: 15.0, color: darkblue)),
              ),

              Visibility(
                  visible: !widget.isJourneyStarted,
                  child: Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 25, right: 20, top: 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    child: ElevatedButton(
                      child: Text("Start Journey", style: TextStyle(color: darkblue),),
                      style: ElevatedButton.styleFrom(
                        primary: skyblue,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        journeyVM.getStartedJourneys(widget.driverId).then((value) => {
                          if(value.docs.length == 0){
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Start Journey?'),
                                content: const Text("This will start your journey and send your real time location to the students."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.of(context).pop(),
                                      determinePosition().then((currentPosition) async => {
                                        await journeyVM.updateStartJourney(widget.journeyId, true).then((value) => {}),
                                        shuttleLocation = LatLng(currentPosition.latitude, currentPosition.longitude),
                                        journeyVM.updateDriverLocation(widget.journeyId, shuttleLocation).then((value) => {}),
                                        isJourneyStopped = false,
                                        refreshState(),
                                        runLocationTimer(),
                                      }).catchError((onError)=>{
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Please turn on your location!"),
                                        ))
                                      }),
                                    },
                                    child: const Text("Yes, I'm sure"),
                                  ),
                                ],
                              ),
                            )
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("You cannot start another journey without ending your previous journey!"),
                            ))
                          }
                        });

                      },
                    ),
                  )
              )
              ),

              Visibility(
                  visible: !widget.isJourneyStarted,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 5, left: 25, right: 20, top: 15),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: ElevatedButton(
                          child: Text("Cancel Journey", style: TextStyle(color: white),),
                          style: ElevatedButton.styleFrom(
                            primary: red,
                            elevation: 0,
                          ),
                          onPressed: () async {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Cancel journey?'),
                                content: const Text("This will cancel your current journey and open reporting."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async => {
                                      Navigator.of(context).pop(),
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReportView(journeyId: widget.journeyId, date: widget.bookingDate, time: widget.bookingTime, routeId: widget.routeId, driverId: widget.driverId, routeName: widget.routeName, onSubmittedReport: ()=>{},),
                                        ),
                                      ).then((value) => {
                                        refreshState()
                                      }),

                                    },
                                    child: const Text("Yes, I'm sure"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                  )
              ),

              Visibility(
                  visible: widget.isJourneyStarted,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 5, left: 25, right: 20, top: 30),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: ElevatedButton(
                          child: Text("View Pickup/Dropoff points", style: TextStyle(color: darkblue),),
                          style: ElevatedButton.styleFrom(
                            primary: skyblue,
                            elevation: 0,
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JourneyView(allLocationPoints: widget.allLocationPoints),
                              ),
                            );
                          },
                        ),
                      )
                  )
              ),

              Visibility(
                  visible: widget.isJourneyStarted,
                  child: Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 25, right: 20, top: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    child: ElevatedButton(
                      child: Text("End Journey", style: TextStyle(color: white),),
                      style: ElevatedButton.styleFrom(
                        primary: red,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        var proximityThreshold = 200.0;
                        var currDistance;
                        determinePosition().then((value) => {
                          currDistance = distanceCalculation(defaultSchoolLocation.latitude, defaultSchoolLocation.longitude, value.latitude, value.longitude),
                          if(currDistance <= proximityThreshold){
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('End journey?'),
                                content: const Text("This will stop real time updates and mark this journey as complete."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async => {
                                      Navigator.of(context).pop(),

                                      isJourneyStopped = true,
                                      await journeyVM.endJourney(widget.journeyId, widget.bookingDate, widget.bookingTime, widget.routeId).then((value) async => {}),

                                      await journeyVM.getStudentIdsFromBooking(widget.bookingDate, widget.bookingTime, widget.routeId).then((value) => {
                                        journeyVM.updateStudentNoShow(value).then((value) => {})
                                      }),
                                      refreshState()
                                    },
                                    child: const Text("Yes, I'm sure"),
                                  ),
                                ],
                              ),
                            ),
                          }
                          else{
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('End journey early?'),
                                content: const Text("You seem to be ending your journey too early. Proceed?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async => {
                                      Navigator.pop(context),
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReportView(journeyId: widget.journeyId, date: widget.bookingDate, time: widget.bookingTime, routeId: widget.routeId, driverId: widget.driverId, routeName: widget.routeName, onSubmittedReport: () => {
                                            isJourneyStopped = true,
                                            Navigator.pop(context),
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text("Successfully cancelled journey and notiifed students and admins"),
                                            )),
                                          },),
                                        ),
                                      ).then((value) => {
                                        refreshState()
                                      }),
                                    },
                                    child: const Text("Yes, I'm sure"),
                                  ),
                                ],
                              ),
                            ),
                          }
                        });
                      },
                    ),
                  )
              )
              ),
            ],
          ),
        )
    );
  }

  runLocationTimer() {
    var currDistance;
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      // if(isJourneyStopped){
      //   stopLocationTimer();
      // }
      // else{
      //   determinePosition().then((value) => {
      //     shuttleLocation = LatLng(value.latitude, value.longitude),
      //     journeyVM.updateDriverLocation(widget.journeyId, shuttleLocation).then((value) => {
      //
      //     }),
      //   });
      // }
      var proximityThreshold = 200.0;
      if(isJourneyStopped){
        stopLocationTimer();
      }
      else{

        determinePosition().then((currentPosition)=>{
          //print("LOCATION " + shuttleLocation.toString()),
          print("CURRENT " + currentPosition.toString()),

          currDistance = distanceCalculation(shuttleLocation.latitude, shuttleLocation.longitude, currentPosition.latitude, currentPosition.longitude),
          print("CURRENT DISTANCE: " + currDistance.toString()),

          if(currDistance >= proximityThreshold){
            shuttleLocation = LatLng(currentPosition.latitude, currentPosition.longitude),
            journeyVM.updateDriverLocation(widget.journeyId, shuttleLocation).then((value) => {

            }),
            shuttleLocation = LatLng(currentPosition.latitude, currentPosition.longitude),
            print("UPDATE FIREBASE " + currDistance.toString())
          }
          else{
            print("DONT UPDATE FIREBASE " + currDistance.toString())
          },

        }).catchError((onError)=>{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please turn on your location!"),
          ))
        });
      }
      refreshState();

    });
  }

  stopLocationTimer(){
    timer?.cancel();
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  double distanceCalculation(schoolLat, schoolLong, driverLat, driverLong) {
    return Geolocator.distanceBetween(schoolLat, schoolLong, driverLat, driverLong);
  }

  refreshState(){
    if(mounted){
      setState(() {
        widget.onJourneyPressed();
      });
    }
  }
}
