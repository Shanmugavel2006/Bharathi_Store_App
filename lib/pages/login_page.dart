import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_page.dart';
import 'admin_sign_in_page.dart';
import 'user/user_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailMobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final input = _emailMobileController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email/mobile and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String email = "";
      
      if (input.contains('@')) {
        email = input;
      } else {
        // Handle mobile number
        String cleanMobile = input.replaceAll(RegExp(r'[^0-9]'), '');
        
        if (cleanMobile.isEmpty) {
          throw Exception("Invalid mobile number format");
        }

        // Try to find the email associated with this mobile number
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('mobile', isEqualTo: cleanMobile)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          email = userQuery.docs.first.get('email') ?? "$cleanMobile@bharathistore.com";
        } else {
          // Fallback to legacy format
          email = "$cleanMobile@bharathistore.com";
        }
      }
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        // Go to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Invalid mobile number or password.';
      } else if (e.code == 'wrong-password') {
        message = 'The password you entered is incorrect.';
      } else if (e.code == 'invalid-email') {
        message = 'The mobile number format is incorrect.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 60),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EFE9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Color(0xFF094D22),
                              size: 44,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Bharathi Departmental Store',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF094D22),
                            ),
                          ),
                          const SizedBox(height: 48),
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter the details to login',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // Mobile Number Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'MOBILE NUMBER OR EMAIL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _emailMobileController,
                            decoration: const InputDecoration(
                              hintText: 'Enter mobile number or email',
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF374151), size: 20),
                              prefixIconConstraints: BoxConstraints(minWidth: 40),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF094D22), width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          
                          // Password Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                              prefixIcon: Icon(Icons.lock, color: Color(0xFF374151), size: 20),
                              suffixIcon: Icon(Icons.visibility, color: Color(0xFF374151), size: 20),
                              prefixIconConstraints: BoxConstraints(minWidth: 40),
                              suffixIconConstraints: BoxConstraints(minWidth: 40),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF094D22), width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF094D22),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Sign up text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account? ',
                                style: TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignupPage()),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFF094D22),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Bottom admin text
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0, top: 40),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminSignInPage()),
                            );
                          },
                          child: const Text(
                            'ADMIN SIGN-IN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
