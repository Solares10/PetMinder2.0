import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  String importance = "Normal";

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? selectedPetId;
  String? selectedPetName;
  String? selectedPetImageUrl;

  List<Map<String, dynamic>> pets = [];
  late String taskId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    taskId = data["id"];
    nameController.text = data["name"] ?? "";
    descController.text = data["description"] ?? "";
    importance = data["importance"] ?? "Normal";

    selectedPetId = data["petId"];
    selectedPetName = data["petName"];
    selectedPetImageUrl = data["petImageUrl"];

    selectedDate = (data["date"] as Timestamp).toDate();
    selectedTime = _parseTime(data["time"]);

    _loadPets();
  }

  // Convert "8:30 PM" → TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final format = DateFormat.jm();
    final dt = format.parse(timeString);
    return TimeOfDay.fromDateTime(dt);
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
      initialDate: selectedDate ?? now,
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
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> saveTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (selectedPetId == null) {
      _showError("Select a pet");
      return;
    }
    if (selectedDate == null) {
      _showError("Select a date");
      return;
    }
    if (selectedTime == null) {
      _showError("Select a time");
      return;
    }

    final formattedTime = selectedTime!.format(context);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .doc(taskId)
        .update({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),

      // pet info
      "petId": selectedPetId,
      "petName": selectedPetName,
      "petImageUrl": selectedPetImageUrl,

      // scheduling
      "date": DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      ),
      "time": formattedTime,

      "importance": importance,
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

  void _showError(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("EDIT TASK"),
        actions: [
          IconButton(
              onPressed: deleteTask,
              icon: const Icon(Icons.delete, color: Colors.white))
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
            _label("Pet"),
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

  // ---------- COMPONENTS ----------

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold),
      );

  Widget _input(TextEditingController c, String hint) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
            border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _petSelector() {
    if (pets.isEmpty) {
      return const Text("No pets found.", style: TextStyle(color: Colors.black54));
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
                selectedPetName = pet["name"];
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
                      offset: Offset(0, 3))
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        pet["imageUrl"] ?? "",
                        fit: BoxFit.cover,
                        width: double.infinity,
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
        foregroundColor: Colors.black,
        elevation: 0,
      ),
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
        foregroundColor: Colors.black,
        elevation: 0,
      ),
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
        style:
            ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text("Save Changes",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
