import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int activeIndex;
  const BottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFF304D9E),
      child: Row(
        children: [
          _navItem(
            context,
            icon: Icons.home,
            label: "Home",
            route: "/tasks",
            isActive: activeIndex == 0,
          ),
          _navItem(
            context,
            icon: Icons.calendar_today,
            label: "Calendar",
            route: "/calendar",
            isActive: activeIndex == 1,
          ),
          _navItem(
            context,
            icon: Icons.pets,
            label: "Pets",
            route: "/pets",
            isActive: activeIndex == 2,
          ),
          _navItem(
            context,
            icon: Icons.settings,
            label: "Settings",
            route: "/settings",
            isActive: activeIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        required bool isActive,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? const Color(0xFFFF6A43) : Colors.white,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFFFF6A43) : Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
