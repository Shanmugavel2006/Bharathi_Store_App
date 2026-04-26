import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../login_page.dart';
import 'user_orders_page.dart';
import 'user_address_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userSettings = Provider.of<UserSettingsProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF094D22)),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Profile', 
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF094D22), 
              fontWeight: FontWeight.bold, 
              fontSize: 18
            )
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: isDark ? Colors.white : const Color(0xFF094D22)), 
              onPressed: () {
                _showSettingsSheet(context, themeProvider, userSettings, isDark);
              }
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final name = userData?['name'] ?? 'User';
            final email = userData?['email'] ?? user?.email ?? 'No email';
            final mobile = userData?['phone'] ?? userData?['mobile'] ?? 'No phone';
            final address = userData?['address'] ?? 'No address';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile Header
                    GestureDetector(
                      onTap: () => _showUserDetailsDialog(context, name, email, mobile, address, isDark),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5EFE9).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(userSettings.profileImageUrl),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Color(0xFF094D22), shape: BoxShape.circle),
                                    child: const Icon(Icons.info_outline, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name, 
                              style: TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold, 
                                color: isDark ? Colors.white : const Color(0xFF1E1E1E)
                              )
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Colors.white, 
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.email, size: 14, color: isDark ? Colors.grey[400] : const Color(0xFF4B5563)),
                                  const SizedBox(width: 8),
                                  Text(
                                    email, 
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: isDark ? Colors.grey[400] : const Color(0xFF4B5563)
                                    )
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Colors.white, 
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone, size: 14, color: isDark ? Colors.grey[400] : const Color(0xFF4B5563)),
                                  const SizedBox(width: 8),
                                  Text(
                                    mobile, 
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: isDark ? Colors.grey[400] : const Color(0xFF4B5563)
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Order Status Tracking
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .where('userId', isEqualTo: user?.uid)
                          .orderBy('createdAt', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final orderDoc = (snapshot.hasData && snapshot.data!.docs.isNotEmpty) ? snapshot.data!.docs.first : null;
                        final orderData = orderDoc?.data() as Map<String, dynamic>?;
                        final status = (orderData?['status'] ?? '').toString().toUpperCase();
                        
                        bool isOrdered = status != 'CANCELLED' && status != '';
                        bool isDelivered = status == 'DELIVERED' || status == 'COMPLETED';

                        return _buildSection(
                          'Order Status',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.white, 
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: Column(
                              children: [
                                _buildStatusRow('Ordered', isOrdered, isDark),
                                const SizedBox(height: 16),
                                Container(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                                const SizedBox(height: 16),
                                _buildStatusRow('Delivered', isDelivered, isDark),
                              ],
                            ),
                          ),
                          isDark: isDark,
                          trailing: orderDoc != null 
                            ? Text(
                                '#${orderDoc.id.substring(0, 8)}', 
                                style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[400])
                              )
                            : null,
                        );
                      }
                    ),
                    const SizedBox(height: 24),

                    // Present Orders
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .where('userId', isEqualTo: user?.uid)
                          .orderBy('createdAt', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final orderDoc = (snapshot.hasData && snapshot.data!.docs.isNotEmpty) ? snapshot.data!.docs.first : null;
                        final orderData = orderDoc?.data() as Map<String, dynamic>?;
                        final status = (orderData?['status'] ?? '').toString().toUpperCase();
                        final total = orderData?['totalAmount'] ?? '₹0';
                        final createdAt = (orderData?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final date = DateFormat('dd MMM, hh:mm a').format(createdAt);
                        
                        return _buildSection(
                          'Present Orders',
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserOrdersPage()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Colors.white, 
                                borderRadius: BorderRadius.circular(16)
                              ),
                              child: orderDoc == null 
                                ? Center(child: Text('No active orders', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey)))
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Order #${orderDoc.id.substring(0, 8)}', 
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold, 
                                                fontSize: 13,
                                                color: isDark ? Colors.white : Colors.black
                                              )
                                            )
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            total, 
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold, 
                                              fontSize: 14, 
                                              color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)
                                            )
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        date, 
                                        style: TextStyle(
                                          fontSize: 11, 
                                          color: isDark ? Colors.grey[500] : const Color(0xFF6B7280)
                                        )
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(3)))),
                                          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(3)))),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        status.toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                          isDark: isDark,
                          trailing: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserOrdersPage())),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF86EFAC), borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                orderDoc != null ? 'VIEW ALL' : '0 ACTIVE', 
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF094D22))
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 24),
                    
                    // Past History
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .where('userId', isEqualTo: user?.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        
                        final allOrders = snapshot.data!.docs;
                        final pastOrders = allOrders.where((doc) {
                          final status = doc['status'].toString().toUpperCase();
                          return status == 'DELIVERED' || status == 'COMPLETED';
                        }).take(3).toList();

                        if (pastOrders.isEmpty) return const SizedBox();

                        return Column(
                          children: [
                            _buildSection(
                              'Past History',
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pastOrders.length,
                                separatorBuilder: (c, i) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final order = pastOrders[index].data() as Map<String, dynamic>;
                                  final orderId = pastOrders[index].id;
                                  final total = order['totalAmount'] ?? '₹0';
                                  final createdAt = (order['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                                  final date = DateFormat('dd MMM, yyyy').format(createdAt);
                                  
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.grey[900] : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF094D22).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.history, color: Color(0xFF094D22), size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Order #${orderId.substring(0, 8)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black)),
                                              Text(date, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                        Text(total, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              isDark: isDark,
                              trailing: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserOrdersPage())),
                                child: Text('VIEW ALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // Saved Addresses
                    _buildSection(
                      'Saved Addresses',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white, 
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.home, color: Color(0xFF094D22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Home', 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 14,
                                      color: isDark ? Colors.white : Colors.black
                                    )
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    address, 
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: isDark ? Colors.grey[500] : const Color(0xFF6B7280), 
                                      height: 1.5
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      isDark: isDark,
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAddressPage(isEditing: true)));
                        },
                        child: Text(
                          'Edit / Add', 
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.bold, 
                            color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)
                          )
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Logout Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6), 
                        borderRadius: BorderRadius.circular(24)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _logout,
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: isDark ? Colors.red[300] : const Color(0xFFD32F2F)),
                                const SizedBox(width: 16),
                                Text(
                                  'Logout', 
                                  style: TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.bold, 
                                    color: isDark ? Colors.red[300] : const Color(0xFFD32F2F)
                                  )
                                ),
                              ],
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

  Widget _buildStatusRow(String label, bool isTicked, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isTicked ? const Color(0xFF094D22) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isTicked ? const Color(0xFF094D22) : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              width: 2,
            ),
          ),
          child: isTicked 
            ? const Icon(Icons.check, size: 16, color: Colors.white) 
            : null,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'IN PREPARATION': return const Color(0xFF094D22);
      case 'CONFIRMED': return Colors.blue;
      case 'DELIVERED': return const Color(0xFF094D22);
      case 'COMPLETED': return Colors.grey;
      case 'CANCELLED': return Colors.red;
      default: return const Color(0xFF094D22);
    }
  }

  Widget _buildSection(String title, {required Widget child, required bool isDark, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6), 
        borderRadius: BorderRadius.circular(24)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E)
                )
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, ThemeProvider themeProvider, UserSettingsProvider userSettings, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings', 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black
                    )
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                          setModalState(() {});
                        },
                        activeColor: const Color(0xFF094D22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Avatar', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userSettings.defaultAvatars.length,
                      itemBuilder: (context, index) {
                        final isSelected = userSettings.selectedAvatarIndex == index;
                        return GestureDetector(
                          onTap: () {
                            userSettings.setAvatarIndex(index);
                            setModalState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF094D22) : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(userSettings.defaultAvatars[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
        );
      },
    );
  }
  void _showUserDetailsDialog(BuildContext context, String name, String email, String mobile, String address, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('User Details', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Name', name, Icons.person, isDark),
            const SizedBox(height: 16),
            _buildDetailItem('Email', email, Icons.email, isDark),
            const SizedBox(height: 16),
            _buildDetailItem('Mobile', mobile, Icons.phone, isDark),
            const SizedBox(height: 16),
            _buildDetailItem('Address', address, Icons.home, isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAddressPage(isEditing: true)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF094D22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit Info', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF094D22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600])),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            ],
          ),
        ),
      ],
    );
  }
}
