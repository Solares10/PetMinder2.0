import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';

class PetsHomeScreen extends StatefulWidget {
  const PetsHomeScreen({super.key});

  @override
  State<PetsHomeScreen> createState() => _PetsHomeScreenState();
}

class _PetsHomeScreenState extends State<PetsHomeScreen> {
  bool gridView = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8A65),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, "/petinfo1");
        },
      ),
bottomNavigationBar: const BottomNav(activeIndex: 2),

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
                  color: Colors.white),
            ),
          ),

          // Toggle Row
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(gridView ? Icons.view_list : Icons.grid_view),
                  onPressed: () {
                    setState(() => gridView = !gridView);
                  },
                ),
              ],
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
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No pets added yet.\nTap + to add your first pet!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                return gridView
                    ? _buildGridView(pets)
                    : _buildListView(pets);
              },
            ),
          ),
        ],
      ),
    );
  }

  // LIST VIEW
  Widget _buildListView(List<QueryDocumentSnapshot> pets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index].data() as Map<String, dynamic>;
        final petId = pets[index].id;

        return _petCardList(
          context: context,
          petId: petId,
          name: pet["petName"],
          species: pet["species"],
          age: pet["age"],
          imageUrl: pet["imageUrl"],
        );
      },
    );
  }

  // GRID VIEW
  Widget _buildGridView(List<QueryDocumentSnapshot> pets) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final pet = pets[index].data() as Map<String, dynamic>;
        final petId = pets[index].id;

        return _petCardGrid(
          context: context,
          petId: petId,
          name: pet["petName"],
          species: pet["species"],
          age: pet["age"],
          imageUrl: pet["imageUrl"],
        );
      },
    );
  }

  // LIST CARD UI
  Widget _petCardList({
    required BuildContext context,
    required String petId,
    required String name,
    required String species,
    required String age,
    required String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, "/petDetail", arguments: petId),
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                blurRadius: 6, color: Colors.black12, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // IMAGE
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
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$age years",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // GRID CARD UI
  Widget _petCardGrid({
    required BuildContext context,
    required String petId,
    required String name,
    required String species,
    required String age,
    required String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, "/petDetail", arguments: petId),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                blurRadius: 6, color: Colors.black12, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl ?? "",
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets, size: 40),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    species,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // NAV BAR
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
        Icon(icon,
            size: 30,
            color: active ? const Color(0xFFFF8A65) : Colors.white),
        Text(
          label,
          style: TextStyle(
              color:
                  active ? const Color(0xFFFF8A65) : Colors.white,
              fontSize: 14),
        ),
      ],
    );
  }
}
