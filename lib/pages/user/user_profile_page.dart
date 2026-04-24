import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../login_page.dart';

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
            final mobile = userData?['mobile'] ?? 'No mobile';
            final address = userData?['address'] ?? 'No address';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5EFE9).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(userSettings.profileImageUrl),
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
                    const SizedBox(height: 24),
                    
                    // Present Orders
                    _buildSection(
                      'Present Orders',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white, 
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Fresh Spinach, Organic Tomatoes, Alphonso Mangoes (2kg)', 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 13,
                                      color: isDark ? Colors.white : Colors.black
                                    )
                                  )
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '₹850.00', 
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
                              '14 Oct, 10:30 AM', 
                              style: TextStyle(
                                fontSize: 11, 
                                color: isDark ? Colors.grey[500] : const Color(0xFF6B7280)
                              )
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFF094D22), borderRadius: BorderRadius.circular(3)))),
                                Expanded(child: Container(height: 6, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(3)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isDark: isDark,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF86EFAC), borderRadius: BorderRadius.circular(12)),
                        child: const Text('1 ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
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
                      trailing: Text(
                        'Add New', 
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)
                        )
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
}
