import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Standardize mobile number to only digits
      String cleanMobile = _mobileController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      
      if (cleanMobile.isEmpty) {
        throw Exception("Please enter a valid mobile number");
      }

      if (email.isEmpty || !email.contains('@')) {
        throw Exception("Please enter a valid email address");
      }

      // Check for duplicate mobile number in Firestore
      final mobileQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('mobile', isEqualTo: cleanMobile)
          .get();
      
      if (mobileQuery.docs.isNotEmpty) {
        throw Exception("This mobile number is already registered.");
      }

      // Check for duplicate email in Firestore
      final emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (emailQuery.docs.isNotEmpty) {
        throw Exception("This email address is already registered.");
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Add user details to firestore database
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'email': email,
        'mobile': cleanMobile,
        'address': _addressController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully! Please login."),
            backgroundColor: Color(0xFF094D22),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "An error occurred during sign up";
      
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        // Special case: Auth account exists but Firestore doc is missing (Deleted Account)
        final doc = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: _emailController.text.trim()).get();
        if (doc.docs.isEmpty) {
          message = 'This account was previously deleted. Please contact support to reactivate or use a different email.';
        } else {
          message = 'This email address is already registered.';
        }
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/Password sign-in is not enabled in Firebase Console.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isDark, {bool isPassword = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (isPassword && value.length < 6) {
               return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[700] : const Color(0xFFC0C5CF), fontSize: 15),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bharathi',
          style: TextStyle(
            color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF81C784),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildTextField('Name', 'Enter your full name', _nameController, isDark),
                  _buildTextField('Email ID', 'example@gmail.com', _emailController, isDark, keyboardType: TextInputType.emailAddress),
                  _buildTextField('Mobile Number', '+91 00000 00000', _mobileController, isDark, keyboardType: TextInputType.phone),
                  _buildTextField('Address', 'Street, Apartment, City', _addressController, isDark),
                  _buildTextField('Password', '........', _passwordController, isDark, isPassword: true),
                  _buildTextField('Confirm Password', '........', _confirmPasswordController, isDark, isPassword: true),
                  
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF094D22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF4B5563), fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
