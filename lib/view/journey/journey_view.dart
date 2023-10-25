import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../res/colors.dart';
import '../../res/env.dart' as ENV;


class JourneyView extends StatefulWidget {
  List<dynamic> allLocationPoints;
  JourneyView({Key? key, required this.allLocationPoints}) : super(key: key);

  @override
  State<JourneyView> createState() => _JourneyViewState();
}

class _JourneyViewState extends State<JourneyView> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> driverMarker = Set();

  LatLng defaultLocation = LatLng(5.3416, 100.2819);

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  LatLng lastDestination = LatLng(0.0, 0.0);



  void initState() {
    initAllPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getPolyline(defaultLocation.longitude, defaultLocation.latitude, lastDestination.longitude, lastDestination.latitude);
    return Scaffold(
      appBar: AppBar(
        title: Text("Pickup/Dropoff Points"),
        backgroundColor: lightblue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: defaultLocation,
                zoom: 13.5,
              ),
              markers: driverMarker,
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            )

          ],
        )

    );
  }

  void initAllPoints() {
    LatLng bookingLocations = LatLng(0.0,0.0);
    double isSame = 0.0;
    driverMarker.add(Marker(markerId: MarkerId("driver"), position: defaultLocation));
    for(var i = 0; i < widget.allLocationPoints.length; i++){
      bookingLocations = LatLng(widget.allLocationPoints[i].latitude, widget.allLocationPoints[i].longitude);
      driverMarker.add(Marker(markerId: MarkerId("location"), position: bookingLocations, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));

      if(i == widget.allLocationPoints.length - 1){
        lastDestination = LatLng(widget.allLocationPoints[i].latitude, widget.allLocationPoints[i].longitude);
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    polylines = {};
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      color: lightblue,
      width: 8,
    );

    polylines[id] = polyline;
    if(mounted){
      setState(() {});
    }
  }

  void getPolyline(sourceLong, sourceLat, driverLong, driverLat) async {
    List<LatLng> polylineCoordinates = [];
    polylineCoordinates.clear();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      ENV.GOOGLE_API_KEY,
      PointLatLng(sourceLat, sourceLong),
      PointLatLng(driverLat, driverLong),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }
}
