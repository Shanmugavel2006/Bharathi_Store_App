import 'package:flutter/material.dart';
import 'admin/admin_home_page.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AdminSignInPage extends StatelessWidget {
  const AdminSignInPage({super.key});

  Widget _buildTextField(String label, String hint, bool isDark, {bool isPassword = false, TextInputType? keyboardType, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? Colors.grey[400] : const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[700] : const Color(0xFFC0C5CF), fontSize: 15),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF), size: 20) : null,
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
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF98F598), // Light green
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.park, // Matches tree icon
                  color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bharathi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DEPARTMENTAL STORE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: isDark ? Colors.grey[500] : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 40),
              
              // Form Card
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Sign In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
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
                      isDark,
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: Icons.alternate_email,
                    ),
                    
                    _buildTextField(
                      'Password', 
                      '........', 
                      isDark,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help, color: isDark ? Colors.grey[500] : const Color(0xFF4B5563), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Need assistance? Contact support',
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : const Color(0xFF4B5563),
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
