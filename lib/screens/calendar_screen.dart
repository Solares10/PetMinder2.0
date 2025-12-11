import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Map<String, List<Map<String, dynamic>>> taskMap = {};

  @override
  void initState() {
    super.initState();
    _loadMonthTasks();
  }

  // ---------------- LOAD MONTH TASKS ----------------
  Future<void> _loadMonthTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime first = DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime last = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .where("date", isGreaterThanOrEqualTo: first)
        .where("date", isLessThanOrEqualTo: last)
        .get();

    taskMap.clear();
    for (var doc in snap.docs) {
      final data = doc.data();
      final DateTime date = (data["date"] as Timestamp).toDate();
      final key = DateFormat("yyyy-MM-dd").format(date);

      taskMap.putIfAbsent(key, () => []);
      taskMap[key]!.add(data);
    }

    setState(() {});
  }

  // ---------------- BUILD UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, "/createTask"),
      ),
     bottomNavigationBar: _bottomNav(context),

      body: Column(
        children: [
          _header(),
          _monthNavigation(),
          _calendarGrid(),
          _taskListForSelectedDay(),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Container(
      height: 100,
      width: double.infinity,
      color: const Color(0xFF0F52BA),
      alignment: Alignment.center,
      child: const Text(
        "CALENDAR",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------- MONTH SELECTOR ----------------
  Widget _monthNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child: const Icon(Icons.chevron_left, size: 32),
            onTap: () {
              setState(() {
                _focusedDay =
                    DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
              });
              _loadMonthTasks();
            },
          ),
          Text(
            DateFormat("MMMM yyyy").format(_focusedDay),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          GestureDetector(
            child: const Icon(Icons.chevron_right, size: 32),
            onTap: () {
              setState(() {
                _focusedDay =
                    DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
              });
              _loadMonthTasks();
            },
          ),
        ],
      ),
    );
  }

  // ---------------- CALENDAR GRID ----------------
  Widget _calendarGrid() {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDay.weekday % 7; // Sunday = 0

    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;

    List<Widget> grid = [];

    // EMPTY CELLS BEFORE DAY 1
    for (int i = 0; i < firstWeekday; i++) {
      grid.add(Container());
    }

    // DAYS OF MONTH
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(_focusedDay.year, _focusedDay.month, day);
      String key = DateFormat("yyyy-MM-dd").format(date);

      bool hasTasks = taskMap.containsKey(key);
      bool isSelected = DateFormat("yyyy-MM-dd").format(_selectedDay) == key;

      grid.add(
        GestureDetector(
          onTap: () {
            setState(() => _selectedDay = date);
          },
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFF8A65) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$day",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // DOT IF DAY HAS TASK
              if (hasTasks)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F52BA),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        children: grid,
      ),
    );
  }

  // ---------------- TASK LIST FOR SELECTED DAY ----------------
  Widget _taskListForSelectedDay() {
    String key = DateFormat("yyyy-MM-dd").format(_selectedDay);
    final tasks = taskMap[key] ?? [];

    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          "No tasks for this day.",
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tasks.length,
        itemBuilder: (context, i) {
          final t = tasks[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              t["name"] ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        },
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
          _navItem(context, Icons.home, "Home", "/tasks"),
          _navItem(context, Icons.calendar_today, "Calendar", "/calendar"),
          _navItem(context, Icons.pets, "Pets", "/pets"),
          _navItem(context, Icons.settings, "Settings", "/settings"),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
