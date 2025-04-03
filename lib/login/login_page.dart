import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
//simport 'auth_service.dart';
//import 'account_screen.dart';
import 'package:Deals/login/auth_service.dart';
import 'package:Deals/login/account_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      // Reset form when switching modes
      _formKey.currentState?.reset();
    });
    _animationController.reset();
    _animationController.forward();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isLogin && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!isLogin && (value == null || value.isEmpty)) {
      return 'Name is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (!isLogin && (value == null || value.isEmpty)) {
      return 'Phone number is required';
    }
    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> handleAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final AuthService authService = AuthService();

        if (isLogin) {
          User? user = await authService.signIn(
            emailController.text.trim(),
            passwordController.text,
          );

          if (user != null) {
            _showSuccessSnackBar('Login successful!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AccountScreen(user: user),
              ),
            );
          } else {
            _showErrorSnackBar('Login failed. Please check your credentials.');
          }
        } else {
          User? user = await authService.signUp(
            nameController.text.trim(),
            phoneController.text.trim(),
            emailController.text.trim(),
            passwordController.text,
          );

          if (user != null) {
            _showSuccessSnackBar('Account created successfully!');
            setState(() {
              isLogin = true;
            });
          } else {
            _showErrorSnackBar('Failed to create account. Please try again.');
          }
        }
      } catch (e) {
        _showErrorSnackBar('Error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: screenSize.width > 600 ? 500 : screenSize.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Icon(
                          isLogin ? Icons.lock_open : Icons.person_add,
                          size: 80,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isLogin ? "Welcome Back" : "Create Account",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isLogin
                              ? "Sign in to continue"
                              : "Fill the form to get started",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Form Fields
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          constraints: BoxConstraints(
                            maxHeight: isLogin ? 0 : 140,
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: "Full Name",
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: _validateName,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: phoneController,
                                  decoration: InputDecoration(
                                    labelText: "Phone Number",
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: _validatePhone,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: obscurePassword,
                          validator: _validatePassword,
                          textInputAction:
                              isLogin
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                        ),

                        if (isLogin) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password functionality
                              },
                              child: const Text("Forgot Password?"),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleAuth,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                      isLogin ? "LOGIN" : "SIGN UP",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Toggle between Login and Signup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogin
                                  ? "Don't have an account? "
                                  : "Already have an account? ",
                              style: theme.textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: _toggleAuthMode,
                              child: Text(
                                isLogin ? "Sign Up" : "Login",
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Social Login
                        if (isLogin) ...[
                          const SizedBox(height: 30),
                          Text(
                            "Or login with",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialLoginButton(
                                icon: Icons.g_mobiledata,
                                color: Colors.red,
                                onPressed: () {
                                  // TODO: Implement Google sign-in
                                },
                              ),
                              const SizedBox(width: 16),
                              _socialLoginButton(
                                icon: Icons.facebook,
                                color: Colors.blue,
                                onPressed: () {
                                  // TODO: Implement Facebook sign-in
                                },
                              ),
                              const SizedBox(width: 16),
                              _socialLoginButton(
                                icon: Icons.apple,
                                color: Colors.black,
                                onPressed: () {
                                  // TODO: Implement Apple sign-in
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
