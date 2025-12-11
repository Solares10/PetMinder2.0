import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';

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
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),

      bottomNavigationBar: const BottomNav(activeIndex: 0),

      body: Column(
        children: [
          _header(),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .collection("tasks")
                  .orderBy("date")
                  .orderBy("time") // sorts properly
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return _empty();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final task = docs[i].data();

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/editTask",
                          arguments: {
                            "id": docs[i].id,
                            "name": task["name"],
                            "description": task["description"],
                            "importance": task["importance"],
                            "petId": task["petId"],
                            "petName": task["petName"],
                            "petImageUrl": task["petImageUrl"],
                            "date": task["date"],
                            "time": task["time"],
                          },
                        );
                      },
                      child: _taskCard(task),
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

  // -------- HEADER --------
  Widget _header() {
    final today = DateFormat('MMMM d').format(DateTime.now());

    return Column(
      children: [
        Container(
          height: 100,
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
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------- EMPTY UI --------
  Widget _empty() {
    return const Center(
      child: Text(
        "No tasks yet.\nTap + to add one!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  // -------- TASK CARD UI --------
  Widget _taskCard(Map<String, dynamic> task) {
    String time = task["time"] ?? "";
    String title = task["name"] ?? "";
    String desc = task["description"] ?? "";

    String importance = task["importance"] ?? "Normal";

    Color color = Colors.grey;
    if (importance == "High") color = Colors.redAccent;
    if (importance == "Normal") color = Colors.orangeAccent;
    if (importance == "Low") color = Colors.lightBlueAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SHOW TIME
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // PET IMAGE + TASK CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // PET IMAGE ONLY (your choice)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      task["petImageUrl"] ?? "",
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

                  const SizedBox(width: 10),

                  // TASK TITLE + DESC
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                      color: color,
                      shape: BoxShape.circle,
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
}
