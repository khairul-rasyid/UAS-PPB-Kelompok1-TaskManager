import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/services/dbservices.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ListTask extends StatelessWidget {
  final String field;
  final String condition;
  final String userUid;

  const ListTask(
      {super.key,
      required this.field,
      required this.condition,
      required this.userUid});

  @override
  Widget build(BuildContext context) {
    final String? title = condition.capitalize;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(flex: 5),
                  Text(
                    "$title Tasks",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF12175E)),
                  ),
                  const Spacer(flex: 6),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: Database.getData(
                    userUid: userUid,
                    field: field,
                    condition: condition,
                    title: 'listtask'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("ERROR");
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    );
                  } else if (snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 45),
                      child: Text(
                        "There haven't been any task yet...",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8A8BB3)),
                      ),
                    );
                  } else if (snapshot.hasData || snapshot.data != null) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DocumentSnapshot clData = snapshot.data!.docs[index];
                        DateTime utc8 =
                            (clData['datetime'] as Timestamp).toDate();
                        DateTime dateTime =
                            utc8.subtract(const Duration(hours: 8));
                        DateTime localTime = dateTime.toLocal();

                        String dtTitle = clData['title'];
                        String dtDate =
                            DateFormat('dd MMMM yyyy').format(localTime);
                        String dtTime = DateFormat('HH:mm').format(localTime);
                        String dtDesc = clData['desc'];
                        String dtStatus = clData['status'];
                        String dtTags = clData["tags"];

                        return _buildTask(
                            // index: index,
                            title: dtTitle,
                            date: dtDate,
                            time: dtTime,
                            desc: dtDesc,
                            status: dtStatus,
                            tags: dtTags);
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
                  }
                  return const Center(
                    child: Text("There haven't been any task yet..."),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTask({
    // required int index,
    required String title,
    required String date,
    required String time,
    required String desc,
    required String status,
    required String tags,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        tileColor: _tileColor(status: status),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        // leading: _icon(status: status),
        title: Text(
          title,
          style: const TextStyle(
              color: Color(0xFF12175E), fontWeight: FontWeight.w500),
        ),
        titleTextStyle: const TextStyle(fontSize: 18),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  date.toString(),
                  style: const TextStyle(
                    color: Color(0xFF9AA8C7),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(time.toString(),
                    style: const TextStyle(
                      color: Color(0xFF9AA8C7),
                    ))
              ],
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 6.0),
              decoration: BoxDecoration(
                  color: _tagColor(tags: tags),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                tags,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _tileColor({required String status}) {
    if (status == "pending") {
      return const Color(0xFFEEF0FF);
    } else if (status == "completed") {
      return const Color(0xFFEBF9FF);
    } else if (status == "canceled") {
      return const Color(0xFFFFF2F2);
    } else if (status == "on going") {
      return const Color(0xFFCBF9D8);
    }

    return const Color(0xFFFFFFFF);
  }

  Color _tagColor({required String tags}) {
    if (tags == "personal") {
      return const Color(0xFF858FE9);
    } else if (tags == "work") {
      return const Color(0xFF7FC9E7);
    } else if (tags == "private") {
      return const Color(0xFFE77D7D);
    } else if (tags == "meeting") {
      return const Color(0xFF81E89E);
    } else if (tags == "events") {
      return const Color(0xFF858FE9);
    }

    return const Color(0xFFFFFFFF);
  }
}
