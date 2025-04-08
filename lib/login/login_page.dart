import 'package:Deals/home_screen.dart';
import 'package:flutter/material.dart';
import 'api_service.dart'; // Import your API service

class Loginnnn extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}


class _AuthScreenState extends State<Loginnnn> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();

    Map<String, dynamic> response;

    if (isLogin) {
      response = await ApiService.loginUser(email, password);
    } else {
      response = await ApiService.registerUser(name, email, password);
    }

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["message"])),
    );

    if (response["success"]) {
      print(isLogin ? "User Logged In" : "User Registered");
      // Navigate to Home Page (Example)
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
                  decoration: InputDecoration(labelText: "Name"),
                  validator: (value) => value!.isEmpty ? "Enter your name" : null,
                ),
                SizedBox(height: 10),
              ],
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Password must be 6+ chars" : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(isLogin ? "Login" : "Register"),
                    ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Create an account" : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
