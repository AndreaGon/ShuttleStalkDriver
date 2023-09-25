import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JourneyVM {

  CollectionReference locationRef = FirebaseFirestore.instance.collection('locations');
  CollectionReference bookingRef = FirebaseFirestore.instance.collection('bookings');

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future getJourneys(String driverId) async{
    DateTime today = DateTime.now();
    String dateStr = today.toString().substring(0, 10);
    print("Date: " + dateStr);
    QuerySnapshot querySnapshot = await locationRef
        .where('driverId', isEqualTo: driverId)
        .where('is_journey_finished', isEqualTo: false)
        .where('date', isEqualTo: dateStr)
        .get();

    return querySnapshot;
  }

  Future getStartedJourneys(String driverId) async{
    QuerySnapshot querySnapshot = await locationRef
        .where('driverId', isEqualTo: driverId)
        .where('is_journey_started', isEqualTo: true)
        .get();

    return querySnapshot;
  }

  Future updateStartJourney(String id, bool isStarted) async {
    locationRef.doc(id).update({
      "is_journey_started": isStarted
    });
  }

  Future updateDriverLocation(String id, LatLng location) async {
    GeoPoint locationPoint = GeoPoint(location.latitude, location.longitude);
    locationRef.doc(id).update({
      "shuttleLocation": locationPoint
    });
  }

  Future endJourney(String id, String date, String time, String routeId) async {
    locationRef.doc(id).update({
      "is_journey_finished": true,
      "is_journey_started": false
    });
    try {
      QuerySnapshot querySnapshot = await bookingRef
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: time)
          .where('routeId', isEqualTo: routeId)
          .get();

      var batch = FirebaseFirestore.instance.batch();

      for(final booking in querySnapshot.docs){
        batch.update(booking.reference, { 'is_invalid': true });
        batch.commit();
      }

    } catch (e) {
      print(e);
    }
  }

  Future getStudentIdsFromBooking(String date, String time, String routeId) async {
    final bookings = await bookingRef
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .where('routeId', isEqualTo: routeId)
        .where('attendance_marked', isEqualTo: false)
        .get();

    List<String> studentIds = [];

    for(final booking in bookings.docs) {
      studentIds.add(booking["studentId"]);
    }

    return studentIds;
  }
  
  Future updateStudentNoShow(List<String> studentIds) async {
    var batch = FirebaseFirestore.instance.batch();

    for (final studentId in studentIds) {
      final DocumentReference studentRef = firestore.collection('students').doc(studentId);
        batch.update(studentRef,
        {"no_show": FieldValue.increment(1)}
      );
    }

    try {
      await batch.commit();
      print('Batch update successful');
    } catch (e) {
      print('Error during batch update: $e');
    }
  }


}