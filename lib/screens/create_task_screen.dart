import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  bool repeat = false;
  String repeatOption = "Daily";
  String completedBy = "Me";
  String importance = "Normal";

  Future<void> saveTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .add({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),
      "time": dateController.text.trim(),
      "repeat": repeat,
      "repeatOption": repeatOption,
      "completedBy": completedBy,
      "importance": importance,
      "createdAt": DateTime.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            height: 100,
            width: double.infinity,
            color: const Color(0xFF0F52BA),
            alignment: Alignment.center,
            child: const Text(
              "CREATE TASK",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // CANCEL / SAVE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6E6),
                      elevation: 0,
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6E6),
                      elevation: 0,
                    ),
                    child: const Text("Save",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),

          // FORM
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Name",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF444444))),
                    const SizedBox(height: 6),
                    _input(nameController, "Enter Title..."),

                    const SizedBox(height: 20),
                    const Text("Description",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF444444))),
                    const SizedBox(height: 6),
                    _input(descController, "Enter Description..."),

                    const SizedBox(height: 20),
                    const Text("Date & Time",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF444444))),
                    const SizedBox(height: 6),
                    _input(dateController, "Complete by Month, 12:00 AM"),

                    // Repeat toggle
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text("Repeat this task?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Switch(
                            value: repeat,
                            onChanged: (v) => setState(() => repeat = v)),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Text("Repeats:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE6E6E6),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          _radio("Daily"),
                          _radio("Weekly"),
                          _radio("Monthly"),
                          _radio("Custom"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text("Completed By:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    _dropdown(
                      value: completedBy,
                      items: const ["Me", "Family", "Friend"],
                      onChanged: (v) =>
                          setState(() => completedBy = v.toString()),
                    ),

                    const SizedBox(height: 24),
                    const Text("Importance",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    _dropdown(
                      value: importance,
                      items: const ["Low", "Normal", "High"],
                      onChanged: (v) =>
                          setState(() => importance = v.toString()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
          ),
        ),
      );

  Widget _radio(String label) => RadioListTile(
        value: label,
        groupValue: repeatOption,
        title: Text(label),
        onChanged: (v) => setState(() => repeatOption = v.toString()),
      );

  Widget _dropdown(
          {required String value,
          required List<String> items,
          required Function(String?) onChanged}) =>
      Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: value,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
