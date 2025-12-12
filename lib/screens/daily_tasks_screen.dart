import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';

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
      bottomNavigationBar: const BottomNav(activeIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/createTask"),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final t = docs[i].data();
                    final id = docs[i].id;
                    return _taskTile(context, t, id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final today = DateFormat('MMMM d').format(DateTime.now());
    return Column(
      children: [
        Container(
          height: 100,
          alignment: Alignment.center,
          color: const Color(0xFF0F52BA),
          child: const Text(
            "DAILY TASKS",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              today,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  Widget _emptyState() => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No tasks yet.\nTap + to create one!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );

  Widget _taskTile(BuildContext context, Map<String, dynamic> t, String id) {
    final title = t["name"] ?? "Untitled";
    final desc = t["description"] ?? "";
    final petName = t["petName"] ?? "";
    final image = t["petImageUrl"];
    final time = cleanTime(t["time"] ?? "");

    Color dotColor = Colors.orangeAccent;
    switch (t["importance"]) {
      case "High":
        dotColor = Colors.redAccent;
        break;
      case "Low":
        dotColor = Colors.blueAccent;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/editTask", arguments: {"id": id, ...t});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(time,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(petName,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(desc,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
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
