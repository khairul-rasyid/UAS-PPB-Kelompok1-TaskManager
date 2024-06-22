import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/dataclass.dart';
import 'package:flutter_application/services/dbservices.dart';
import 'package:flutter_application/services/notif.dart';
import 'package:intl/intl.dart';

class AddTask extends StatefulWidget {
  final User user;
  const AddTask({super.key, required this.user});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? date;
  TimeOfDay? time;

  String? _selectedTags;
  int? _selectedMinute;

  List<String> tags = ["personal", "work", "private", "meeting", "events"];
  List<int> minute = [0, 15, 30, 45, 60];

  late User userData;

  @override
  void initState() {
    userData = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
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
                  "Add Task",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 6),
              ],
            ),
            const SizedBox(height: 30),
            _textForm(text: "Title"),
            _formField(
                hintText: "Plan for a month", controller: _titleController),
            const SizedBox(height: 20),
            _textForm(text: "Date"),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: DateFormat('dd MMMM yyyy').format(DateTime.now()),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  setState(() {
                    date = pickedDate;
                    _dateController.text =
                        DateFormat('dd MMMM yyyy').format(date!);
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _textForm(text: "Time"),
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(
                hintText: DateFormat('HH:mm').format(DateTime.now()),
                suffixIcon: const Icon(Icons.schedule),
              ),
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());

                if (pickedTime != null) {
                  setState(() {
                    time = pickedTime;
                    // final datetime = DateTime(date!.year, date!.month,
                    //     date!.day, time!.hour, time!.minute);
                    _timeController.text = time!.format(context);
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _textForm(text: "Desciprion"),
            _formField(
              hintText: "Creating this month's work plan",
              controller: _descController,
            ),
            const SizedBox(height: 20),
            _textForm(text: "Tags"),
            DropdownButtonFormField<String>(
              hint: const Text("Select tags"),
              value: _selectedTags,
              items: tags.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTags = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            _textForm(text: "Remind ... minutes early"),
            DropdownButtonFormField<int>(
              hint: const Text("Select minute"),
              value: _selectedMinute,
              items: minute.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedMinute = newValue;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 50,
              width: 500,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF5B67CA)),
                      foregroundColor:
                          MaterialStateProperty.all<Color>((Colors.white)),
                      shape: const MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14))))),
                  onPressed: () {
                    if (_titleController.text != "" ||
                        _descController.text != "" ||
                        _dateController.text != "" ||
                        _timeController.text != "" ||
                        _selectedTags != null ||
                        _selectedMinute != null) {
                      Random random = Random();
                      int randomId = random.nextInt(1000000000);

                      final DateTime datetime = DateTime(date!.year,
                          date!.month, date!.day, time!.hour, time!.minute);

                      final DateTime dateNotif = datetime
                          .subtract(Duration(minutes: _selectedMinute!));

                      Notif.scheduleNotif(
                          id: randomId,
                          title: _titleController.text,
                          body: _descController.text,
                          dateTime: dateNotif);

                      final DateTime dateTimeUtc8 =
                          datetime.add(const Duration(hours: 8));

                      final newTask = ItemTask(
                          idNotif: randomId,
                          userUid: userData.uid,
                          itemTitle: _titleController.text,
                          itemDesc: _descController.text,
                          itemDatetime: dateTimeUtc8,
                          itemTags: _selectedTags.toString(),
                          itemStatus: "on going");
                      Database.addData(item: newTask);
                      Navigator.pop(context);
                    } else {
                      return _validateDialog(context);
                    }
                  },
                  child: const Text("Create")),
            ),
          ],
        ),
      ),
    ));
  }
}

Widget _textForm({required String text}) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      color: Color(0xFF8A8BB3),
    ),
  );
}

Widget _formField(
    {required String hintText, required TextEditingController controller}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
        hintText: hintText, hintStyle: const TextStyle(fontSize: 16)),
  );
}

void _validateDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
            child: Text(
          'Can not be empty',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        )),
        content: const Text(
          'Fill in all forms',
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      );
    },
  );
}
