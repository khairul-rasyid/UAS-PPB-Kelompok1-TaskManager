import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/dbservices.dart';
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
                    "Task $title",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
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
                        "No Task...",
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
                        String dtTitle = clData['title'];
                        Timestamp dtTimestamp = clData['datetime'];
                        String dtDate = DateFormat('dd MMMM yyyy')
                            .format(dtTimestamp.toDate());
                        String dtTime =
                            DateFormat('HH:mm').format(dtTimestamp.toDate());
                        String dtDesc = clData['desc'];
                        String dtTags = clData['tags'];
                        return _buildTask(
                            // index: index,
                            title: dtTitle,
                            date: dtDate,
                            time: dtTime,
                            desc: dtDesc,
                            tags: dtTags);
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
                  }
                  return const Center(
                    child: Text("No Task"),
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
    required String tags,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        tileColor: _tileColor(tags: tags),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        leading: _icon(tags: tags),
        title: Text(
          title,
          style: const TextStyle(
              color: Color(0xFF000000), fontWeight: FontWeight.w500),
        ),
        titleTextStyle: const TextStyle(fontSize: 18),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Text(date.toString()),
                const SizedBox(
                  width: 10,
                ),
                Text(time.toString())
              ],
            ),
            const SizedBox(height: 8),
            Text(tags),
          ],
        ),
      ),
    );
  }

  Color _tileColor({required String tags}) {
    if (tags == "personal") {
      return const Color(0xFF858FE9).withOpacity(0.18);
    } else if (tags == "work") {
      return const Color(0xFF7FC9E7).withOpacity(0.18);
    } else if (tags == "private") {
      return const Color(0xFFE77D7D).withOpacity(0.18);
    } else if (tags == "meeting") {
      return const Color(0xFF81E89E).withOpacity(0.18);
    } else if (tags == "events") {
      return const Color(0xFF858FE9).withOpacity(0.18);
    }
    return const Color(0xFFFFFFFF);
  }

  Widget _icon({required String tags}) {
    if (tags == "personal") {
      return _styleIcon(
          nameIcon: Icons.person_outline_rounded,
          color: const Color(0xFF858FE9));
    } else if (tags == "work") {
      return _styleIcon(
          nameIcon: Icons.work_outline_rounded, color: const Color(0xff7FC9E7));
    } else if (tags == "private") {
      return _styleIcon(
          nameIcon: Icons.lock_outline_rounded, color: const Color(0xFFE77D7D));
    } else if (tags == "meeting") {
      return _styleIcon(
          nameIcon: Icons.meeting_room_outlined,
          color: const Color(0xFF81E89E));
    } else if (tags == "events") {
      return _styleIcon(
          nameIcon: Icons.calendar_month, color: const Color(0xFF858FE9));
    }
    return const Text("E");
  }

  Widget _styleIcon({required IconData nameIcon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        nameIcon,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
