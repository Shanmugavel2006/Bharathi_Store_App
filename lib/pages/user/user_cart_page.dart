import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'user_checkout_page.dart';

class UserCartPage extends StatefulWidget {
  const UserCartPage({super.key});

  @override
  State<UserCartPage> createState() => _UserCartPageState();
}

class _UserCartPageState extends State<UserCartPage> {
  final user = FirebaseAuth.instance.currentUser;

  double _parsePrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            'Please login to view cart',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          )
        )
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Bharathi Store',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 80, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty', 
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey, fontSize: 16)
                    ),
                  ],
                ),
              );
            }

            final cartItems = snapshot.data!.docs;
            double subtotal = 0;
            for (var item in cartItems) {
              final data = item.data() as Map<String, dynamic>;
              subtotal += _parsePrice(data['price'] ?? '0') * (data['quantity'] ?? 1);
            }
            double deliveryFee = subtotal > 500 ? 0 : 40;
            double total = subtotal + deliveryFee;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR SELECTION',
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.2, 
                        color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shopping Cart',
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white : const Color(0xFF094D22)
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final data = cartItems[index].data() as Map<String, dynamic>;
                        final docId = cartItems[index].id;
                        return _buildCartItem(
                          docId: docId,
                          imageUrl: data['imageUrl'] ?? '',
                          title: data['title'] ?? 'No Name',
                          subtitle: data['tag'] ?? 'General',
                          price: data['price'] ?? '₹0',
                          quantity: data['quantity'] ?? 1,
                          isDark: isDark,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary', 
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E)
                            )
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal', 
                                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF4B5563), fontSize: 13)
                              ),
                              Text(
                                '₹${subtotal.toStringAsFixed(2)}', 
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1E1E1E), 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delivery Fee', 
                                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF4B5563), fontSize: 13)
                              ),
                              Text(
                                deliveryFee == 0 ? 'Free' : '₹${deliveryFee.toStringAsFixed(2)}', 
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1E1E1E), 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total', 
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22), 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              Text(
                                '₹${total.toStringAsFixed(2)}', 
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22), 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserCheckoutPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF094D22),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Proceed to Checkout', 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String docId,
    required String imageUrl,
    required String title,
    required String subtitle,
    required String price,
    required int quantity,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: isDark ? Colors.grey[900] : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14, 
                          color: isDark ? Colors.white : const Color(0xFF1E1E1E)
                        )
                      )
                    ),
                    Text(
                      price, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14, 
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E)
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : const Color(0xFF6B7280))
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF094D22).withOpacity(0.3) : const Color(0xFF98F598), 
                        borderRadius: BorderRadius.circular(8)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (quantity > 1) {
                                FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').doc(docId).update({'quantity': quantity - 1});
                              }
                            },
                            child: Icon(Icons.remove, size: 14, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$quantity', 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 13, 
                              color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)
                            )
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').doc(docId).update({'quantity': quantity + 1});
                            },
                            child: Icon(Icons.add, size: 14, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: isDark ? Colors.grey[600] : const Color(0xFF4B5563), size: 20),
                      onPressed: () => FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').doc(docId).delete(),
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
