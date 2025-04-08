import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'user_provider.dart';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to view your profile.")),
      );
      return;
    }

    // First try to get data from local storage
    if (userProvider.user != null) {
      final user = userProvider.user!;
      nameController.text = user["name"] ?? "";
      emailController.text = user["email"] ?? "";
      phoneController.text = user["phone_number"] ?? "";
      nationalityController.text = user["nationality"] ?? "";
      addressController.text = user["address"] ?? "";
    }

    // Then fetch latest data from server
    final response = await ApiService.getProfile(userProvider.token!);

    if (response["success"]) {
      final user = response["data"];
      nameController.text = user["name"] ?? "";
      emailController.text = user["email"] ?? "";
      phoneController.text = user["phone_number"] ?? "";
      nationalityController.text = user["nationality"] ?? "";
      addressController.text = user["address"] ?? "";

      // Update local storage with latest data
      await userProvider.updateUserData(user);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["message"])));
    }

    setState(() => isLoading = false);
  }

  Future<void> saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final updatedData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone_number": phoneController.text.trim(),
      "nationality": nationalityController.text.trim(),
      "address": addressController.text.trim(),
    };

    final response = await ApiService.updateProfile(
      updatedData,
      userProvider.token!,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response["message"])));

    if (response["success"]) {
      // Update local storage with new data
      await userProvider.updateUserData(updatedData);
      setState(() => isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (!userProvider.isLoggedIn) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Please login to view your profile"),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text("Login"),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  nameController.text.isNotEmpty
                                      ? nameController.text[0].toUpperCase()
                                      : "U",
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                nameController.text,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Name",
                                  prefixIcon: Icon(Icons.person),
                                ),
                                enabled: isEditing,
                              ),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(Icons.email),
                                ),
                                enabled: isEditing,
                              ),
                              TextFormField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: "Phone",
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                enabled: isEditing,
                              ),
                              TextFormField(
                                controller: nationalityController,
                                decoration: InputDecoration(
                                  labelText: "Nationality",
                                  prefixIcon: Icon(Icons.flag),
                                ),
                                enabled: isEditing,
                              ),
                              TextFormField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  labelText: "Address",
                                  prefixIcon: Icon(Icons.home),
                                ),
                                enabled: isEditing,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 45),
                              backgroundColor: Colors.blue,
                            ),
                            onPressed:
                                () =>
                                    isEditing
                                        ? saveProfile()
                                        : setState(() => isEditing = true),
                            child: Text(
                              isEditing ? "Save Changes" : "Edit Profile",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        if (!isEditing) ...[
                          SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                userProvider.logout();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Logged out successfully"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

