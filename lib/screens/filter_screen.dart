import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// GLOBAL FILTER STORAGE
class AppFilters {
  static List<String> petIds = [];
  static List<String> importance = [];
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<Map<String, dynamic>> pets = [];
  List<String> selectedPets = [...AppFilters.petIds];
  List<String> selectedImportance = [...AppFilters.importance];

  @override
  void initState() {
    super.initState();
    _loadPets();
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

  // TOGGLE PET
  void togglePet(String petId) {
    setState(() {
      if (selectedPets.contains(petId)) {
        selectedPets.remove(petId);
      } else {
        selectedPets.add(petId);
      }
    });
  }

  // TOGGLE IMPORTANCE
  void toggleImportance(String level) {
    setState(() {
      if (selectedImportance.contains(level)) {
        selectedImportance.remove(level);
      } else {
        selectedImportance.add(level);
      }
    });
  }

  // SAVE FILTERS
  void applyFilters(BuildContext context) {
    AppFilters.petIds = selectedPets;
    AppFilters.importance = selectedImportance;

    Navigator.pop(context);
  }

  void resetFilters() {
    setState(() {
      selectedPets.clear();
      selectedImportance.clear();
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F52BA),
        title: const Text("FILTER TASKS"),
        actions: [
          TextButton(
            onPressed: resetFilters,
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PET FILTER
            const Text(
              "Filter by Pets",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),

            pets.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("No pets found."),
                  )
                : SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pets.length,
                      itemBuilder: (context, i) {
                        final pet = pets[i];
                        final bool active = selectedPets.contains(pet["id"]);

                        return GestureDetector(
                          onTap: () => togglePet(pet["id"]),
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: active ? Colors.orange : Colors.grey.shade300,
                                  width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.black12,
                                  offset: Offset(0, 3),
                                )
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
                                      width: double.infinity,
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
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 30),

            // IMPORTANCE FILTER
            const Text(
              "Filter by Importance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),

            const SizedBox(height: 12),

            _importanceRow("High", Colors.redAccent),
            const SizedBox(height: 10),
            _importanceRow("Normal", Colors.orangeAccent),
            const SizedBox(height: 10),
            _importanceRow("Low", Colors.lightBlueAccent),

            const SizedBox(height: 40),

            // APPLY BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => applyFilters(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _importanceRow(String level, Color color) {
    final bool active = selectedImportance.contains(level);

    return GestureDetector(
      onTap: () => toggleImportance(level),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: active ? color : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            level,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
