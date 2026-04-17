import 'package:flutter/material.dart';
import 'admin/admin_home_page.dart';

class AdminSignInPage extends StatelessWidget {
  const AdminSignInPage({super.key});

  Widget _buildTextField(String label, String hint, {bool isPassword = false, TextInputType? keyboardType, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFC0C5CF), fontSize: 15),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF9CA3AF), size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF094D22)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF98F598), // Light green
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.park, // Matches tree icon
                  color: Color(0xFF094D22),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bharathi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF094D22),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'DEPARTMENTAL STORE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 40),
              
              // Form Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Sign In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildTextField(
                      'Email', 
                      'admin@bharathistore.com', 
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: Icons.alternate_email,
                    ),
                    
                    _buildTextField(
                      'Password', 
                      '........', 
                      isPassword: true,
                      suffixIcon: Icons.lock_outline,
                    ),
                    
                    const SizedBox(height: 8),
                    
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminHomePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF094D22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Admin Sign In',
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
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Bottom Help Text
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help, color: Color(0xFF4B5563), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Need assistance? Contact support',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
