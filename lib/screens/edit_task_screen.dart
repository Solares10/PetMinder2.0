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

    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Load data from Firestore document into fields
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

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("tasks")
        .doc(taskId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: _bottomNav(),

      body: Column(
        children: [
          // ================= TOP BLUE HEADER =================
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

          // ================= DELETE | CANCEL EDIT | SAVE ROW =================
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

                // CANCEL EDIT (CENTER TEXT)
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

                // SAVE BUTTON
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

          // ================= FORM SCROLL AREA =================
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // NAME
                    const Text(
                      "Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _input(nameController, "Enter Title..."),

                    // DESCRIPTION
                    const SizedBox(height: 25),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _input(descController, "Enter Description..."),

                    // DATE & TIME
                    const SizedBox(height: 25),
                    const Text(
                      "Date & Time",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _input(dateController, "Complete by Month, ##:##AM"),

                    // COMPLETED BY DROPDOWN
                    const SizedBox(height: 25),
                    const Text(
                      "Completed By:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _dropdown(
                      value: completedBy,
                      items: const ["Me", "Family", "Friend"],
                      onChanged: (v) =>
                          setState(() => completedBy = v.toString()),
                    ),

                    // NOTE
                    const SizedBox(height: 25),
                    const Text(
                      "Note:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _input(noteController, "Some optional note here ..."),

                    // SKIP FOR TODAY BUTTON
                    const SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: add skip logic
                          },
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

  // ---------------- INPUT FIELD ----------------
  Widget _input(TextEditingController controller, String hint) {
    return Container(
      height: 50,
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

  // ---------------- DROPDOWN ----------------
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
          items:
              items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------------- BOTTOM NAVIGATION ----------------
  Widget _bottomNav() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(color: Color(0xFF0F52BA)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home, "Home", active: true),
          _navItem(Icons.calendar_today, "Calendar"),
          _navItem(Icons.pets, "Pets"),
          _navItem(Icons.settings, "Settings"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool active = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: active ? const Color(0xFFFF8A65) : Colors.white,
        ),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFFFF8A65) : Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
