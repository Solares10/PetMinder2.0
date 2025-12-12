import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';
import 'package:petminder_flutter/screens/filter_screen.dart';

// CLEAN TIME FUNCTION (fixes Chrome’s hidden unicode spaces)
String cleanTime(String t) =>
    t.replaceAll(RegExp(r"\u202F|\u00A0|\s+"), " ").trim();

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/createTask"),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: const BottomNav(activeIndex: 0),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .collection("tasks")
                  .orderBy("date")
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                // See exact Firestore message in the console
                if (snapshot.hasError) {
                  debugPrint('DailyTasks error: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Error loading tasks.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // Apply filters
                final filtered = docs.where((doc) {
                  final t = doc.data();

                  // Filter by pets
                  if (AppFilters.petIds.isNotEmpty &&
                      !AppFilters.petIds.contains(t["petId"])) {
                    return false;
                  }

                  // Filter by importance
                  if (AppFilters.importance.isNotEmpty &&
                      !AppFilters.importance.contains(t["importance"])) {
                    return false;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final task = filtered[index].data();
                    final id = filtered[index].id;

                    return _taskTile(context, task, id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    String today = DateFormat('MMMM d').format(DateTime.now());

    return Column(
      children: [
        Container(
          height: 100,
          width: double.infinity,
          color: const Color(0xFF0F52BA),
          alignment: Alignment.center,
          child: const Text(
            "DAILY TASKS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              today,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "No tasks yet.\nTap + to create a task!",
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ---------------- TASK TILE ----------------
  Widget _taskTile(BuildContext context, Map<String, dynamic> t, String id) {
    String title = t["name"] ?? "Untitled";
    String desc = t["description"] ?? "";
    String time = cleanTime(t["time"] ?? "");
    String? image = t["petImageUrl"];

    Color dotColor = Colors.orangeAccent;
    switch (t["importance"]) {
      case "High":
        dotColor = Colors.redAccent;
        break;
      case "Low":
        dotColor = Colors.lightBlueAccent;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/editTask",
          arguments: {
            "id": id,
            ...t,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 70,
              child: Text(
                time,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // PET IMAGE WITH FALLBACK
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: image == null
                          ? Container(
                              width: 55,
                              height: 55,
                              color: Colors.grey[300],
                              child: const Icon(Icons.pets),
                            )
                          : Image.network(
                              image,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 55,
                                height: 55,
                                color: Colors.grey[300],
                                child: const Icon(Icons.pets),
                              ),
                            ),
                    ),

                    const SizedBox(width: 12),

                    // TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

                    // IMPORTANCE DOT
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
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
}
