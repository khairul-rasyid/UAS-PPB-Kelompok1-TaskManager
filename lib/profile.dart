import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/auth.dart';
import 'package:flutter_application/list_task.dart';
import 'package:flutter_application/login.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User userData;
  @override
  void initState() {
    userData = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        const SizedBox(
          height: 40,
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              )),
          child: Column(
            children: [
              const SizedBox(height: 30),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                title: Text("${userData.displayName}",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w500)),
                subtitle: Text("${userData.email}",
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFFFFFFF))),
                leading: ClipOval(
                    child: Image(
                  image: NetworkImage("${userData.photoURL}"),
                  width: 50,
                )),
                trailing: GestureDetector(
                  onTap: () {
                    signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFFFFFFF),
                    size: 25,
                  ),
                ),
              ),
              const SizedBox(height: 30)
            ],
          ),
        ),
        Container(
          color: Theme.of(context).primaryColor,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(0))),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                itemProfile('Personal', Icons.person_outline_rounded,
                    const Color(0xFF858FE9), true),
                itemProfile('Work', Icons.work_outline_rounded,
                    const Color(0xFF7FC9E7), true),
                itemProfile('Private', Icons.lock_outline_rounded,
                    const Color(0xFFE77D7D), true),
                itemProfile('Meeting', Icons.meeting_room_outlined,
                    const Color(0xFF81E89E), true),
                itemProfile('Events', Icons.calendar_month,
                    const Color(0xFF858FE9), true),
                itemProfile(
                    'Create Board', Icons.add, const Color(0xFFF0A58E), false),
              ],
            ),
          ),
        )
      ]),
    );
  }

  itemProfile(String title, IconData iconData, Color background,
          bool isClickable) =>
      GestureDetector(
        onTap: isClickable
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListTask(
                          userUid: userData.uid,
                          field: 'tags',
                          condition: title.toLowerCase())),
                );
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: background.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(iconData, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15),
                )
              ],
            ),
          ),
        ),
      );
}
