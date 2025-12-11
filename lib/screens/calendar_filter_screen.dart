import 'package:flutter/material.dart';

class CalendarFilterScreen extends StatefulWidget {
  const CalendarFilterScreen({super.key});

  @override
  State<CalendarFilterScreen> createState() => _CalendarFilterScreenState();
}

class _CalendarFilterScreenState extends State<CalendarFilterScreen> {
  // PET FILTERS
  bool phineas = true;
  bool felicia = false;
  bool pepe = false;

  // IMPORTANCE FILTERS
  bool high = true;
  bool medium = true;
  bool low = true;

  // RECURRENCE FILTERS
  bool oneTime = true;
  bool recurring = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: _bottomNav(),

      body: Column(
        children: [
          // ================= TOP BAR =================
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0F52BA),
            child: Row(
              children: [
                // Invisible filter icon (alpha 0)
                Opacity(
                  opacity: 0,
                  child: Icon(Icons.filter_list, color: Colors.white),
                ),

                // Center title
                const Expanded(
                  child: Text(
                    "CALENDAR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Filter icon on right
                const Icon(Icons.filter_list, color: Colors.white),
              ],
            ),
          ),

          // ================= SCROLL CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FILTER TITLE
                  const Text(
                    "FILTERS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ======= PETS SECTION =======
                  const Text(
                    "Pets",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),
                  _filterRow("Phineas", const Color(0xFFF4A026), phineas,
                      (v) => setState(() => phineas = v ?? false)),
                  const SizedBox(height: 10),
                  _filterRow("Felicia", const Color(0xFFF3EEAC), felicia,
                      (v) => setState(() => felicia = v ?? false)),
                  const SizedBox(height: 10),
                  _filterRow("Pepe", const Color(0xFF8EDDC6), pepe,
                      (v) => setState(() => pepe = v ?? false)),

                  const SizedBox(height: 20),
                  Divider(color: Color(0xFFD1D1D1), thickness: 1),

                  // ======= IMPORTANCE =======
                  const SizedBox(height: 20),
                  const Text(
                    "Importance",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),
                  _importanceGroup(
                    label: "High",
                    description:
                        "Vet Visit, Medications, Grooming appointment, Health emergencies",
                    color: Color(0xFFE65454),
                    value: high,
                    onChanged: (v) => setState(() => high = v ?? false),
                  ),

                  const SizedBox(height: 12),
                  _importanceGroup(
                    label: "Medium",
                    description: "Bath, Replace litter, Buy food",
                    color: Color(0xFF5C8AB6),
                    value: medium,
                    onChanged: (v) => setState(() => medium = v ?? false),
                  ),

                  const SizedBox(height: 12),
                  _importanceGroup(
                    label: "Low",
                    description:
                        "Feedings, Walks, Playtime, Brushing, Water refills",
                    color: Color(0xFFE5E5E5),
                    value: low,
                    onChanged: (v) => setState(() => low = v ?? false),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Color(0xFFD1D1D1), thickness: 1),

                  // ======= RECURRENCE =======
                  const SizedBox(height: 20),
                  const Text(
                    "Recurrence",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  _importanceGroup(
                    label: "One-Time",
                    description:
                        "Last-minute vet schedule, playdate, etc.",
                    color: Color(0xFFE65454),
                    value: oneTime,
                    onChanged: (v) => setState(() => oneTime = v ?? false),
                  ),

                  const SizedBox(height: 12),

                  _importanceGroup(
                    label: "Recurring",
                    description: "Daily feedings, etc.",
                    color: Color(0xFF5C8AB6),
                    value: recurring,
                    onChanged: (v) => setState(() => recurring = v ?? false),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER ROW (Pets) =================
  Widget _filterRow(
      String label, Color color, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(right: 12, left: 4),
          color: color,
        ),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 16)),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF0F52BA),
        ),
      ],
    );
  }

  // ================= IMPORTANCE + RECURRENCE ROW =================
  Widget _importanceGroup({
    required String label,
    required String description,
    required Color color,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(right: 12, left: 4),
              color: color,
            ),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 16)),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Color(0xFF0F52BA),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 4),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
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
      color: const Color(0xFF0F52BA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home, "Home"),
          _navItem(Icons.calendar_today, "Calendar", active: true),
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
          color:
              active ? const Color(0xFFFF8A65) : Colors.white,
          size: 30,
        ),
        Text(
          label,
          style: TextStyle(
            color:
                active ? const Color(0xFFFF8A65) : Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
