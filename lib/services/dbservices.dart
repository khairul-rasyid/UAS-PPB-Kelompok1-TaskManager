import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/dataclass.dart';

CollectionReference taskTable = FirebaseFirestore.instance.collection("task");

class Database {
  static Stream<QuerySnapshot> getData(
      {required String field,
      required String condition,
      String? title,
      required String userUid}) {
    if (title == "") {
      return taskTable
          .where('userUid', isEqualTo: userUid)
          .where(field, isEqualTo: condition)
          .orderBy('datetime')
          .snapshots();
    } else if (title == "listtask") {
      return taskTable
          .where('userUid', isEqualTo: userUid)
          .where(field, isEqualTo: condition)
          .orderBy('datetime', descending: true)
          .snapshots();
    }
    return taskTable
        .where('userUid', isEqualTo: userUid)
        .where(field, isEqualTo: condition)
        .orderBy('title')
        .startAt([title]).endAt(['$title\uf8ff']).snapshots();
  }

  static Future<void> addData({required ItemTask item}) async {
    DocumentReference docRef = taskTable.doc(item.itemTitle);

    await docRef
        .set(item.toJson())
        // ignore: avoid_print
        .whenComplete(() => print("data berhasil diinput"))
        // ignore: avoid_print
        .catchError((e) => print(e));
  }

  static Future<void> updateData(
      {required String idDocs, required Map<String, String> data}) async {
    DocumentReference<Object?> docRef = taskTable.doc(idDocs);

    await docRef
        .update(data)
        // ignore: avoid_print
        .whenComplete(() => print("data berhasil diupdate"))
        // ignore: avoid_print
        .catchError((e) => print(e));
  }

  static Future<void> deleteData({required String docsName}) async {
    await taskTable.doc(docsName).delete();
  }

  // static Future<int> getTaskCountByStatus(
  //     {required String userUid, required String status}) async {
  //   final query = taskTable
  //       .where("userUid", isEqualTo: userUid)
  //       .where("status", isEqualTo: status);
  //   final querysnapshot = await query.get();

  //   return querysnapshot.docs.length;
  // }

  static Stream<int> getTaskCountByStatusStream(
      {required String userUid, required String status}) async* {
    // Stream controller for emitting count updates
    final StreamController<int> countController = StreamController<int>();

    // Firestore query
    final query = taskTable
        .where("userUid", isEqualTo: userUid)
        .where("status", isEqualTo: status);

    // Get initial count (optional)
    final initialSnapshot = await query.get();
    countController.add(initialSnapshot.docs.length);

    // Listen for document changes and update count
    query.snapshots().listen((snapshot) {
      countController.add(snapshot.docs.length);
    });

    // Yield the count stream
    yield* countController.stream;
  }

  // static Map<String, Future<int>> getDataCountByStatus(String userUid) {
  //   final completedCount =
  //       getTaskCountByStatus(userUid: userUid, status: "completed");
  //   final pendingCount =
  //       getTaskCountByStatus(userUid: userUid, status: "completed");
  //   final canceledCount =
  //       getTaskCountByStatus(userUid: userUid, status: "completed");
  //   final onGoingCount =
  //       getTaskCountByStatus(userUid: userUid, status: "completed");

  //   return {
  //     "completed": completedCount,
  //     "pending": pendingCount,
  //     "canceled": canceledCount,
  //     "on going": onGoingCount,
  //   };
  // }
}
