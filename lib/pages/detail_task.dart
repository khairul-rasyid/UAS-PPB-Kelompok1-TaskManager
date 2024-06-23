import 'package:flutter/material.dart';
import 'package:flutter_application/services/dbservices.dart';
import 'package:flutter_application/services/notif.dart';

class DetailTask extends StatefulWidget {
  final String title;
  final String date;
  final String time;
  final String desc;
  final String tags;
  final int idNotif;

  const DetailTask(
      {super.key,
      required this.title,
      required this.date,
      required this.time,
      required this.desc,
      required this.tags,
      required this.idNotif});

  @override
  State<DetailTask> createState() => _DetailTaskState();
}

class _DetailTaskState extends State<DetailTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                const Text(
                  "Detail Task",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(flex: 6),
              ],
            ),
            const SizedBox(height: 15),
            // title
            _textTitle(text: "Title"),
            const SizedBox(
              height: 3,
            ),
            _textData(text: widget.title),
            _divider(),
            const SizedBox(height: 5),

            // date
            _textTitle(text: "Date"),
            const SizedBox(
              height: 3,
            ),
            _textData(text: widget.date),
            _divider(),
            const SizedBox(height: 5),

            // time
            _textTitle(text: "Time"),
            const SizedBox(
              height: 3,
            ),
            _textData(text: widget.time),
            _divider(),
            const SizedBox(height: 5),

            //desc
            _textTitle(text: "Description"),
            const SizedBox(
              height: 3,
            ),
            _textData(text: widget.desc),
            _divider(),
            const SizedBox(height: 5),

            // tags
            _textTitle(text: "Tags"),
            const SizedBox(
              height: 3,
            ),
            _textData(text: widget.tags),
            _divider(),

            //button status
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buttonStatus(
                      title: widget.title,
                      text: "Completed",
                      newStatus: "completed",
                      idNotif: widget.idNotif),
                  _buttonStatus(
                      title: widget.title,
                      text: "Pending",
                      newStatus: "pending",
                      idNotif: widget.idNotif),
                  _buttonStatus(
                      title: widget.title,
                      text: "Canceled",
                      newStatus: "canceled",
                      idNotif: widget.idNotif),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _textTitle({required String text}) {
    return Text(
      text,
      style: const TextStyle(
        letterSpacing: 1,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF8A8BB3),
      ),
    );
  }

  Widget _textData({required String text}) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      color: Color(0xFFAFAFAF),
      thickness: 1,
    );
  }

  Widget _buttonStatus(
      {required String title,
      required String text,
      required String newStatus,
      required int idNotif}) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: () {
          final changeData = {'status': newStatus};
          Notif.cancelScheduledNotif(idNotif);
          Database.updateData(idDocs: title, data: changeData);
          Navigator.pop(context);
        },
        style: _colorButton(status: newStatus),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  ButtonStyle _colorButton({required String status}) {
    if (status == "completed") {
      return ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          backgroundColor: const Color(0xFF7DC8E7), // Warna background tombol
          foregroundColor: Colors.white, // Warna teks tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sudut tombol
          ));
    } else if (status == "pending") {
      return ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          backgroundColor: const Color(0xFF7D88E7), // Warna background tombol
          foregroundColor: Colors.white, // Warna teks tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sudut tombol
          ));
    } else if (status == "canceled") {
      return ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          backgroundColor: const Color(0xFFE77D7D), // Warna background tombol
          foregroundColor: Colors.white, // Warna teks tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sudut tombol
          ));
    } else if (status == "on going") {
      return ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          backgroundColor: const Color(0xFF81E89E), // Warna background tombol
          foregroundColor: Colors.white, // Warna teks tombol
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sudut tombol
          ));
    }

    return ElevatedButton.styleFrom();
  }
}
