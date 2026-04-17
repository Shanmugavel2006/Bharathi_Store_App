import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'admin_sign_in_page.dart';
import 'user/user_home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                              'MOBILE NUMBER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your mobile number',
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                              prefixIcon: Icon(Icons.phone, color: Color(0xFF374151), size: 20),
                              prefixIconConstraints: BoxConstraints(minWidth: 40),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF094D22), width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            keyboardType: TextInputType.phone,
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
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UserHomePage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF094D22),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
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
