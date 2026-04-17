import 'package:flutter/material.dart';

class AdminAddProductPage extends StatelessWidget {
  const AdminAddProductPage({super.key});

  Widget _buildTextField(String label, String hint, {String? prefixText, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFC0C5CF), fontSize: 15),
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: Color(0xFF094D22), fontSize: 15, fontWeight: FontWeight.bold),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF9CA3AF), size: 24) : null,
            filled: true,
            fillColor: const Color(0xFFEEEEEE),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Product',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094D22),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 40),
            
            _buildTextField('Product Name', 'Enter product name...'),
            _buildTextField('Price in Rupees', '0.00', prefixText: '₹ '),
            _buildTextField('Category Selection', 'Choose category', suffixIcon: Icons.keyboard_arrow_down),
            _buildTextField('Image URL', 'https://example.com/image.jpg'),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {},
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
                      'Add Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
