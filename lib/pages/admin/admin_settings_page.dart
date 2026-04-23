import 'package:flutter/material.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Store Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
            ),
            const SizedBox(height: 6),
            Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFF81C784), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            
            _buildSettingTile(Icons.storefront_outlined, 'Store Information', 'Edit name, address, and contact'),
            _buildSettingTile(Icons.notifications_none, 'Notification Settings', 'Manage push and email alerts'),
            _buildSettingTile(Icons.payment, 'Payment Methods', 'Enable/disable payment options'),
            _buildSettingTile(Icons.security, 'Security', 'Change password and admin permissions'),
            _buildSettingTile(Icons.help_outline, 'Help & Support', 'Visit help center or contact us'),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
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

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFE5F5E9), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF094D22), size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: () {},
      ),
    );
  }
}
