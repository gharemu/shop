import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'user_provider.dart';
import 'package:Deals/screen/checkout_page.dart'; // Make sure to import this

class ProfilePage extends StatefulWidget {
  final bool fromCheckout;

  const ProfilePage({Key? key, this.fromCheckout = false}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;

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
        const SnackBar(content: Text("Please log in to view your profile.")),
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
    try {
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
    } catch (e) {
      print("Error fetching profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load profile. Please try again."),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final updatedData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone_number": phoneController.text.trim(),
      "nationality": nationalityController.text.trim(),
      "address": addressController.text.trim(),
    };

    try {
      final response = await ApiService.updateProfile(
        updatedData,
        userProvider.token!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: response["success"] ? Colors.green : Colors.red,
        ),
      );

      if (response["success"]) {
        // Update local storage with new data
        await userProvider.updateUserData(updatedData);
        setState(() => isEditing = false);

        // If we came from checkout, return to checkout page
        if (widget.fromCheckout) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutPage(comingFromProfile: true),
            ),
          );
        }
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save profile. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.fromCheckout && !isEditing)
            TextButton(
              onPressed: () {
                setState(() => isEditing = true);
              },
              child: const Text(
                "Edit",
                style: TextStyle(
                  color: Color(0xFFFF3E6C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3E6C)),
              )
              : Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (!userProvider.isLoggedIn) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Please login to view your profile",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3E6C),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile header with gradient background
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFF3E6C),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFFFEE2EB),
                                  child: Text(
                                    nameController.text.isNotEmpty
                                        ? nameController.text[0].toUpperCase()
                                        : "U",
                                    style: const TextStyle(
                                      fontSize: 50,
                                      color: Color(0xFFFF3E6C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                nameController.text,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                emailController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Personal Information Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Color(0xFFFF3E6C),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Personal Information",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!widget.fromCheckout && !isEditing)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() => isEditing = true);
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Color(0xFFFF3E6C),
                                      ),
                                      label: const Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: Color(0xFFFF3E6C),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              // Information fields with improved design
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    buildProfileField(
                                      controller: nameController,
                                      label: "Full Name",
                                      icon: Icons.person_outline,
                                      isEditing: isEditing,
                                      isHighlighted: widget.fromCheckout,
                                    ),
                                    const SizedBox(height: 16),
                                    buildProfileField(
                                      controller: emailController,
                                      label: "Email Address",
                                      icon: Icons.email_outlined,
                                      isEditing: isEditing,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 16),
                                    buildProfileField(
                                      controller: phoneController,
                                      label: "Phone Number",
                                      icon: Icons.phone_outlined,
                                      isEditing: isEditing,
                                      keyboardType: TextInputType.phone,
                                      isHighlighted: widget.fromCheckout,
                                    ),
                                    const SizedBox(height: 16),
                                    buildProfileField(
                                      controller: nationalityController,
                                      label: "Nationality",
                                      icon: Icons.flag_outlined,
                                      isEditing: isEditing,
                                    ),
                                    const SizedBox(height: 16),
                                    buildProfileField(
                                      controller: addressController,
                                      label: "Delivery Address",
                                      icon: Icons.home_outlined,
                                      isEditing: isEditing,
                                      maxLines: 3,
                                      isHighlighted: widget.fromCheckout,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Buttons section
                              if (isEditing)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isEditing = false;
                                            // Reset to original values
                                            fetchProfile();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black87,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          "CANCEL",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            isSaving ? null : saveProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFF3E6C,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child:
                                            isSaving
                                                ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : const Text(
                                                  "SAVE CHANGES",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ],
                                )
                              else if (!widget.fromCheckout)
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      userProvider.logout();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Logged out successfully",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/login');
                                    },
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      "LOGOUT",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditing,
    bool isHighlighted = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted && !isEditing ? const Color(0xFFFFF5F7) : null,
        borderRadius: BorderRadius.circular(8),
        border:
            isHighlighted && !isEditing
                ? Border.all(color: const Color(0xFFFF3E6C), width: 1)
                : null,
      ),
      padding:
          isHighlighted && !isEditing
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              : EdgeInsets.zero,
      child: TextField(
        controller: controller,
        enabled: isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: isEditing ? Colors.black87 : Colors.black54,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: isHighlighted ? const Color(0xFFFF3E6C) : Colors.grey,
          ),
          labelStyle: TextStyle(
            color: isHighlighted ? const Color(0xFFFF3E6C) : null,
          ),
          border:
              isEditing
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          isHighlighted
                              ? const Color(0xFFFF3E6C)
                              : Colors.grey.shade300,
                    ),
                  )
                  : InputBorder.none,
          enabledBorder:
              isEditing
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          isHighlighted
                              ? const Color(0xFFFF3E6C)
                              : Colors.grey.shade300,
                    ),
                  )
                  : InputBorder.none,
          focusedBorder:
              isEditing
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF3E6C),
                      width: 2,
                    ),
                  )
                  : InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
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
