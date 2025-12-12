import 'dart:io' show File;
import 'dart:typed_data'; // ⭐ REQUIRED FOR Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ⭐ USE imgBB upload instead of Firebase Storage
import 'package:petminder_flutter/helpers/image_upload.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // IMAGE DATA
  String? profileImageUrl;
  Uint8List? webImageBytes;
  File? localImageFile;

  // USER FIELDS
  final emailController = TextEditingController();
  final notesController = TextEditingController();
  String? birthday = "";
  String fullName = "";
  List<String> petNames = [];

  // SETTINGS
  bool notifDailyTasks = true;
  bool notifHealthUpdates = false;
  bool isEditing = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // ---------------- LOAD USER DATA ----------------
  Future<void> loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = snap.data() ?? {};

    setState(() {
      fullName = user.displayName ?? "";
      profileImageUrl = data["profileImage"];
      birthday = data["birthday"] ?? "";
      emailController.text = user.email ?? "";
      notesController.text = data["notes"] ?? "";
      notifDailyTasks = data["notifDailyTasks"] ?? true;
      notifHealthUpdates = data["notifHealthUpdates"] ?? false;
      petNames = List<String>.from(data["pets"] ?? []);
    });
  }

  // ---------------- IMAGE UPLOAD USING imgBB ----------------
  Future<void> pickProfileImage() async {
    if (!isEditing) return;

    setState(() => isUploading = true);

    final uploadedUrl = await pickAndUploadPetImage();

    setState(() => isUploading = false);

    if (uploadedUrl != null) {
      setState(() {
        profileImageUrl = uploadedUrl;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image. Try again.")),
      );
    }
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "birthday": birthday,
      "notes": notesController.text.trim(),
      "notifDailyTasks": notifDailyTasks,
      "notifHealthUpdates": notifHealthUpdates,
      "pets": petNames,
      "profileImage": profileImageUrl,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated!")),
    );
  }

  // ---------------- BUILD UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNav(activeIndex: 3),
      body: Column(
        children: [
          // ---------------- TOP BAR ----------------
          Container(
            height: 100,
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ---------------- PROFILE IMAGE ----------------
                  GestureDetector(
                    onTap: pickProfileImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : ClipOval(
                              child: profileImageUrl != null
                                  ? Image.network(profileImageUrl!,
                                      fit: BoxFit.cover)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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

                  // ---------------- CARD ----------------
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NAME + EDIT BUTTON
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isEditing ? Icons.check : Icons.edit,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() => isEditing = !isEditing);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          _section("Birthday"),
                          _chip(birthday ?? "Unknown"),

                          const SizedBox(height: 15),

                          _section("Pets"),
                          Wrap(
                            spacing: 8,
                            children: petNames.map((p) => _chip(p)).toList(),
                          ),

                          const SizedBox(height: 15),

                          _section("Email"),
                          _input(emailController, enabled: false),

                          const SizedBox(height: 15),

                          _section("Notifications"),
                          _switchRow("Daily Tasks", notifDailyTasks,
                              (v) => setState(() => notifDailyTasks = v),
                              enabled: isEditing),
                          _switchRow("Health Updates", notifHealthUpdates,
                              (v) => setState(() => notifHealthUpdates = v),
                              enabled: isEditing),

                          const SizedBox(height: 20),

                          _section("Notes"),
                          _input(notesController,
                              hint: "Type notes...", enabled: isEditing),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F52BA),
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _section(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _input(TextEditingController c,
      {String hint = "", bool enabled = true}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: TextField(
        controller: c,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text),
      );

  Widget _switchRow(String label, bool value, Function(bool) onChanged,
      {bool enabled = true}) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
