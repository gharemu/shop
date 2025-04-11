import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:Deals/login/api_service.dart';
import 'package:Deals/services/image_service.dart';
import 'package:Deals/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  // Make email optional
  const UserProfileScreen({Key? key, this.email}) : super(key: key);
  
  final String? email;

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  
  String userName = '';
  String userEmail = '';
  String userId = '';
  String? profileImageUrl;
  
  bool isLoading = true;
  bool isEditing = false;
  bool isUpdating = false;
  String? errorMessage;
  String? successMessage;
  
  File? _profileImage;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        isUploadingImage = true;
      });
      
      try {
        final result = await ImageService.uploadProfileImage(_profileImage!);
        
        if (result['success']) {
          setState(() {
            profileImageUrl = result['imageUrl'];
            successMessage = 'Profile image updated successfully';
          });
          
          // Refresh user data to get updated profile image
          _loadUserData();
        } else {
          setState(() {
            errorMessage = result['message'] ?? 'Failed to upload image';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error uploading image: ${e.toString()}';
        });
      } finally {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = 'Authentication token not found';
          isLoading = false;
        });
        return;
      }
      
      final userData = await ApiService.getUserProfile(token);
      
      if (userData['success'] == true) {
        setState(() {
          userName = userData['user']['name'] ?? 'User';
          userEmail = userData['user']['email'] ?? widget.email ?? '';
          userId = userData['user']['id']?.toString() ?? '';
          profileImageUrl = userData['user']['profile_image'];
          
          nameController.text = userName;
          emailController.text = userEmail;
        });
      } else {
        setState(() {
          errorMessage = userData['message'] ?? 'Failed to load user data';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> _updateProfile() async {
    setState(() {
      isUpdating = true;
      errorMessage = null;
      successMessage = null;
    });
    
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = 'Authentication token not found';
          isUpdating = false;
        });
        return;
      }
      
      final Map<String, dynamic> userData = {
        'name': nameController.text,
      };
      
      // Only include password fields if the user is trying to change password
      if (currentPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
        userData['currentPassword'] = currentPasswordController.text;
        userData['newPassword'] = newPasswordController.text;
      }
      
      final result = await ApiService.updateUserProfile(userData, token);
      
      if (result['success']) {
        setState(() {
          successMessage = result['message'] ?? 'Profile updated successfully';
          // Clear password fields
          currentPasswordController.clear();
          newPasswordController.clear();
          // Exit edit mode
          isEditing = false;
        });
        
        // Reload user data to reflect changes
        await _loadUserData();
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) {
                  // Reset form if canceling edit
                  nameController.text = userName;
                  emailController.text = userEmail;
                  currentPasswordController.clear();
                  newPasswordController.clear();
                  errorMessage = null;
                  successMessage = null;
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  if (successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        successMessage!,
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: profileImageUrl != null 
                            ? NetworkImage('${ApiService.baseUrl}$profileImageUrl')
                            : null,
                        child: profileImageUrl == null
                            ? Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: _pickAndUploadImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  if (!isEditing) ...[
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Name'),
                      subtitle: Text(userName),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(userEmail),
                    ),
                  ] else ...[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: emailController,
                      enabled: false, // Email cannot be changed
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Change Password (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: isUpdating ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: isUpdating
                          ? const CircularProgressIndicator()
                          : const Text('Save Changes'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}