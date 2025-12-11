import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'delete_task_dialog.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();
  final noteController = TextEditingController();

  String completedBy = "Me";
  late String taskId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    taskId = data["id"];
    nameController.text = data["name"] ?? "";
    descController.text = data["description"] ?? "";
    dateController.text = data["time"] ?? "";
    completedBy = data["completedBy"] ?? "Me";
    noteController.text = data["note"] ?? "";
  }

  Future<void> saveTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .doc(taskId)
        .update({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),
      "time": dateController.text.trim(),
      "completedBy": completedBy,
      "note": noteController.text.trim(),
      "updatedAt": DateTime.now(),
    });

    Navigator.pop(context);
  }

  Future<void> deleteTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .doc(taskId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNav(context),
      body: Column(
        children: [
          // TOP HEADER
          Container(
            height: 100,
            width: double.infinity,
            color: const Color(0xFF0F52BA),
            alignment: Alignment.center,
            child: const Text(
              "EDIT TASK",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // DELETE | CANCEL | SAVE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // DELETE
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return DeleteTaskDialog(
                            onDelete: () {
                              deleteTask();
                              Navigator.pop(context);
                            },
                            onCancel: () => Navigator.pop(context),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4E4E4),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // CANCEL TEXT
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Center(
                      child: Text(
                        "Cancel Edit",
                        style: TextStyle(
                          color: Color(0xFF0F52BA),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // SAVE
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4E4E4),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FORM AREA
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Name"),
                    _input(nameController, "Enter Title..."),
                    const SizedBox(height: 25),
                    _label("Description"),
                    _input(descController, "Enter Description..."),
                    const SizedBox(height: 25),
                    _label("Date & Time"),
                    _input(dateController, "Complete by Month, ##:##AM"),
                    const SizedBox(height: 25),
                    _label("Completed By"),
                    _dropdown(
                      value: completedBy,
                      items: const ["Me", "Family", "Friend"],
                      onChanged: (v) =>
                          setState(() => completedBy = v.toString()),
                    ),
                    const SizedBox(height: 25),
                    _label("Note"),
                    _input(noteController, "Some optional note here ..."),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4E4E4),
                          elevation: 0,
                        ),
                        child: const Text(
                          "SKIP FOR TODAY",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  // Label helper
  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF444444),
        ),
      );

  // Input
  Widget _input(TextEditingController controller, String hint) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF888888)),
        ),
      ),
    );
  }

  // Dropdown
  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
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

  // Bottom navbar
  Widget _bottomNav(BuildContext context) {
    return Container(
      height: 95,
      color: const Color(0xFF0F52BA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(context, Icons.home, "Home", "/tasks"),
          _navItem(
              context, Icons.calendar_today, "Calendar", "/calendarFilter"),
          _navItem(context, Icons.pets, "Pets", "/pets"),
          _navItem(context, Icons.settings, "Settings", "/settings"),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
