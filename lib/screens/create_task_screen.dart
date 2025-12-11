import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String importance = "Normal";

  String? selectedPetId;
  String? selectedPetImageUrl;
  List<Map<String, dynamic>> pets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("pets")
        .get();

    setState(() {
      pets = snap.docs
          .map((d) => {
                "id": d.id,
                "name": d["petName"],
                "imageUrl": d["imageUrl"],
              })
          .toList();
    });
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> saveTask() async {
    if (selectedPetId == null) {
      _showError("Please select a pet.");
      return;
    }
    if (selectedDate == null) {
      _showError("Please select a date.");
      return;
    }
    if (selectedTime == null) {
      _showError("Please select a time.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final formattedTime =
        selectedTime!.format(context); // e.g. "8:30 PM"

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .add({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),

      // pet info
      "petId": selectedPetId,
      "petImageUrl": selectedPetImageUrl,

      // scheduling
      "date": DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      ),
      "time": formattedTime,

      // extra data
      "importance": importance,
      "createdAt": DateTime.now(),
    });

    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            color: const Color(0xFF0F52BA),
            child: const Text(
              "CREATE TASK",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Task Name"),
                  _input(nameController, "Task title..."),

                  const SizedBox(height: 20),
                  _label("Description"),
                  _input(descController, "Task details..."),

                  const SizedBox(height: 20),
                  _label("Select Pet"),

                  const SizedBox(height: 10),
                  _petSelector(),

                  const SizedBox(height: 20),
                  _label("Date"),
                  _dateButton(),

                  const SizedBox(height: 20),
                  _label("Time"),
                  _timeButton(),

                  const SizedBox(height: 20),
                  _label("Importance"),
                  _importanceDropdown(),

                  const SizedBox(height: 30),
                  _saveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- COMPONENTS ----------------

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black));
  }

  Widget _input(TextEditingController c, String hint) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEDEDED)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
            border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _petSelector() {
    if (pets.isEmpty) {
      return const Text("No pets found. Add a pet first.",
          style: TextStyle(color: Colors.black54));
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        itemBuilder: (context, i) {
          final pet = pets[i];
          final bool active = (selectedPetId == pet["id"]);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPetId = pet["id"];
                selectedPetImageUrl = pet["imageUrl"];
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: active ? Colors.orange : Colors.transparent,
                    width: 3),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 4,
                      color: Colors.black12,
                      offset: Offset(0, 3))
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Image.network(
                        pet["imageUrl"] ?? "",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey,
                          child: const Icon(Icons.pets),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      pet["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dateButton() {
    return ElevatedButton(
      onPressed: pickDate,
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEDEDED),
          elevation: 0,
          foregroundColor: Colors.black),
      child: Text(
        selectedDate == null
            ? "Pick Date"
            : DateFormat('MMMM d, yyyy').format(selectedDate!),
      ),
    );
  }

  Widget _timeButton() {
    return ElevatedButton(
      onPressed: pickTime,
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEDEDED),
          elevation: 0,
          foregroundColor: Colors.black),
      child: Text(
        selectedTime == null ? "Pick Time" : selectedTime!.format(context),
      ),
    );
  }

  Widget _importanceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: importance,
          items: ["High", "Normal", "Low"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => importance = v.toString()),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: saveTask,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text("Save Task", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
