import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int activeIndex;
  const BottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F52BA),
      ),
      child: Row(
        children: [
          _navItem(
            context,
            index: 0,
            icon: Icons.home,
            label: "Home",
            route: "/tasks",
          ),
          _navItem(
            context,
            index: 1,
            icon: Icons.calendar_today,
            label: "Calendar",
            route: "/calendar",
          ),
          _navItem(
            context,
            index: 2,
            icon: Icons.pets,
            label: "Pets",
            route: "/pets",
          ),
          _navItem(
            context,
            index: 3,
            icon: Icons.settings,
            label: "Settings",
            route: "/settings",
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool isActive = index == activeIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? const Color(0xFFFF8A65) : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFFFF8A65) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
