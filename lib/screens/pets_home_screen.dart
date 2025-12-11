import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetsHomeScreen extends StatelessWidget {
  const PetsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNav(),
      body: Column(
        children: [
          // TOP BAR
          Container(
            height: 100,
            color: const Color(0xFF0F52BA),
            alignment: Alignment.center,
            child: const Text(
              "PET MINDER",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // PET LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user!.uid)
                  .collection("pets")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pets = snapshot.data!.docs;

                if (pets.isEmpty) {
                  return const Center(
                    child: Text(
                      "No pets added yet.\nUse PetInfo screens to add pets.",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index].data() as Map<String, dynamic>;
                    final petId = pets[index].id;

                    return _petCard(
                      context: context,
                      petId: petId,
                      name: pet["petName"],
                      species: pet["species"],
                      age: pet["age"],
                      imageUrl: pet["imageUrl"],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // PET CARD UI (LEFT SCREEN)
  Widget _petCard({
    required BuildContext context,
    required String petId,
    required String name,
    required String species,
    required String age,
    required String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/petDetail",
          arguments: petId,
        );
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                blurRadius: 6, color: Colors.black12, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // PET IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl ?? "",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets, size: 40),
                ),
              ),
            ),

            // TEXT INFO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SPECIES TAG
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        species,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // NAME
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // AGE
                    Text(
                      "$age years",
                      style: const TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _bottomNav() {
    return Container(
      height: 95,
      color: const Color(0xFF0F52BA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home, "Home"),
          _navItem(Icons.calendar_today, "Calendar"),
          _navItem(Icons.pets, "Pets", active: true),
          _navItem(Icons.settings, "Settings"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool active = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: active ? const Color(0xFFFF8A65) : Colors.white,
        ),
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
