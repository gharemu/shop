import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _profileImageUrl;
  bool _isDarkMode = false;
  bool _isLoading = false;
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  bool _isVerifyingEmail = false;
  bool _isVerifyingPhone = false;
  String? _verificationId;
  Timer? _emailVerificationTimer;
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameController.text = widget.user.displayName ?? '';
    emailController.text = widget.user.email ?? '';
    phoneController.text = widget.user.phoneNumber ?? '';
    _profileImageUrl = widget.user.photoURL;
    _isEmailVerified = widget.user.emailVerified;
    _isPhoneVerified = widget.user.phoneNumber != null;
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isVerifyingEmail = true;
      _isLoading = true;
    });

    try {
      // Send verification email
      await widget.user.sendEmailVerification();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Please check your inbox'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Start timer to check if email is verified
      _emailVerificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        await widget.user.reload();
        User? refreshedUser = FirebaseAuth.instance.currentUser;
        
        if (refreshedUser != null && refreshedUser.emailVerified) {
          setState(() {
            _isEmailVerified = true;
            _isVerifyingEmail = false;
          });
          _emailVerificationTimer?.cancel();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPhone() async {
    setState(() {
      _isVerifyingPhone = true;
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await widget.user.updatePhoneNumber(credential);
          setState(() {
            _isPhoneVerified = true;
            _isVerifyingPhone = false;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number verified automatically!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone verification failed: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent to your phone number!'),
              backgroundColor: Colors.blue,
            ),
          );
          
          // Show OTP dialog
          _showOtpDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during phone verification: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null || otpController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create credential with the OTP provided by user
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text,
      );
      
      // Update user's phone number with the verified credential
      await widget.user.updatePhoneNumber(credential);
      
      setState(() {
        _isPhoneVerified = true;
        _isVerifyingPhone = false;
      });
      
      Navigator.of(context).pop(); // Close OTP dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the verification code sent to your phone'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isVerifyingPhone = false;
              });
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: _verifyOtp,
            child: const Text('VERIFY'),
          ),
        ],
      ),
    );
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user name
      await widget.user.updateDisplayName(nameController.text);
      
      // Update email if changed and not verified yet
      if (!_isEmailVerified && emailController.text != widget.user.email) {
        await widget.user.updateEmail(emailController.text);
        setState(() {
          _isEmailVerified = false;
        });
        
        // Send verification email for the new email
        await widget.user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent to your new email address!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reload user and go back
      await widget.user.reload();
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Apply theme based on dark mode setting
    final ThemeData theme = _isDarkMode 
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.teal,
            colorScheme: const ColorScheme.dark().copyWith(primary: Colors.tealAccent),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light().copyWith(primary: Colors.blue),
          );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile"),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle theme',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile picture
                          GestureDetector(
                            onTap: () {
                              // Implement image picker functionality here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Photo upload feature coming soon!')),
                              );
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _profileImageUrl != null
                                      ? NetworkImage(_profileImageUrl!)
                                      : null,
                                  child: _profileImageUrl == null
                                      ? const Icon(Icons.person, size: 60)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Name field
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Email field with verification
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    prefixIcon: const Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.brightness == Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    suffixIcon: _isEmailVerified
                                        ? const Icon(Icons.verified, color: Colors.green)
                                        : const Icon(Icons.error_outline, color: Colors.orange),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  enabled: !_isEmailVerified,
                                ),
                              ),
                              if (!_isEmailVerified) ...[
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _isVerifyingEmail ? null : _verifyEmail,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(_isVerifyingEmail ? "SENDING..." : "VERIFY"),
                                ),
                              ],
                            ],
                          ),
                          if (!_isEmailVerified)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0, left: 12.0),
                              child: Text(
                                "Email needs verification",
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          const SizedBox(height: 16),
                          
                          // Phone field with verification
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Phone Number",
                                    hintText: "+1234567890",
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.brightness == Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    suffixIcon: _isPhoneVerified
                                        ? const Icon(Icons.verified, color: Colors.green)
                                        : const Icon(Icons.error_outline, color: Colors.orange),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (!RegExp(r'^\+?[0-9]{10,14}$').hasMatch(value)) {
                                      return 'Please enter a valid phone number';
                                    }
                                    return null;
                                  },
                                  enabled: !_isPhoneVerified,
                                ),
                              ),
                              if (!_isPhoneVerified) ...[
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _isVerifyingPhone ? null : _verifyPhone,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(_isVerifyingPhone ? "SENDING..." : "VERIFY"),
                                ),
                              ],
                            ],
                          ),
                          if (!_isPhoneVerified)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0, left: 12.0),
                              child: Text(
                                "Phone number needs verification",
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          const SizedBox(height: 32),
                          
                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: saveChanges,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "SAVE CHANGES",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Cancel button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "CANCEL",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    otpController.dispose();
    _emailVerificationTimer?.cancel();
    super.dispose();
  }
}