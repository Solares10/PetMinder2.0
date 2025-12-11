import 'package:flutter/material.dart';

class PetInfo2Screen extends StatefulWidget {
  const PetInfo2Screen({super.key});

  @override
  State<PetInfo2Screen> createState() => _PetInfo2ScreenState();
}

class _PetInfo2ScreenState extends State<PetInfo2Screen> {
  final birthdayController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final vaccinesController = TextEditingController();

  late Map<String, dynamic> petInfo1Data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    petInfo1Data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOGO
            Row(
              children: [
                Image.asset(
                  "assets/images/ic_pet_logo.png",
                  width: 42,
                  height: 42,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Pet Minder",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // BIRTHDAY
            const SizedBox(height: 16),
            _input(birthdayController, "Birthday (MM/DD/YYYY)"),

            // WEIGHT
            const SizedBox(height: 12),
            _input(weightController, "Weight"),

            // HEIGHT
            const SizedBox(height: 12),
            _input(heightController, "Height"),

            // VACCINES
            const SizedBox(height: 12),
            _input(vaccinesController, "Vaccines"),

            // NEXT BUTTON
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/summary",
                    arguments: {
                      // From PetInfo1 data
                      "petName": petInfo1Data["petName"],
                      "species": petInfo1Data["species"],
                      "sex": petInfo1Data["sex"],
                      "age": petInfo1Data["age"],

                      // From PetInfo2
                      "birthday": birthdayController.text.trim(),
                      "weight": weightController.text.trim(),
                      "height": heightController.text.trim(),
                      "vaccines": vaccinesController.text.trim(),
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F52BA),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }
}
