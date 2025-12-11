import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:petminder_flutter/widgets/bottom_nav.dart';
import 'package:petminder_flutter/screens/filter_screen.dart'; // For AppFilters

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime focusedMonth = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Map<String, List<Map<String, dynamic>>> tasksByDay = {};

  @override
  void initState() {
    super.initState();
    loadMonthTasks();
  }

  // LOAD ALL TASKS FOR THE MONTH
  Future<void> loadMonthTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    DateTime lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .where("date", isGreaterThanOrEqualTo: firstDay)
        .where("date", isLessThanOrEqualTo: lastDay)
        .get();

    Map<String, List<Map<String, dynamic>>> map = {};

    for (var doc in snap.docs) {
      final t = doc.data() as Map<String, dynamic>;
      t["id"] = doc.id; // for editing

      // FILTER BY PET
      if (AppFilters.petIds.isNotEmpty &&
          !AppFilters.petIds.contains(t["petId"])) {
        continue;
      }

      // FILTER BY IMPORTANCE
      if (AppFilters.importance.isNotEmpty &&
          !AppFilters.importance.contains(t["importance"])) {
        continue;
      }

      DateTime date = (t["date"] as Timestamp).toDate();
      String key = DateFormat("yyyy-MM-dd").format(date);

      map.putIfAbsent(key, () => []);
      map[key]!.add(t);
    }

    setState(() => tasksByDay = map);
  }

  // --- UI STARTS HERE ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNav(activeIndex: 1),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, "/createTask")
            .then((_) => loadMonthTasks()),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              _header(),
              _monthSelector(),
              _calendarGrid(),
            ],
          ),

          _taskSlideUpPanel(),
        ],
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Container(
      height: 100,
      width: double.infinity,
      color: const Color(0xFF0F52BA),
      alignment: Alignment.center,
      child: const Text(
        "CALENDAR",
        style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // MONTH SELECTOR
  Widget _monthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              child: const Icon(Icons.chevron_left, size: 32),
              onTap: () {
                setState(() {
                  focusedMonth =
                      DateTime(focusedMonth.year, focusedMonth.month - 1);
                });
                loadMonthTasks();
              }),
          Text(
            DateFormat("MMMM yyyy").format(focusedMonth),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
              child: const Icon(Icons.chevron_right, size: 32),
              onTap: () {
                setState(() {
                  focusedMonth =
                      DateTime(focusedMonth.year, focusedMonth.month + 1);
                });
                loadMonthTasks();
              }),
        ],
      ),
    );
  }

  // CALENDAR GRID (SUNDAY FIRST)
  Widget _calendarGrid() {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final firstWeekday = firstDay.weekday % 7;
    final totalDays =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    List<Widget> cells = [];

    // EMPTY CELLS BEFORE DAY 1
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(Container());
    }

    // DAYS OF MONTH
    for (int day = 1; day <= totalDays; day++) {
      DateTime date =
          DateTime(focusedMonth.year, focusedMonth.month, day);
      String key = DateFormat("yyyy-MM-dd").format(date);

      bool isSelected =
          DateFormat("yyyy-MM-dd").format(selectedDay) == key;

      // DOT COLOR SELECTED BY IMPORTANCE
      Color? dotColor;

      if (tasksByDay.containsKey(key)) {
        final tasks = tasksByDay[key]!;

        bool hasHigh =
            tasks.any((t) => t["importance"] == "High");
        bool hasNormal =
            tasks.any((t) => t["importance"] == "Normal");
        bool hasLow =
            tasks.any((t) => t["importance"] == "Low");

        if (hasHigh) dotColor = Colors.redAccent;
        else if (hasNormal) dotColor = Colors.orangeAccent;
        else if (hasLow) dotColor = Colors.lightBlueAccent;
      }

      cells.add(
        GestureDetector(
          onTap: () => setState(() => selectedDay = date),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFFF8A65)
                      : Colors.transparent,
                ),
                child: Text(
                  "$day",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),

              if (dotColor != null)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        children: cells,
      ),
    );
  }

  // SLIDE-UP TASK PANEL (COLLAPSED: 2 tasks)
  Widget _taskSlideUpPanel() {
    final key = DateFormat("yyyy-MM-dd").format(selectedDay);
    final tasks = tasksByDay[key] ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.18,
      maxChildSize: 0.75,
      builder: (context, scroll) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 10,
                  color: Colors.black26,
                  offset: Offset(0, -2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              Text(
                DateFormat("MMMM d").format(selectedDay),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: tasks.length.clamp(0, 50),
                  itemBuilder: (context, i) {
                    final t = tasks[i];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/editTask",
                          arguments: t,
                        ).then((_) => loadMonthTasks());
                      },
                      child: _taskTile(t),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // TASK TILE FOR SLIDE-UP PANEL
  Widget _taskTile(Map<String, dynamic> t) {
    String title = t["name"];
    String time = t["time"];
    String? img = t["petImageUrl"];
    String importance = t["importance"];

    Color color = Colors.orange;
    if (importance == "High") color = Colors.redAccent;
    if (importance == "Low") color = Colors.lightBlueAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // PET IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              img ?? "",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
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
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          // IMPORTANCE DOT
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
