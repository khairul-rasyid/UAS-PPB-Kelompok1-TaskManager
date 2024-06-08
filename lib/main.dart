import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application/auth.dart';
import 'package:flutter_application/list_task.dart';
import 'firebase_options.dart';

import 'profile.dart';
import 'task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: const CheckUser(),
    );
  }
}

class MyBottomNavBar extends StatefulWidget {
  final User user;
  const MyBottomNavBar({super.key, required this.user});

  @override
  State<MyBottomNavBar> createState() => _MyButtomNavBarState();
}

class _MyButtomNavBarState extends State<MyBottomNavBar> {
  int myCurrentIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    pages = [
      HomePage(
        user: widget.user,
      ),
      TaskPage(
        user: widget.user,
      ),
      ProfilePage(
        user: widget.user,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 0))
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BottomNavigationBar(
              selectedItemColor: const Color(0xFF5B67CA),
              unselectedItemColor: Colors.black,
              currentIndex: myCurrentIndex,
              onTap: (index) {
                setState(() {
                  myCurrentIndex = index;
                });
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.assignment), label: "Task"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
              ]),
        ),
      ),
      body: pages[myCurrentIndex],
    );
  }
}

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, ${user.displayName}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Let's make this day productive")
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Task",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TaskCard(
                        userUid: user.uid,
                        icon: Icons.computer,
                        name: "Completed",
                        task: "86 Task",
                        bgColor: const Color(0xFF81E89E)),
                    const SizedBox(
                      width: 20,
                    ),
                    TaskCard(
                        userUid: user.uid,
                        icon: Icons.access_time,
                        name: "Pending",
                        task: "15 Task",
                        bgColor: const Color(0xFF7D88E7)),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TaskCard(
                        userUid: user.uid,
                        icon: Icons.close_rounded,
                        name: "Canceled",
                        task: "15 Task",
                        bgColor: const Color(0xFFE77D7D)),
                    const SizedBox(
                      width: 20,
                    ),
                    TaskCard(
                        userUid: user.uid,
                        icon: Icons.book,
                        name: "On Going",
                        task: "67 Task",
                        bgColor: const Color(0xFF7DC8E7)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String task;
  final Color bgColor;
  final String userUid;

  const TaskCard(
      {super.key,
      required this.icon,
      required this.name,
      required this.task,
      required this.bgColor,
      required this.userUid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListTask(
                  userUid: userUid,
                  field: 'status',
                  condition: name.toLowerCase())),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient:
                LinearGradient(colors: [bgColor, bgColor.withOpacity(0.69)])),
        padding: const EdgeInsets.all(12),
        width: 160,
        height: 170,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 42,
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              )
            ]),
      ),
    );
  }
}
