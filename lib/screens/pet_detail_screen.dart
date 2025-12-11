import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'delete_pet_dialog.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petId = ModalRoute.of(context)!.settings.arguments as String;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("pets")
            .doc(petId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final pet = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              // TOP BAR
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                color: const Color(0xFF0F52BA),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        pet["petName"].toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/editPet", arguments: {
                          "id": petId,
                          ...pet
                        });
                      },
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => DeletePetDialog(
                            onDelete: () async {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user.uid)
                                  .collection("pets")
                                  .doc(petId)
                                  .delete();

                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            onCancel: () => Navigator.pop(context),
                          ),
                        );
                      },
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // PET IMAGE
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: Image.network(
                          pet["imageUrl"] ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, size: 100),
                          ),
                        ),
                      ),

                      // DETAILS CARD
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet["petName"],
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 16),
                            const Text("Birthday",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            _tag(pet["birthday"]),

                            const SizedBox(height: 16),
                            const Text("Attributes:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),

                            Wrap(
                              spacing: 10,
                              children: [
                                _tag(pet["species"]),
                                _tag("${pet["weight"]}"),
                                _tag(pet["sex"]),
                                _tag("${pet["height"]}"),
                                _tag(pet["vaccines"]),
                                _tag(pet["age"]),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}
