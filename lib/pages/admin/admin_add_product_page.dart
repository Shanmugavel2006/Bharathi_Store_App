import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddProductPage extends StatefulWidget {
  const AdminAddProductPage({super.key});

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagController = TextEditingController();
  
  bool _isAvailable = true;
  Color _tagColor = const Color(0xFF1B5E20);
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'title': _nameController.text.trim(),
        'price': '₹ ${_priceController.text.trim()}',
        'category': _categoryController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'isAvailable': _isAvailable,
        'tag': _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
        'tagColorHex': '#${_tagColor.value.toRadixString(16).padLeft(8, '0')}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also ensure category exists in filters
      final catName = _categoryController.text.trim();
      final catQuery = await FirebaseFirestore.instance.collection('filters').where('name', isEqualTo: catName).get();
      if (catQuery.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('filters').add({'name': catName});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully!')));
        _nameController.clear();
        _priceController.clear();
        _categoryController.clear();
        _imageUrlController.clear();
        _tagController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {String? prefixText, IconData? suffixIcon, TextInputType? keyboardType}) {
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
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
        child: Form(
          key: _formKey,
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
              
              _buildTextField('Product Name', 'Enter product name...', _nameController),
              _buildTextField('Price in Rupees', '0.00', _priceController, prefixText: '₹ ', keyboardType: TextInputType.number),
              _buildTextField('Category Selection', 'e.g. Vegetables, Fruits', _categoryController),
              _buildTextField('Image URL', 'https://images.unsplash.com/...', _imageUrlController),
              
              const Text(
                'TAG (OPTIONAL)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'e.g. ORGANIC, BEST',
                  filled: true,
                  fillColor: const Color(0xFFEEEEEE),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Text('Available in Stock:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Switch(
                    value: _isAvailable, 
                    onChanged: (val) => setState(() => _isAvailable = val),
                    activeColor: const Color(0xFF094D22),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094D22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Product',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.add, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
