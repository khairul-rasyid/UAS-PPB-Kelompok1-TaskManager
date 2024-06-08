import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/dataclass.dart';
import 'package:flutter_application/dbservices.dart';
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
  final TextEditingController _dateTimeController = TextEditingController();

  String? _selectedItem;

  List<String> tags = ["personal", "work", "private", "meeting", "events"];

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
        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
            _textForm(text: "Date & Time"),
            TextFormField(
              controller: _dateTimeController,
              decoration: InputDecoration(
                hintText: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
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
                  // ignore: use_build_context_synchronously
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    DateTime finalDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute);

                    String formattedDateTime =
                        DateFormat('dd-MM-yyyy HH:mm').format(finalDateTime);
                    setState(() {
                      _dateTimeController.text = formattedDateTime;
                    });
                  }
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
              hint: const Text("Tags for task"),
              value: _selectedItem,
              items: tags.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 40,
              width: 500,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF5B67CA)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>((Colors.white)),
                  ),
                  onPressed: () {
                    DateTime parsedDateTime = DateFormat('dd-MM-yyyy HH:mm')
                        .parse(_dateTimeController.text);

                    DateTime utcDateTime = parsedDateTime.toUtc();
                    final newTask = ItemTask(
                        userUid: userData.uid,
                        itemTitle: _titleController.text,
                        itemDesc: _descController.text,
                        itemDatetime: utcDateTime.toUtc(),
                        itemTags: _selectedItem.toString(),
                        itemStatus: "on going");
                    Database.addData(item: newTask);
                    Navigator.pop(context);
                  },
                  child: const Text("Create")),
            )
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
