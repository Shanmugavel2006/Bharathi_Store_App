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

  void _navigateToEdit(String docId, Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAddProductPage(product: product, productId: docId),
      ),
    );
  }

  void _showVariantsStatusDialog(String docId, Map<String, dynamic> product) {
    List variants = List.from(product['variants'] ?? []);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Variants for ${product['title']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: variants.length,
                itemBuilder: (context, index) {
                  final v = variants[index];
                  final isVAvailable = v['isAvailable'] != false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('₹ ${v['price']}', style: const TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                              onPressed: () => _showEditVariantDialog(docId, product, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              onPressed: () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Variant'),
                                    content: Text('Remove "${v['title']}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  List updatedVariants = List.from(variants);
                                  updatedVariants.removeAt(index);
                                  await FirebaseFirestore.instance.collection('products').doc(docId).update({
                                    'variants': updatedVariants,
                                    'hasVariants': updatedVariants.isNotEmpty,
                                  });
                                  if (mounted) Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isVAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isVAvailable ? Colors.green : Colors.red),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isVAvailable,
                                onChanged: (val) async {
                                  setModalState(() {
                                    variants[index]['isAvailable'] = val;
                                  });
                                  await FirebaseFirestore.instance.collection('products').doc(docId).update({
                                    'variants': variants,
                                  });
                                },
                                activeColor: const Color(0xFF094D22),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          );
        },
      ),
    );
  }

  void _showEditVariantDialog(String docId, Map<String, dynamic> product, int variantIndex) {
    List variants = List.from(product['variants'] ?? []);
    Map<String, dynamic> variant = Map<String, dynamic>.from(variants[variantIndex]);
    
    final titleController = TextEditingController(text: variant['title']);
    final priceController = TextEditingController(text: variant['price'].toString());
    final unitValueController = TextEditingController(text: variant['unitValue']?.toString() ?? '');
    String selectedUnit = variant['unitType'] ?? 'g';
    final imageUrlController = TextEditingController(text: variant['imageUrl'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Variant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Variant Title')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: unitValueController, decoration: const InputDecoration(labelText: 'Unit Value'), keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: selectedUnit,
                isExpanded: true,
                items: ['g', 'kg', 'ml', 'l'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) => selectedUnit = val!,
              ),
              TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              variant['title'] = titleController.text.trim();
              variant['price'] = priceController.text.trim();
              variant['unitValue'] = unitValueController.text.trim();
              variant['unitType'] = selectedUnit;
              variant['imageUrl'] = imageUrlController.text.trim();
              
              variants[variantIndex] = variant;
              await FirebaseFirestore.instance.collection('products').doc(docId).update({
                'variants': variants,
              });
              if (mounted) {
                Navigator.pop(context); // Close edit dialog
                Navigator.pop(context); // Close status dialog to refresh
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Variant updated')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF094D22)),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Categories'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('filters').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final filter = docs[index];
                  return ListTile(
                    title: Text(filter['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Category'),
                            content: Text('Remove "${filter['name']}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await FirebaseFirestore.instance.collection('filters').doc(filter.id).delete();
                        }
                      },
                    ),
                  );
                },
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
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showFiltersDialog,
                    icon: const Icon(Icons.category, color: Color(0xFF094D22)),
                    tooltip: 'Manage Categories',
                  ),
                ],
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

                    var docs = snapshot.data!.docs.toList();
                    
                    // Sort alphabetically by title
                    docs.sort((a, b) => (a['title'] as String? ?? '').toLowerCase().compareTo((b['title'] as String? ?? '').toLowerCase()));

                    if (_searchQuery.isNotEmpty) {
                      docs = docs.where((doc) => 
                        (doc['title'] as String? ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (doc['category'] as String? ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
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
            ],
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminAddProductPage()),
            );
          },
          backgroundColor: const Color(0xFF094D22),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
    return Scaffold(
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminAddProductPage()),
          );
        },
        backgroundColor: const Color(0xFF094D22),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
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
                          onTap: () => _navigateToEdit(docId, product),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                          if (product['hasVariants'] == true)
                            GestureDetector(
                              onTap: () => _showVariantsStatusDialog(docId, product),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text('View Variants Status', style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline)),
                              ),
                            ),
                        ],
                      ),
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
