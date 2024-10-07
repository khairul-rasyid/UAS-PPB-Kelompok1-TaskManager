import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/services/dbservices.dart';
import 'package:flutter_application/services/notif.dart';
// import 'package:flutter_launcher_icons/xml_templates.dart';
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
                        String dtTags = clData['tags'];
                        int dtNotif = clData['idNotif'];
                        return Dismissible(
                          key: Key('$dtNotif'),
                          confirmDismiss: (direction) =>
                              _deleteTaskDialog(context),
                          onDismissed: (direction) {
                            Notif.cancelScheduledNotif(dtNotif);
                            Database.deleteData(docsName: dtTitle);
                          },
                          background: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFFe15b5b),
                            ),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: const Icon(
                              Icons.delete,
                              color: Color(0xFFfdf6f6),
                              size: 38,
                            ),
                          ),
                          secondaryBackground: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFFe15b5b),
                            ),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: const Icon(
                              Icons.delete,
                              color: Color(0xFFfdf6f6),
                              size: 38,
                            ),
                          ),
                          child: _buildTask(
                            // index: index,
                            title: dtTitle,
                            date: dtDate,
                            time: dtTime,
                            desc: dtDesc,
                            tags: dtTags,
                            idNotif: dtNotif,
                          ),
                        );
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
    required String tags,
    required int idNotif,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        // leading: _icon(tags: tags),
        tileColor: _tileColor(tags: tags).withOpacity(0.18),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        // leading: _icon(status: status),
        title: Text(
          title,
          style: const TextStyle(
              color: Color(0xFF12175E), fontWeight: FontWeight.w500),
        ),
        titleTextStyle: const TextStyle(fontSize: 20),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  date.toString(),
                  style: const TextStyle(
                    color: Color(0xFF8A8BB3),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  time.toString(),
                  style: const TextStyle(
                    color: Color(0xFF8A8BB3),
                  ),
                )
              ],
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _tags(tagsName: tags),
          ],
        ),
      ),
    );
  }

  Color _tileColor({required String tags}) {
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

  Widget _tags({required String tagsName}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
        color: _tileColor(tags: tagsName).withOpacity(1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tagsName,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }

  Future<bool> _deleteTaskDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
              child: Text(
            'Delete Task',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          )),
          content: const Text(
            'Are you sure to delete this task?',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No',
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Yes',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}
