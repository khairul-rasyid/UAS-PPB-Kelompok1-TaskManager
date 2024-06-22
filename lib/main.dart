import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application/pages/list_task.dart';
import 'package:flutter_application/pages/splash.dart';
import 'package:flutter_application/pages/task.dart';
import 'package:flutter_application/pages/profile.dart';
import 'package:flutter_application/services/notif.dart';
import 'package:flutter_application/services/dbservices.dart';
import 'firebase_options.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notif.initNotif();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Notif.listenerNotif();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
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
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
              color: Color.fromARGB(255, 233, 233, 233),
              blurRadius: 12,
              offset: Offset(0, 0))
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BottomNavigationBar(
              selectedItemColor: const Color(0xFF5B67CA),
              unselectedItemColor: Color(0xFFC6CEDD),
              showSelectedLabels: false,
              showUnselectedLabels: false,
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
        padding: const EdgeInsets.fromLTRB(13, 60, 13, 10),
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
                        color: Color(0xFF12175E),
                      ),
                    ),
                    const Text(
                      "Let's make this day productive",
                      style: TextStyle(
                        color: Color(0xFF12175E),
                      ),
                    )
                  ],
                ),
                ClipOval(
                  child: Image(
                    image: NetworkImage("${user.photoURL}"),
                    width: 38,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "My Tasks",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12175E)),
              ),
            ),
            const SizedBox(height: 15),
            StaggeredGrid.count(
                crossAxisCount: 8,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: [
                  StreamBuilder<int>(
                    stream: Database.getTaskCountByStatusStream(
                        userUid: user.uid, status: "completed"),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final count = snapshot.data!;

                        return StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 4.3,
                            child: TaskCard(
                              userUid: user.uid,
                              cardName: "Completed",
                              numberOfTasks: "$count Tasks",
                              backgroundColor: const Color(0xFF7DC8E7),
                              textColor: const Color(0xFF12175E),
                              imgSrc: "assets/images/imac-1.png",
                            ));
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      return StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 4.3,
                          child: TaskCard(
                            userUid: user.uid,
                            cardName: "Completed",
                            numberOfTasks: "0 Tasks",
                            backgroundColor: const Color(0xFF7DC8E7),
                            textColor: const Color(0xFF12175E),
                            imgSrc: "assets/images/imac-1.png",
                            iconData: Icons.abc,
                          ));
                    },
                  ),
                  StreamBuilder<int>(
                    stream: Database.getTaskCountByStatusStream(
                        userUid: user.uid, status: "pending"),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final count = snapshot.data!;

                        return StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 3,
                            child: TaskCard(
                              userUid: user.uid,
                              cardName: "Pending",
                              numberOfTasks: "$count Tasks",
                              backgroundColor: const Color(0xFF7D88E7),
                              textColor: Colors.white,
                              iconData: Icons.access_time,
                            ));
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      return StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 3,
                          child: TaskCard(
                            userUid: user.uid,
                            cardName: "Pending",
                            numberOfTasks: "0 Tasks",
                            backgroundColor: const Color(0xFF7D88E7),
                            textColor: Colors.white,
                            iconData: Icons.access_time,
                          ));
                    },
                  ),
                  StreamBuilder<int>(
                    stream: Database.getTaskCountByStatusStream(
                        userUid: user.uid, status: "on going"),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final count = snapshot.data!;

                        return StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 4.3,
                            child: TaskCard(
                              userUid: user.uid,
                              cardName: "On Going",
                              numberOfTasks: "$count Tasks",
                              backgroundColor: const Color(0xFF81E89E),
                              textColor: const Color(0xFF12175E),
                              imgSrc: "assets/images/folder-1.png",
                            ));
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      return StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 4.3,
                          child: TaskCard(
                            userUid: user.uid,
                            cardName: "On Going",
                            numberOfTasks: "0 Tasks",
                            backgroundColor: const Color(0xFF81E89E),
                            textColor: const Color(0xFF12175E),
                            imgSrc: "assets/images/folder-1.png",
                          ));
                    },
                  ),
                  StreamBuilder<int>(
                    stream: Database.getTaskCountByStatusStream(
                        userUid: user.uid, status: "canceled"),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final count = snapshot.data!;

                        return StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 3,
                            child: TaskCard(
                              userUid: user.uid,
                              cardName: "Canceled",
                              numberOfTasks: "$count Tasks",
                              backgroundColor: const Color(0xFFE77D7D),
                              textColor: Colors.white,
                              iconData: Icons.remove_circle_outline,
                            ));
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      return StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 3,
                          child: TaskCard(
                            userUid: user.uid,
                            cardName: "Canceled",
                            numberOfTasks: "0 Tasks",
                            backgroundColor: const Color(0xFFE77D7D),
                            textColor: Colors.white,
                            iconData: Icons.remove_circle_outline,
                          ));
                    },
                  ),
                ])
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.userUid,
    required this.cardName,
    required this.numberOfTasks,
    required this.backgroundColor,
    required this.textColor,
    this.imgSrc = "",
    this.iconData,
  });

  final String userUid;
  final String cardName;
  final String numberOfTasks;
  final Color backgroundColor;
  final String imgSrc;
  final IconData? iconData;
  final Color textColor;

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
                  condition: cardName.toLowerCase())),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular((14))),
            boxShadow: [
              BoxShadow(
                  color: backgroundColor.withOpacity(0.8),
                  blurRadius: 12,
                  offset: const Offset(8, 10))
            ]),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imgSrc.isNotEmpty)
                  Image.asset(
                    imgSrc,
                    width: 90,
                    height: 90,
                  ),
                if (iconData != null)
                  Icon(
                    iconData!,
                    color: textColor,
                    size: 32,
                  ),
                Text(cardName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    )),
                Text(
                  numberOfTasks,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            Icon(Icons.arrow_right_alt_outlined, color: textColor)
          ],
        ),
      ),
    );
  }
}
