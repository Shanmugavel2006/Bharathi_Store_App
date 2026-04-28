import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String? productId;

  const AdminAddProductPage({super.key, this.product, this.productId});

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
  final _unitValueController = TextEditingController();
  String _selectedUnit = 'g';
  
  bool _isAvailable = true;
  Color _tagColor = const Color(0xFF1B5E20);
  bool _isLoading = false;
  List<Map<String, dynamic>> _variants = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['title'] ?? '';
      _priceController.text = (widget.product!['price'] ?? '').toString().replaceAll('₹', '').trim();
      _categoryController.text = widget.product!['category'] ?? '';
      _imageUrlController.text = widget.product!['imageUrl'] ?? '';
      _tagController.text = widget.product!['tag'] ?? '';
      _unitValueController.text = widget.product!['unitValue']?.toString() ?? '';
      _selectedUnit = widget.product!['unitType'] ?? 'g';
      _isAvailable = widget.product!['isAvailable'] ?? true;
      _variants = List<Map<String, dynamic>>.from(widget.product!['variants'] ?? []);
      
      if (widget.product!['tagColorHex'] != null) {
        try {
          String hex = widget.product!['tagColorHex'].replaceAll('#', '');
          if (hex.length == 6) hex = 'FF$hex';
          _tagColor = Color(int.parse(hex, radix: 16));
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _tagController.dispose();
    _unitValueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productData = {
        'title': _nameController.text.trim(),
        'price': '₹ ${_priceController.text.trim()}',
        'category': _categoryController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'isAvailable': _isAvailable,
        'tag': _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
        'tagColorHex': '#${_tagColor.value.toRadixString(16).padLeft(8, '0')}',
        'unitValue': _unitValueController.text.trim(),
        'unitType': _selectedUnit,
        'variants': _variants,
        'hasVariants': _variants.isNotEmpty,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.productId != null) {
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(productData);
      } else {
        productData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('products').add(productData);
      }

      // Also ensure category exists in filters
      final catName = _categoryController.text.trim();
      final catQuery = await FirebaseFirestore.instance.collection('filters').where('name', isEqualTo: catName).get();
      if (catQuery.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('filters').add({'name': catName});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.productId != null ? 'Product updated successfully!' : 'Product added successfully!'))
        );
        
        if (widget.productId != null) {
          Navigator.pop(context);
        } else {
          _nameController.clear();
          _priceController.clear();
          _categoryController.clear();
          _imageUrlController.clear();
          _tagController.clear();
          _unitValueController.clear();
          setState(() {
            _variants = [];
            _selectedUnit = 'g';
          });
        }
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
    final body = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productId != null ? 'Edit Product' : 'Add New Product',
                style: const TextStyle(
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
                'UNIT / WEIGHT (OPTIONAL)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _unitValueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 500, 1',
                        filled: true,
                        fillColor: const Color(0xFFEEEEEE),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(4)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          isExpanded: true,
                          items: ['g', 'kg', 'ml', 'l'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
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
              
              const Text(
                'PRODUCT VARIANTS (OPTIONAL)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 12),
              
              if (_variants.isNotEmpty)
                Column(
                  children: _variants.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var v = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (v['imageUrl'] != null && v['imageUrl'].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(v['imageUrl'], width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image)),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('₹ ${v['price']} ${v['unitValue'] ?? ''} ${v['unitType'] ?? ''}', style: const TextStyle(fontSize: 12, color: Color(0xFF094D22))),
                                Text(
                                  v['isAvailable'] == false ? 'UNAVAILABLE' : 'AVAILABLE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: v['isAvailable'] == false ? Colors.red : Colors.green),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => setState(() => _variants.removeAt(idx)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddVariantDialog,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Multiple Options / Variants'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF094D22),
                    side: const BorderSide(color: Color(0xFF094D22)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094D22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.productId != null ? 'Update Product' : 'Add Product',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Icon(widget.productId != null ? Icons.save : Icons.add, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.productId != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFF094D22),
        ),
        body: body,
      );
    }
    return body;
  }

  void _showAddVariantDialog() {
    final vTitleController = TextEditingController();
    final vPriceController = TextEditingController();
    final vImageUrlController = TextEditingController();
    final vUnitValueController = TextEditingController();
    String vSelectedUnit = 'g';
    bool vIsAvailable = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product Variant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: vTitleController, decoration: const InputDecoration(labelText: 'Variant Name (e.g. Red, 500g)')),
              TextField(controller: vPriceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: vImageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
              const SizedBox(height: 16),
              const Text('Unit / Weight (Optional)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setDialogState) => Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: vUnitValueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 500, 1', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: vSelectedUnit,
                            isExpanded: true,
                            items: ['g', 'kg', 'ml', 'l'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (val) => setDialogState(() => vSelectedUnit = val!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) => Row(
                  children: [
                    const Text('Available in Stock:', style: TextStyle(fontSize: 14)),
                    const Spacer(),
                    Switch(
                      value: vIsAvailable,
                      onChanged: (val) => setDialogState(() => vIsAvailable = val),
                      activeColor: const Color(0xFF094D22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (vTitleController.text.isNotEmpty && vPriceController.text.isNotEmpty) {
                setState(() {
                  _variants.add({
                    'title': vTitleController.text.trim(),
                    'price': vPriceController.text.trim(),
                    'imageUrl': vImageUrlController.text.trim(),
                    'unitValue': vUnitValueController.text.trim(),
                    'unitType': vSelectedUnit,
                    'isAvailable': vIsAvailable,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF094D22)),
            child: const Text('Add Option', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
