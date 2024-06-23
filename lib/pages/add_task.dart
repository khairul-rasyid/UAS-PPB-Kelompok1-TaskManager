import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/dataclass.dart';
import 'package:flutter_application/services/dbservices.dart';
import 'package:flutter_application/services/notif.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTask extends StatefulWidget {
  final User user;
  const AddTask({super.key, required this.user});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
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
          // crossAxisAlignment: CrossAxisAlignment.start,
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
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textForm(text: "Title"),
                  _formField(
                      hintText: "Plan for a month",
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title!';
                        }
                        return null;
                      }),
                  const SizedBox(height: 20),
                  _textForm(text: "Date"),
                  _formField(
                      hintText:
                          DateFormat('dd MMMM yyyy').format(DateTime.now()),
                      controller: _dateController,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select date!';
                        }
                        return null;
                      }),
                  const SizedBox(height: 20),
                  _textForm(text: "Time"),
                  _formField(
                      hintText: DateFormat('HH:mm').format(DateTime.now()),
                      controller: _timeController,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.schedule),
                      onTap: () => _selectTime(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select time!';
                        }
                        return null;
                      }),
                  const SizedBox(height: 20),
                  _textForm(text: "Description"),
                  _formField(
                      hintText: "Creating this month's work plan",
                      controller: _descController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description!';
                        }
                        return null;
                      }),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select tags!';
                        }
                        return null;
                      }),
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
                      validator: (value) {
                        if (value == null) {
                          return 'Please select minute!';
                        }
                        return null;
                      }),
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Random random = Random();
                            int randomId = random.nextInt(1000000000);

                            final DateTime datetime = DateTime(
                                date!.year,
                                date!.month,
                                date!.day,
                                time!.hour,
                                time!.minute);

                            final DateTime dateNotif = datetime
                                .subtract(Duration(minutes: _selectedMinute!));

                            Notif.scheduleNotif(
                                id: randomId,
                                title: "Task Reminder",
                                body:
                                    "You have ${_titleController.text.capitalize} to complete today at ${time!.hour}:${time!.minute}",
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
                          }
                        },
                        child: const Text("Create")),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
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
      {required String hintText,
      required TextEditingController controller,
      Widget? suffixIcon,
      bool readOnly = false,
      VoidCallback? onTap,
      required String? Function(String?) validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 16),
          suffixIcon: suffixIcon),
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
        initialEntryMode: DatePickerEntryMode.calendarOnly);

    if (pickedDate != null) {
      setState(() {
        date = pickedDate;
        _dateController.text = DateFormat('dd MMMM yyyy').format(date!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.inputOnly);

    if (pickedTime != null) {
      setState(() {
        time = pickedTime;
        // final datetime = DateTime(date!.year, date!.month,
        //     date!.day, time!.hour, time!.minute);
        _timeController.text = time!.format(context);
      });
    }
  }
}
