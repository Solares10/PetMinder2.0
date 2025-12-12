import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = cred.user!.uid;

      final petsSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("pets")
          .limit(1) // we only care if there's at least 1
          .get();
      final hasPet = petsSnapshot.docs.isNotEmpty;

      if (hasPet) {
        // Returning user → skip onboarding
        Navigator.pushReplacementNamed(context, "/tasks"); // or "/pets"
      } else {
        // First-time user → go to pet onboarding
        Navigator.pushReplacementNamed(context, "/petinfo1");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";

      if (e.code == "user-not-found") {
        errorMessage = "No user found with that email.";
      } else if (e.code == "wrong-password") {
        errorMessage = "Incorrect password.";
      } else if (e.code == "invalid-email") {
        errorMessage = "Invalid email format.";
      } else if (e.code == "network-request-failed") {
        errorMessage = "Network error. Check your connection.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
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
            // Logo
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
                )
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Email",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            _input(emailController, "Email"),

            const SizedBox(height: 16),
            const Text(
              "Password",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            _input(passwordController, "Password", obscure: true),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA)),
                child: const Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/signup"),
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, {bool obscure = false}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E))),
      ),
    );
  }
}
