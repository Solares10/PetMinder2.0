import 'package:flutter/material.dart';
import 'package:petminder_flutter/widgets/bottom_nav.dart';

class CalendarMinimizedScreen extends StatelessWidget {
  const CalendarMinimizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/createTask");
        },
        backgroundColor: const Color(0xFFFF6F61), // vibrant_coral
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const BottomNav(activeIndex: 1),


      body: Column(
        children: [
          // ================= TOP BAR =================
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            color: const Color(0xFF0F52BA),
            child: const Text(
              "CALENDAR",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // ================= SCROLL CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(
                      "assets/images/ic_calendar_min.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Selected date text
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Thur. Nov. 20",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Task List Container
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Example task entries (in XML you used <include> twice)
                        _taskCard(
                          time: "08:30 AM",
                          title: "Feeding",
                          description: "Feed the dog",
                        ),
                        const SizedBox(height: 8),
                        _taskCard(
                          time: "02:00 PM",
                          title: "Walk",
                          description: "30-minute walk outside",
                        ),
                      ],
                    ),
                  ),

                  // Extra spacing above bottom nav
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TASK CARD UI =================
  Widget _taskCard({
    required String time,
    required String title,
    required String description,
  }) {
    return Row(
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.black87),
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
    );
  }

  // ================= BOTTOM NAVIGATION =================
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
          size: 32,
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
    );
  }
}
