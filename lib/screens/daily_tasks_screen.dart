import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/createTask");
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),

      bottomNavigationBar: _bottomNav(),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user!.uid)
                  .collection("tasks")
                  .orderBy("createdAt", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return _emptySchedule();
                }

                return _taskList(snapshot.data!.docs);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- UI COMPONENTS -----------------------------

  Widget _header() {
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

        // DATE
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("October 21",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _taskList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final task = docs[i].data() as Map<String, dynamic>;

        return _taskCard(
          time: task["time"] ?? "",
          title: task["name"] ?? "",
          description: task["description"] ?? "",
        );
      },
    );
  }

  Widget _taskCard({
    required String time,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TIME
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

          // TASK CARD
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
                  // TITLE + MENU
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

  Widget _bottomNav() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(color: Color(0xFF0F52BA)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home, "Home", active: true),
          _navItem(Icons.calendar_today, "Calendar"),
          _navItem(Icons.pets, "Pets"),
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
          size: 28,
          color: active ? Color(0xFFFF8A65) : Colors.white,
        ),
        Text(
          label,
          style: TextStyle(
            color: active ? Color(0xFFFF8A65) : Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
