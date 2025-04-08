import 'package:Deals/login/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  bool isEditing = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalityController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // save this during login

    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please log in again.")));
      return;
    }

    final response = await ApiService.getProfile(token);

    if (response["success"]) {
      final user = response["data"];
      nameController.text = user["name"];
      emailController.text = user["email"];
      phoneController.text = user["phone_number"];
      nationalityController.text = user["nationality"];
      addressController.text = user["address"];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"])));
    }

    setState(() => isLoading = false);
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final updatedData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone_number": phoneController.text.trim(),
      "nationality": nationalityController.text.trim(),
      "address": addressController.text.trim(),
    };

    final response = await ApiService.updateProfile(updatedData, token!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["message"])),
    );

    if (response["success"]) {
      setState(() => isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    enabled: isEditing,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    enabled: isEditing,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                    enabled: isEditing,
                  ),
                  TextFormField(
                    controller: nationalityController,
                    decoration: InputDecoration(labelText: "Nationality"),
                    enabled: isEditing,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: "Address"),
                    enabled: isEditing,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        isEditing ? saveProfile() : setState(() => isEditing = true),
                    child: Text(isEditing ? "Save" : "Edit"),
                  )
                ],
              ),
            ),
    );
  }
}
