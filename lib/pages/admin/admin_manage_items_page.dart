import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_add_product_page.dart';

class AdminManageItemsPage extends StatefulWidget {
  final bool isStandalone;
  const AdminManageItemsPage({super.key, this.isStandalone = false});

  @override
  State<AdminManageItemsPage> createState() => _AdminManageItemsPageState();
}

class _AdminManageItemsPageState extends State<AdminManageItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleAvailability(String docId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'isAvailable': !currentStatus,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  Future<void> _deleteProduct(String docId) async {
    try {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to remove this product?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance.collection('products').doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product removed successfully')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
      }
    }
  }

  void _showEditDialog(String docId, Map<String, dynamic> product) {
    final titleController = TextEditingController(text: product['title']);
    final priceController = TextEditingController(text: product['price'].toString().replaceAll('₹', ''));
    final categoryController = TextEditingController(text: product['category']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Product Name')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price', prefixText: '₹')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').doc(docId).update({
                'title': titleController.text.trim(),
                'price': '₹${priceController.text.trim()}',
                'category': categoryController.text.trim(),
              });
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF094D22)),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showVariantsStatusDialog(Map<String, dynamic> product) {
    final List variants = product['variants'] ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Variants for ${product['title']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: variants.length,
            itemBuilder: (context, index) {
              final v = variants[index];
              final isVAvailable = v['isAvailable'] != false;
              return ListTile(
                title: Text(v['title']),
                subtitle: Text('₹ ${v['price']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: isVAvailable ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(8)),
                  child: Text(isVAvailable ? 'AVAILABLE' : 'OUT OF STOCK', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inventory Control',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Audit and update your product availability.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search products, categories...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFEBEBEB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    var docs = snapshot.data!.docs;
                    if (_searchQuery.isNotEmpty) {
                      docs = docs.where((doc) => 
                        (doc['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (doc['category'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final product = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        return _buildItemCard(
                          docId: docId,
                          product: product,
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 60), 
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF094D22),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAddProductPage()));
            },
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );

    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF094D22)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Manage Items', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
        ),
        body: content,
      );
    }
    return content;
  }

  Widget _buildItemCard({
    required String docId,
    required Map<String, dynamic> product,
    required int index,
  }) {
    final category = (product['category'] ?? 'General').toString().toUpperCase();
    final sku = product['sku'] ?? '#SKU-${1000 + index}';
    final title = product['title'] ?? 'No Name';
    final price = product['price'] ?? '₹0';
    final isAvailable = product['isAvailable'] ?? true;
    final imageUrl = product['imageUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty 
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey))
                    : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              if (!isAvailable)
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: const Text('OUT OF\nSTOCK', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: isAvailable ? const Color(0xFF558B2F) : const Color(0xFF869287), borderRadius: BorderRadius.circular(12)),
                      child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showEditDialog(docId, product),
                          child: const Icon(Icons.edit, size: 16, color: Color(0xFF094D22)),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _deleteProduct(docId),
                          child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        ),
                        const SizedBox(width: 8),
                        Text(sku, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                        if (product['hasVariants'] == true)
                          GestureDetector(
                            onTap: () => _showVariantsStatusDialog(product),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text('View Variants Status', style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline)),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.75,
                          child: Switch(
                            value: isAvailable,
                            onChanged: (val) => _toggleAvailability(docId, isAvailable),
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF094D22),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFE5E7EB),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAvailable ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
