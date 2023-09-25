import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shuttle_stalk_driver/view_model/authentication/authentication_view_model.dart';
import 'package:shuttle_stalk_driver/view_model/journey/journey_view_model.dart';

import '../../res/colors.dart';
import 'layout/journey_card_layout.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final JourneyVM journeyVM = JourneyVM();
  final AuthenticationVM authVM = AuthenticationVM();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 75,
          automaticallyImplyLeading: false,
          title: Center(child: Text("My Journey",style: TextStyle(color:Colors.white,fontSize:20, fontWeight: FontWeight.bold))),
          backgroundColor: lightblue
      ),
      body: FutureBuilder(
        future: authVM.getCurrentUserWithEmail(FirebaseAuth.instance.currentUser!.email ?? ""),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var driverData;
            driverData = snapshot.data?.docs.map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>).toList();

            return FutureBuilder(
              future: journeyVM.getJourneys(driverData[0]["id"]),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                if(!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var journeyData;
                journeyData = snapshot.data?.docs.map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>).toList();
                //print("DATA: " + journeyData.toString());
                if(snapshot.data?.docs.length != 0){
                  return ListView.builder(
                      itemCount:  snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        return JourneyCardLayout(driverId: journeyData[index]["driverId"], routeName: journeyData[index]["routeName"], pickupDropoff: journeyData[index]["pickupDropoff"], bookingTime: journeyData[index]["time"], bookingDate: journeyData[index]["date"], journeyId: journeyData[index]["id"], isJourneyStarted: journeyData[index]["is_journey_started"], onJourneyPressed: () {
                          setState(() {});
                        }, allLocationPoints: journeyData[index]["booking_locations"], routeId: journeyData[index]["routeId"],);
                      }
                  );
                }
                else{
                  return Padding(
                    padding: EdgeInsets.all(30.0),
                    child:  Container(
                      height: 50,
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
                      child: Padding(
                          padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                          child: Text("No journey today. All good!", style: TextStyle(color: darkblue, fontSize: 15.0))
                      ),
                    ),
                  );
                }
              },

            );
          },
        )
      );
  }
}
