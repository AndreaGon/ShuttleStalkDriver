import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:shuttle_stalk_driver/res/env.dart';
import 'package:uuid/uuid.dart';


class ReportVM {
  CollectionReference announcements = FirebaseFirestore.instance.collection('announcements');

  Future<void> createNotification(String title, String content, String driverId, String routeName) async {
    var uuid = Uuid();
    var uuidV4 = uuid.v4();
    announcements.doc(uuidV4).set({
      'id': uuidV4,
      'title': "Journey cancellation for " + routeName + " due to " + title,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'createdBy': driverId
    }).then((value) => {

    });
  }

  Future sendCancellationNotification(String date, String time, String routeName, String reason) async{
    var data =  {
      "title": "Driver Cancelled Journey",
      "content": "Journey for ${routeName} on ${date} at ${time} has been cancelled by the driver due to the following reasons: ${reason}",
    };

    final response =  await Dio().post('${API_URL}/announcements/send-notif', data: data);
  }
}
