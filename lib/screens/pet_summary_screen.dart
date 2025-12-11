import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petminder_flutter/helpers/image_upload.dart';

class PetSummaryScreen extends StatefulWidget {
  const PetSummaryScreen({super.key});

  @override
  State<PetSummaryScreen> createState() => _PetSummaryScreenState();
}

class _PetSummaryScreenState extends State<PetSummaryScreen> {
  String? petImageUrl;

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

    petName = data["petName"];
    species = data["species"];
    sex = data["sex"];
    age = data["age"];
    birthday = data["birthday"];
    weight = data["weight"];
    height = data["height"];
    vaccines = data["vaccines"];
  }

  Future<void> uploadPetImage() async {
    final url = await pickAndUploadPetImage();
    if (url != null) {
      setState(() {
        petImageUrl = url;
      });
    }
  }

  Future<void> savePet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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
      "imageUrl": petImageUrl,
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
            Row(
              children: [
                Image.asset("assets/images/ic_pet_logo.png", width: 42, height: 42),
                const SizedBox(width: 8),
                const Text("Pet Minder",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 16),

            Text("Welcome, $petName!",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

            // IMAGE PICKER BOX
            const SizedBox(height: 16),
            GestureDetector(
              onTap: uploadPetImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: petImageUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload, size: 32),
                          SizedBox(height: 8),
                          Text("Upload Image",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          petImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(petName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _info("Birthday", birthday),
                  _info("Species", species),
                  _info("Weight", weight),
                  _info("Height", height),
                  _info("Sex", sex),
                  _info("Age", age),
                  _info("Vaccines", vaccines),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: savePet,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F52BA)),
                child: const Text("Finish", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text("$label: $value",
          style: const TextStyle(color: Color(0xFF333333))),
    );
  }
}
