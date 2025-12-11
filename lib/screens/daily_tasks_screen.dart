import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';


class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // SAFETY CHECK
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
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
                  .orderBy("createdAt", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return _emptySchedule();
                }

                return _taskList(context, docs);
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
  Widget _emptySchedule() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          "Create a task by pressing the '+' icon below!",
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ---------------- TASK LIST ----------------
  Widget _taskList(BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final task = docs[i].data();
        final taskId = docs[i].id; // ⭐ IMPORTANT: PASS FIRESTORE ID

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/editTask",
              arguments: {
                "id": taskId,
                "name": task["name"],
                "description": task["description"],
                "time": task["time"],
                "completedBy": task["completedBy"],
                "note": task["note"],
              },
            );
          },
          child: _taskCard(
            time: task["time"] ?? "",
            title: task["name"] ?? "",
            description: task["description"] ?? "",
          ),
        );
      },
    );
  }

  // ---------------- TASK CARD UI ----------------
  Widget _taskCard({
    required String time,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.more_horiz, color: Colors.black54),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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

  // ---------------- NAV BAR ----------------
  Widget _bottomNav(BuildContext context) {
    return Container(
      height: 95,
      color: const Color(0xFF0F52BA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(context, Icons.home, "Home", "/tasks", active: true),
          _navItem(context, Icons.calendar_today, "Calendar", "/calendar"),
          _navItem(context, Icons.pets, "Pets", "/pets"),
          _navItem(context, Icons.settings, "Settings", "/settings"),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context, IconData icon, String label, String route,
      {bool active = false}) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
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
      ),
    );
  }
}
