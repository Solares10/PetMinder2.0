import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:petminder_flutter/widgets/bottom_nav.dart';
import 'package:petminder_flutter/screens/filter_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime focusedMonth = DateTime.now();
  DateTime selectedDay = DateTime.now();

  // key: "yyyy-MM-dd" → list of tasks
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

  // ---------------- MINI 3-WEEK CALENDAR ----------------
  Widget _miniThreeWeekCalendar() {
    // Start of selected week (Sunday)
    final startOfCurrentWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday % 7),
    );

    final startOfPrevWeek =
    startOfCurrentWeek.subtract(const Duration(days: 7));
    final startOfNextWeek =
    startOfCurrentWeek.add(const Duration(days: 7));

    // Weekday labels for the header row (Sun..Sat) based on current week
    final headerDays =
    List.generate(7, (i) => startOfCurrentWeek.add(Duration(days: i)));

    // Helper: builds ONE week row (numbers + dots only)
    Widget buildWeekRow(DateTime start) {
      final days = List.generate(7, (i) => start.add(Duration(days: i)));

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((date) {
            final key = DateFormat("yyyy-MM-dd").format(date);
            final isSelected =
                DateFormat("yyyy-MM-dd").format(selectedDay) == key;

            // Dot color logic (reuse full grid logic)
            Color? dotColor;
            if (tasksByDay.containsKey(key)) {
              final tasks = tasksByDay[key]!;
              bool hasHigh = tasks.any((t) => t["importance"] == "High");
              bool hasNormal = tasks.any((t) => t["importance"] == "Normal");
              bool hasLow = tasks.any((t) => t["importance"] == "Low");

              if (hasHigh) {
                dotColor = Colors.redAccent;
              } else if (hasNormal) {
                dotColor = Colors.orangeAccent;
              } else if (hasLow) {
                dotColor = Colors.lightBlueAccent;
              }
            }

            return GestureDetector(
              onTap: () {
                final previousFocused = focusedMonth;

                setState(() {
                  selectedDay = date;

                  if (date.month != focusedMonth.month ||
                      date.year != focusedMonth.year) {
                    focusedMonth = DateTime(date.year, date.month);
                  }
                });

                if (focusedMonth != previousFocused) {
                  loadMonthTasks();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day circle
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFFFF8A65)
                          : Colors.transparent,
                    ),
                    child: Text(
                      "${date.day}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  // Dot (if tasks exist)
                  if (dotColor != null)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    // Full mini calendar: weekday header + 3 week rows
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weekday header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: headerDays.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;

              // Highlight the column that matches the selected day-of-week
              final isSelectedDow =
                  (selectedDay.weekday % 7) == (date.weekday % 7);

              return SizedBox(
                width: 28,
                child: Center(
                  child: Text(
                    DateFormat.E().format(date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      isSelectedDow ? FontWeight.bold : FontWeight.normal,
                      color: isSelectedDow ? Colors.blue : Colors.black54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),

          buildWeekRow(startOfPrevWeek),
          buildWeekRow(startOfCurrentWeek),
          buildWeekRow(startOfNextWeek),
        ],
      ),
    );
  }


  // ---------------- UI ----------------

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

      body: Column(
        children: [
          // FIXED HEADER
          _header(),

          // SCROLLABLE AREA (month selector + calendar + tasks)
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CalendarSliverDelegate(
                      minHeight: 200,
                      maxHeight: 480,
                      buildMonthSelector: (context) => _monthSelector(),
                      buildFull: (context) => _calendarGrid(),
                      buildMini: (context) => _miniThreeWeekCalendar(),
                    ),
                  ),

                ];
              },
              body: _tasksListBody(),
            ),
          ),
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
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
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
            },
          ),
          Text(
            DateFormat("MMMM yyyy").format(focusedMonth),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            child: const Icon(Icons.chevron_right, size: 32),
            onTap: () {
              setState(() {
                focusedMonth =
                    DateTime(focusedMonth.year, focusedMonth.month + 1);
              });
              loadMonthTasks();
            },
          ),
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
      DateTime date = DateTime(focusedMonth.year, focusedMonth.month, day);
      String key = DateFormat("yyyy-MM-dd").format(date);

      bool isSelected =
          DateFormat("yyyy-MM-dd").format(selectedDay) == key;

      // DOT COLOR SELECTED BY IMPORTANCE
      Color? dotColor;

      if (tasksByDay.containsKey(key)) {
        final tasks = tasksByDay[key]!;

        bool hasHigh = tasks.any((t) => t["importance"] == "High");
        bool hasNormal = tasks.any((t) => t["importance"] == "Normal");
        bool hasLow = tasks.any((t) => t["importance"] == "Low");

        if (hasHigh) {
          dotColor = Colors.redAccent;
        } else if (hasNormal) {
          dotColor = Colors.orangeAccent;
        } else if (hasLow) {
          dotColor = Colors.lightBlueAccent;
        }
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

  // TASK LIST BODY (SCROLLS AND COLLAPSES HEADER)
  // TASK LIST BODY (SCROLLS AND COLLAPSES HEADER)
  Widget _tasksListBody() {
    final key = DateFormat("yyyy-MM-dd").format(selectedDay);
    final tasks = tasksByDay[key] ?? [];

    // EMPTY STATE (no scrolling, just message)
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "No tasks for ${DateFormat("MMMM d").format(selectedDay)}.\nTap + to create one!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    // If there are only a few tasks, don't let the inner list scroll.
    final bool fewTasks = tasks.length <= 2; // bump to 3 if you want

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        24,  // <- constant top padding now
        16,
        90,
      ),
      physics: fewTasks
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      itemCount: tasks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              DateFormat("MMMM d").format(selectedDay),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final t = tasks[index - 1];

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
    );
  }



  // TASK TILE
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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

// ---------------- SLIVER DELEGATE FOR COLLAPSING CALENDAR ----------------

class _CalendarSliverDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget Function(BuildContext) buildMonthSelector;
  final Widget Function(BuildContext) buildFull;
  final Widget Function(BuildContext) buildMini;

  _CalendarSliverDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.buildMonthSelector,
    required this.buildFull,
    required this.buildMini,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final calendar = t < 0.5 ? buildFull(context) : buildMini(context);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          buildMonthSelector(context),
          Expanded(child: calendar),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_CalendarSliverDelegate oldDelegate) => true;
}
