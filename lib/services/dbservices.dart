import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/dataclass.dart';

CollectionReference tblTask = FirebaseFirestore.instance.collection("task");

class Database {
  static Stream<QuerySnapshot> getData(
      {required String field,
      required String condition,
      String? title,
      required String userUid}) {
    if (title == "") {
      return tblTask
          .where('userUid', isEqualTo: userUid)
          .where(field, isEqualTo: condition)
          .orderBy('datetime')
          .snapshots();
    } else if (title == "listtask") {
      return tblTask
          .where('userUid', isEqualTo: userUid)
          .where(field, isEqualTo: condition)
          .orderBy('datetime', descending: true)
          .snapshots();
    }
    return tblTask
        .where('userUid', isEqualTo: userUid)
        .where(field, isEqualTo: condition)
        .orderBy('title')
        .startAt([title]).endAt(['$title\uf8ff']).snapshots();
  }

  static Future<void> addData({required ItemTask item}) async {
    DocumentReference docRef = tblTask.doc(item.itemTitle);

    await docRef
        .set(item.toJson())
        // ignore: avoid_print
        .whenComplete(() => print("data berhasil diinput"))
        // ignore: avoid_print
        .catchError((e) => print(e));
  }

  static Future<void> updateData(
      {required String idDocs, required Map<String, String> data}) async {
    DocumentReference<Object?> docRef = tblTask.doc(idDocs);

    await docRef
        .update(data)
        // ignore: avoid_print
        .whenComplete(() => print("data berhasil diupdate"))
        // ignore: avoid_print
        .catchError((e) => print(e));
  }

  static Future<void> deleteData({required String docsName}) async {
    await tblTask.doc(docsName).delete();
  }
}
