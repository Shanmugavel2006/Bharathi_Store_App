import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatefulWidget {
  final bool isStandalone;
  const AdminUsersPage({super.key, this.isStandalone = false});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  Future<void> _toggleUserStatus(String userId, String userName, bool currentStatus) async {
    String action = currentStatus ? 'Deactivate' : 'Reactivate';
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action User'),
        content: Text('Are you sure you want to $action "$userName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: currentStatus ? Colors.red : const Color(0xFF094D22)),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isActive': !currentStatus,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User "$userName" ${currentStatus ? 'deactivated' : 'reactivated'}')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF094D22)),
            const SizedBox(width: 10),
            const Text('User Details', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.person_outline, 'Name', user['name'] ?? 'N/A'),
            _detailRow(Icons.email_outlined, 'Email', user['email'] ?? 'N/A'),
            _detailRow(Icons.phone_outlined, 'Mobile', user['mobile'] ?? 'N/A'),
            _detailRow(Icons.location_on_outlined, 'Address', user['address'] ?? 'N/A'),
            _detailRow(Icons.admin_panel_settings_outlined, 'Role', (user['role'] as String?)?.toUpperCase() ?? 'USER'),
            if (user['createdAt'] != null)
              _detailRow(Icons.calendar_today_outlined, 'Joined', (user['createdAt'] as Timestamp).toDate().toString().split(' ')[0]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registered Users',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF094D22),
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
              // Notice: We don't order by createdAt here if it might be missing in some docs, 
              // or we handle the empty state gracefully.
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No users registered yet.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final users = snapshot.data!.docs;
                
                // Manual sort in memory if needed or just display
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    final bool isActive = userData['isActive'] ?? true;
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isActive ? Colors.grey.shade200 : Colors.red.shade100),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isActive ? const Color(0xFFE5F5E9) : Colors.red.shade50,
                                  child: Text(
                                    (userData['name'] as String?)?.isNotEmpty == true 
                                        ? userData['name'][0].toUpperCase() 
                                        : 'U',
                                    style: TextStyle(
                                      color: isActive ? const Color(0xFF094D22) : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            userData['name'] ?? 'Unknown User',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isActive ? const Color(0xFF1E1E1E) : Colors.red,
                                            ),
                                          ),
                                          if (!isActive) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                              child: const Text('DEACTIVATED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userData['mobile'] ?? 'No Mobile Number',
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFF9FAFB) : Colors.red.shade50.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      userData['address'] ?? 'No address provided',
                                      style: const TextStyle(
                                        color: Color(0xFF4B5563),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _toggleUserStatus(users[index].id, userData['name'] ?? 'Unknown User', isActive),
                                  icon: Icon(
                                    isActive ? Icons.block : Icons.check_circle_outline, 
                                    color: isActive ? Colors.red : const Color(0xFF094D22), 
                                    size: 18
                                  ),
                                  label: Text(
                                    isActive ? 'Deactivate' : 'Reactivate',
                                    style: TextStyle(
                                      color: isActive ? Colors.red : const Color(0xFF094D22),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _showUserDetails(userData),
                                  icon: const Icon(Icons.info_outline, size: 18, color: Color(0xFF094D22)),
                                  label: const Text(
                                    'Details',
                                    style: TextStyle(
                                      color: Color(0xFF094D22),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF094D22)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Registered Users', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
        ),
        body: content,
      );
    }
    return content;
  }
}
