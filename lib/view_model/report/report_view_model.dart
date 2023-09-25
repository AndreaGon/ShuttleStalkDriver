import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';


class ReportVM {
  CollectionReference announcements = FirebaseFirestore.instance.collection('announcements');

  Future<void> createNotification(String title, String content) async {
    var uuid = Uuid();
    var uuidV4 = uuid.v4();
    announcements.doc(uuidV4).set({
      'id': uuidV4,
      'title': title,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }).then((value) => {

    });
  }
}
