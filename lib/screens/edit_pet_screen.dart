import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditPetScreen extends StatefulWidget {
  const EditPetScreen({super.key});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final name = TextEditingController();
  final species = TextEditingController();
  final sex = TextEditingController();
  final age = TextEditingController();
  final birthday = TextEditingController();
  final weight = TextEditingController();
  final height = TextEditingController();
  final vaccines = TextEditingController();

  File? newImageFile;
  String? existingImageURL;
  late String petId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    petId = data["id"];
    name.text = data["petName"];
    species.text = data["species"];
    sex.text = data["sex"];
    age.text = data["age"];
    birthday.text = data["birthday"];
    weight.text = data["weight"];
    height.text = data["height"];
    vaccines.text = data["vaccines"];
    existingImageURL = data["imageUrl"];
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newImageFile = File(picked.path));
    }
  }

  Future<void> saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String imageURL = existingImageURL ?? "";

    if (newImageFile != null) {
      final ref = FirebaseStorage.instance
          .ref("pets/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await ref.putFile(newImageFile!);
      imageURL = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("pets")
        .doc(petId)
        .update({
      "petName": name.text.trim(),
      "species": species.text.trim(),
      "sex": sex.text.trim(),
      "age": age.text.trim(),
      "birthday": birthday.text.trim(),
      "weight": weight.text.trim(),
      "height": height.text.trim(),
      "vaccines": vaccines.text.trim(),
      "imageUrl": imageURL,
      "updatedAt": DateTime.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text("EDIT PET"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // IMAGE PREVIEW
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12)),
                child: newImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(newImageFile!, fit: BoxFit.cover),
                      )
                    : existingImageURL != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(existingImageURL!,
                                fit: BoxFit.cover),
                          )
                        : const Icon(Icons.pets, size: 60),
              ),
            ),

            const SizedBox(height: 20),

            _field("Name", name),
            _field("Species", species),
            _field("Sex", sex),
            _field("Age", age),
            _field("Birthday", birthday),
            _field("Weight", weight),
            _field("Height", height),
            _field("Vaccines", vaccines),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800),
                child: const Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey)),
          child: TextField(
            controller: controller,
            decoration:
                const InputDecoration(border: InputBorder.none),
          ),
        )
      ],
    );
  }
}
