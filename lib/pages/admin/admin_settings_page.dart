import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_settings_provider.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userSettings = Provider.of<UserSettingsProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Settings',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : const Color(0xFF094D22)
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 48, 
              height: 4, 
              decoration: BoxDecoration(
                color: const Color(0xFF81C784), 
                borderRadius: BorderRadius.circular(2)
              )
            ),
            const SizedBox(height: 32),
            
            // Profile & Avatar Section
            Text(
              'Profile Customization',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.grey[300] : Colors.grey[800]
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(userSettings.profileImageUrl),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Default Avatar', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userSettings.defaultAvatars.length,
                      itemBuilder: (context, index) {
                        final isSelected = userSettings.selectedAvatarIndex == index;
                        return GestureDetector(
                          onTap: () => userSettings.setAvatarIndex(index),
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
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Appearance
            Text(
              'App Appearance',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.grey[300] : Colors.grey[800]
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.withOpacity(0.1) : const Color(0xFFE3F2FD), 
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode, 
                    color: isDark ? Colors.blue : Colors.blue[800], 
                    size: 22
                  ),
                ),
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                  activeColor: const Color(0xFF094D22),
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            _buildSettingTile(Icons.storefront_outlined, 'Store Information', 'Edit name, address, and contact', isDark),
            _buildSettingTile(Icons.notifications_none, 'Notification Settings', 'Manage push and email alerts', isDark),
            _buildSettingTile(Icons.payment, 'Payment Methods', 'Enable/disable payment options', isDark),
            _buildSettingTile(Icons.security, 'Security', 'Change password and admin permissions', isDark),
            _buildSettingTile(Icons.help_outline, 'Help & Support', 'Visit help center or contact us', isDark),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout from Admin', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2E7D32).withOpacity(0.1) : const Color(0xFFE5F5E9), 
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(icon, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22), size: 22),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black
          )
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(
            fontSize: 12, 
            color: isDark ? Colors.grey[500] : Colors.grey
          )
        ),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey, size: 20),
        onTap: () {},
      ),
    );
  }
}
