import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // TOP BLUE HEADER
      body: Column(
        children: [
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

          // CANCEL / SAVE ROW
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // CANCEL
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6E6),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // SAVE
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Add Firebase save
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6E6),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MAIN SCROLL AREA
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _input(nameController, "Enter Title..."),

                    // DESCRIPTION
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    const Text(
                      "Date & Time",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _input(dateController, "Complete by Month, 12:00 AM"),

                    // REPEAT SWITCH
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          "Repeat this task?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF444444),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: repeat,
                          onChanged: (v) => setState(() => repeat = v),
                        ),
                      ],
                    ),

                    // REPEAT OPTIONS (Radio Buttons)
                    const SizedBox(height: 12),
                    const Text(
                      "Repeats:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF444444)),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E6E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _radio("Daily"),
                          _radio("Weekly"),
                          _radio("Monthly"),
                          _radio("Custom"),
                        ],
                      ),
                    ),

                    // COMPLETED BY (Dropdown)
                    const SizedBox(height: 24),
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
                      items: ["Me", "Family", "Friend"],
                      onChanged: (v) =>
                          setState(() => completedBy = v.toString()),
                    ),

                    // IMPORTANCE (Dropdown)
                    const SizedBox(height: 24),
                    const Text(
                      "Importance",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _dropdown(
                      value: importance,
                      items: ["Low", "Normal", "High"],
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

  // INPUT FIELD
  Widget _input(TextEditingController controller, String hint) {
    return Container(
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
  }

  // RADIO BUTTON OPTION
  Widget _radio(String label) {
    return RadioListTile(
      value: label,
      groupValue: repeatOption,
      title: Text(label),
      onChanged: (value) {
        setState(() => repeatOption = value.toString());
      },
    );
  }

  // DROPDOWN MENU
  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
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
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
