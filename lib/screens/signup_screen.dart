import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user!.updateDisplayName(name);

      Navigator.pushReplacementNamed(context, "/petinfo1");
    } on FirebaseAuthException catch (e) {
      String message = "Sign up failed.";

      if (e.code == "email-already-in-use") {
        message = "Email is already registered.";
      } else if (e.code == "invalid-email") {
        message = "Invalid email format.";
      } else if (e.code == "weak-password") {
        message = "Password is too weak.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
            // LOGO ROW
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
                      color: Colors.black),
                )
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              "Create new account",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // FULL NAME
            const SizedBox(height: 24),
            const Text(
              "Full Name",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(fullNameController, "Full Name"),

            // EMAIL
            const SizedBox(height: 16),
            const Text(
              "Email",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(emailController, "Email"),

            // PASSWORD
            const SizedBox(height: 16),
            const Text(
              "Password",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(passwordController, "Password", obscure: true),

            // CONFIRM PASSWORD
            const SizedBox(height: 16),
            const Text(
              "Confirm Password",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            _input(confirmPasswordController, "Confirm Password",
                obscure: true),

            // SIGN UP BUTTON
            const SizedBox(height: 32),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: signUp,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F52BA)),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? ",
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/signin"),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint,
      {bool obscure = false}) {
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
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }
}
