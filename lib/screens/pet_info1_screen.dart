import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetInfo1Screen extends StatefulWidget {
  const PetInfo1Screen({super.key});

  @override
  State<PetInfo1Screen> createState() => _PetInfo1ScreenState();
}

class _PetInfo1ScreenState extends State<PetInfo1Screen> {
  final petNameController = TextEditingController();
  final speciesController = TextEditingController();
  final sexController = TextEditingController();
  final ageController = TextEditingController();

  String userName = "Friend";

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      userName = user.displayName!;
    }
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

            // Welcome Header
            const SizedBox(height: 16),
            Text(
              "Welcome $userName!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              "Add Pet Information",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),

            const SizedBox(height: 16),

            // PET NAME
            const Text(
              "Pet Name",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(petNameController, "Pet Name"),

            // SPECIES
            const SizedBox(height: 12),
            const Text(
              "Species",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(speciesController, "Species"),

            // SEX
            const SizedBox(height: 12),
            const Text(
              "Sex",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(sexController, "Sex"),

            // AGE
            const SizedBox(height: 12),
            const Text(
              "Age",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(ageController, "Age"),

            const SizedBox(height: 32),

            // NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/petinfo2",
                    arguments: {
                      "petName": petNameController.text.trim(),
                      "species": speciesController.text.trim(),
                      "sex": sexController.text.trim(),
                      "age": ageController.text.trim(),
                    },
                  );
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F52BA)),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // SKIP / DO LATER
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/tasks"),
                child: const Text(
                  "Do Later",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // PROGRESS DOTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(true),
                _dot(false),
                _dot(false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // INPUT FIELD WIDGET
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

  // DOT WIDGET
  Widget _dot(bool active) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.blue : Colors.grey.shade400,
      ),
    );
  }
}
