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

  // ---------------- LOAD PETS ----------------
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

  // ---------------- PICK DATE ----------------
  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) setState(() => selectedDate = picked);
  }

  // ---------------- PICK TIME ----------------
  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) setState(() => selectedTime = picked);
  }

  // ---------------- SAVE TASK ----------------
  Future<void> saveTask() async {
    if (selectedPetId == null) return _error("Please select a pet.");
    if (selectedDate == null) return _error("Please select a date.");
    if (selectedTime == null) return _error("Please select a time.");

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch pet info to store name + image
    final petData = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("pets")
        .doc(selectedPetId)
        .get();

    final formattedTime = selectedTime!.format(context);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .add({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),

      // PET INFO
      "petId": selectedPetId,
      "petName": petData["petName"],
      "petImageUrl": petData["imageUrl"],

      // DATE + TIME
      "date": DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      ),
      "time": formattedTime,

      // EXTRA
      "importance": importance,
      "createdAt": DateTime.now(),
    });

    Navigator.pop(context);
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        title: const Text(
          "CREATE TASK",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          )
        ],
      ),

      body: SingleChildScrollView(
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
    );
  }

  // ---------------- COMPONENTS ---------------

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _input(TextEditingController c, String hint) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: c,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _petSelector() {
    if (pets.isEmpty) {
      return const Text("No pets available. Add a pet first.");
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        itemBuilder: (context, i) {
          final pet = pets[i];
          final bool active = selectedPetId == pet["id"];

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
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        pet["imageUrl"] ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.pets, size: 40),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      pet["name"],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dateButton() => ElevatedButton(
        onPressed: pickDate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEDEDED),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        child: Text(selectedDate == null
            ? "Pick Date"
            : DateFormat('MMMM d, yyyy').format(selectedDate!)),
      );

  Widget _timeButton() => ElevatedButton(
        onPressed: pickTime,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEDEDED),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        child: Text(selectedTime == null
            ? "Pick Time"
            : selectedTime!.format(context)),
      );

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

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
          ),
          child: const Text("Save Task",
              style: TextStyle(color: Colors.white)),
        ),
      );
}
