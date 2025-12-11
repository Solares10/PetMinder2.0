import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PetSummaryScreen extends StatefulWidget {
  const PetSummaryScreen({super.key});

  @override
  State<PetSummaryScreen> createState() => _PetSummaryScreenState();
}

class _PetSummaryScreenState extends State<PetSummaryScreen> {
  File? imageFile;

  late String petName;
  late String species;
  late String sex;
  late String age;
  late String birthday;
  late String weight;
  late String height;
  late String vaccines;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    petName = data["petName"] ?? "";
    species = data["species"] ?? "";
    sex = data["sex"] ?? "";
    age = data["age"] ?? "";
    birthday = data["birthday"] ?? "";
    weight = data["weight"] ?? "";
    height = data["height"] ?? "";
    vaccines = data["vaccines"] ?? "";
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> savePet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imageUrl;

    if (imageFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("pets/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("pets")
        .add({
      "petName": petName,
      "species": species,
      "sex": sex,
      "age": age,
      "birthday": birthday,
      "weight": weight,
      "height": height,
      "vaccines": vaccines,
      "imageUrl": imageUrl,
      "createdAt": DateTime.now(),
    });

    Navigator.pushReplacementNamed(context, "/tasks");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOGO
            Row(
              children: [
                Image.asset(
                  "assets/images/ic_pet_logo.png",
                  width: 42,
                  height: 42,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Pet Minder",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),

            // Welcome title
            const SizedBox(height: 16),
            Text(
              "Welcome, $petName!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            // UPLOAD IMAGE BOX
            const SizedBox(height: 16),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload, size: 32, color: Color(0xFF333333)),
                          SizedBox(height: 8),
                          Text(
                            "Upload Image",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          )
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          imageFile!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            // SUMMARY CARD
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "Birthday",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 4),
                  _tag(birthday),

                  const SizedBox(height: 12),
                  Text("Species: $species", style: const TextStyle(color: Color(0xFF333333))),
                  const SizedBox(height: 8),
                  Text("Weight: $weight", style: const TextStyle(color: Color(0xFF333333))),
                  const SizedBox(height: 8),
                  Text("Height: $height", style: const TextStyle(color: Color(0xFF333333))),
                  const SizedBox(height: 8),
                  Text("Sex: $sex", style: const TextStyle(color: Color(0xFF333333))),
                  const SizedBox(height: 8),
                  Text("Age: $age", style: const TextStyle(color: Color(0xFF333333))),
                  const SizedBox(height: 8),
                  Text("Vaccines: $vaccines", style: const TextStyle(color: Color(0xFF333333))),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // FINISH BUTTON
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F52BA),
                ),
                child: const Text(
                  "Finish",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // DOTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(false),
                _dot(false),
                _dot(true),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF333333))),
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
