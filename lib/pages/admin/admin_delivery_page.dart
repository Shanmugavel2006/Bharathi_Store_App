import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class AdminDeliveryPage extends StatelessWidget {
  final bool isStandalone;
  const AdminDeliveryPage({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    Widget content = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Register',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF094D22),
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
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('delivery_partners').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No delivery partners registered', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final partner = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF57C00).withOpacity(0.2),
                          child: const Icon(Icons.delivery_dining, color: Color(0xFFF57C00)),
                        ),
                        title: Text(
                          partner['name'] ?? 'Unknown Partner',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          partner['phone'] ?? 'No phone',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (isStandalone) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF094D22)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Delivery Register', 
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF094D22), 
              fontWeight: FontWeight.bold
            )
          ),
        ),
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddPartnerDialog(context, isDark),
          backgroundColor: const Color(0xFFF57C00),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        content,
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _showAddPartnerDialog(context, isDark),
            backgroundColor: const Color(0xFFF57C00),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showAddPartnerDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Add Delivery Partner', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Partner Name',
                labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('delivery_partners').add({
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00)),
            child: const Text('Add Partner', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
