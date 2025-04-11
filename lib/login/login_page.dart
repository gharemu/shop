import 'package:flutter/material.dart';
import 'package:Deals/home_screen.dart';
import 'package:Deals/adminfiles/admin_dashboard.dart';
import 'api_service.dart';

class Loginnnn extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<Loginnnn> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isLoading = false;
  String errorMessage = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();

    try {
      Map<String, dynamic> response;
      
      if (isLogin) {
        print("Attempting login with: $email");
        response = await ApiService.loginUser(email, password);
        print("Login Response: $response");
      } else {
        print("Attempting registration with: $email");
        response = await ApiService.registerUser(name, email, password);
        print("Registration Response: $response");
      }

      if (response["success"] == true) {
        bool isAdmin = response["isAdmin"] == true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isAdmin ? const AdminDashboard() : const HomeScreen(),
          ),
        );
      } else {
        setState(() {
          errorMessage = response["message"] ?? "Operation failed. Please try again.";
        });
      }
    } catch (e) {
      print("Error details: $e");
      setState(() {
        if (e.toString().contains("Failed to fetch")) {
          errorMessage = "Cannot connect to server. Please check your internet connection and make sure the server is running.";
        } else {
          errorMessage = "An error occurred: ${e.toString()}";
        }
      });
    } finally {
      setState(() => isLoading = false);
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Register")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLogin) ...[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 10),
              ],
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.isEmpty ? "Enter a valid email" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "Password must be 6+ chars" : null,
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(isLogin ? "Login" : "Register"),
                    ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin
                    ? "Create an account"
                    : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
