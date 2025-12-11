import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? profileImage;
  final emailController = TextEditingController();
  final notesController = TextEditingController();
  String? birthday;
  String fullName = "";
  List<String> petNames = [];

  bool notifDailyTasks = true;
  bool notifHealthUpdates = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = userDoc.data() ?? {};

    setState(() {
      fullName = user.displayName ?? "";
      birthday = data["birthday"] ?? "";
      emailController.text = user.email ?? "";
      notesController.text = data["notes"] ?? "";
      notifDailyTasks = data["notifDailyTasks"] ?? true;
      notifHealthUpdates = data["notifHealthUpdates"] ?? false;
      petNames = List<String>.from(data["pets"] ?? []);
    });
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    String? profileUrl;

    // Upload profile image if changed
    if (profileImage != null) {
      final ref = FirebaseStorage.instance
          .ref("users/${user!.uid}/profile.jpg");
      await ref.putFile(profileImage!);
      profileUrl = await ref.getDownloadURL();
    }

    // Save profile data to Firestore
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
      "birthday": birthday,
      "notes": notesController.text.trim(),
      "notifDailyTasks": notifDailyTasks,
      "notifHealthUpdates": notifHealthUpdates,
      "pets": petNames,
      "profileImage": profileUrl,
    }, SetOptions.merge());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNav(),

      body: Column(
        children: [
          // ================= TOP BAR =================
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            color: const Color(0xFF0F52BA),
            child: const Text(
              "PROFILE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ================= MAIN CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // PROFILE IMAGE UPLOAD FRAME
                  GestureDetector(
                    onTap: pickProfileImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: ClipOval(
                        child: profileImage != null
                            ? Image.file(profileImage!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.upload, size: 32),
                                  SizedBox(height: 4),
                                  Text(
                                    "Upload Image",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CARD
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NAME + EDIT ICON
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fullName,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.edit, size: 24),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // BIRTHDAY
                          const Text(
                            "Birthday",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          _chip(birthday ?? "Unknown"),

                          const SizedBox(height: 20),

                          // PETS LIST
                          const Text(
                            "Pets",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 10,
                            children: petNames
                                .map((p) => _chip(p))
                                .toList(),
                          ),

                          const SizedBox(height: 20),

                          // EMAIL
                          const Text(
                            "Email & Phone",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          _input(emailController, "Email"),

                          const SizedBox(height: 20),

                          // NOTIFICATIONS
                          const Text(
                            "Notifications",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),

                          _switchRow(
                            "Daily Tasks",
                            notifDailyTasks,
                            (v) => setState(() => notifDailyTasks = v),
                          ),
                          _switchRow(
                            "Health Updates",
                            notifHealthUpdates,
                            (v) => setState(() => notifHealthUpdates = v),
                          ),

                          const SizedBox(height: 20),

                          // NOTES
                          const Text(
                            "Notes",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          _input(notesController, "Type notes..."),

                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F52BA),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Save Changes"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // INPUT FIELD
  Widget _input(TextEditingController c, String hint) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }

  // CHIP
  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }

  // SWITCH ROW
  Widget _switchRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // BOTTOM NAV
  Widget _bottomNav() {
    return Container(
      height: 95,
      color: const Color(0xFF0F52BA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home, "Home"),
          _navItem(Icons.calendar_today, "Calendar"),
          _navItem(Icons.pets, "Pets"),
          _navItem(Icons.settings, "Settings", active: true),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool active = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            size: 30,
            color: active ? const Color(0xFFFF8A65) : Colors.white),
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
