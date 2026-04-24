import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'dart:async';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Statistics',
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
            const SizedBox(height: 32),
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(
                  'Total Products', 
                  'products', 
                  Icons.inventory_2_outlined, 
                  const Color(0xFFE3F2FD), 
                  const Color(0xFF1976D2),
                  isDark: isDark
                ),
                _buildStatCard(
                  'Registered Users', 
                  'users', 
                  Icons.people_outline, 
                  const Color(0xFFF1F8E9), 
                  const Color(0xFF388E3C),
                  isDark: isDark
                ),
                _buildStatCard(
                  'Delivery Register', 
                  'delivery_partners', 
                  Icons.local_shipping_outlined, 
                  const Color(0xFFFFF3E0), 
                  const Color(0xFFF57C00),
                  isDark: isDark
                ),
                _buildStatCard(
                  'Pending Orders', 
                  'orders', 
                  Icons.pending_actions_outlined, 
                  const Color(0xFFFCE4EC), 
                  const Color(0xFFC2185B),
                  query: (ref) => ref.where('status', isEqualTo: 'pending'),
                  isDark: isDark
                ),
                _buildStatCard(
                  'Completed Orders', 
                  'orders', 
                  Icons.check_circle_outline, 
                  const Color(0xFFE8F5E9), 
                  const Color(0xFF2E7D32),
                  query: (ref) => ref.where('status', isEqualTo: 'completed'),
                  isDark: isDark
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 16),
            
            // Activity List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getCombinedActivityStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'No recent activity',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    );
                  }

                  final activities = snapshot.data!;
                  return Column(
                    children: List.generate(activities.length, (index) {
                      final activity = activities[index];
                      return Column(
                        children: [
                          _buildActivityRow(
                            activity['title'], 
                            activity['time'], 
                            isDark: isDark
                          ),
                          if (index < activities.length - 1) 
                            Divider(height: 32, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                        ],
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getCombinedActivityStream() {
    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();
        
    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, List<Map<String, dynamic>>>(
      usersStream,
      ordersStream,
      (userSnap, orderSnap) {
        final List<Map<String, dynamic>> activities = [];
        
        for (var doc in userSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          activities.add({
            'title': 'New user "${data['name'] ?? 'Unknown'}" registered',
            'time': _formatTimestamp(data['createdAt']),
            'timestamp': data['createdAt'] ?? Timestamp.now(),
          });
        }
        
        for (var doc in orderSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          activities.add({
            'title': 'New order received from ${data['customerName'] ?? 'Unknown'}',
            'time': _formatTimestamp(data['createdAt']),
            'timestamp': data['createdAt'] ?? Timestamp.now(),
          });
        }
        
        activities.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
        return activities.take(5).toList();
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is! Timestamp) return 'Some time ago';
    
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }

  Widget _buildStatCard(String label, String collection, IconData icon, Color bgColor, Color iconColor, {Query Function(CollectionReference)? query, required bool isDark}) {
    Query baseQuery = FirebaseFirestore.instance.collection(collection);
    if (query != null) {
      baseQuery = query(FirebaseFirestore.instance.collection(collection));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: baseQuery.snapshots(),
      builder: (context, snapshot) {
        String count = '...';
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length.toString();
        } else if (snapshot.hasError) {
          count = '0';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withOpacity(0.1) : bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActivityRow(String title, String time, {required bool isDark}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF094D22),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Simple Rx implementation helper since we don't have rxdart
class Rx {
  static Stream<T> combineLatest2<A, B, T>(
    Stream<A> streamA,
    Stream<B> streamB,
    T Function(A a, B b) combiner,
  ) async* {
    A? lastA;
    B? lastB;
    bool hasA = false;
    bool hasB = false;

    await for (final value in _mergeStreams([
      streamA.map((a) => _StreamValue<A, B>(a: a)),
      streamB.map((b) => _StreamValue<A, B>(b: b)),
    ])) {
      if (value.a != null || (value.a == null && value.isA)) {
        lastA = value.a;
        hasA = true;
      }
      if (value.b != null || (value.b == null && !value.isA)) {
        lastB = value.b;
        hasB = true;
      }

      if (hasA && hasB) {
        yield combiner(lastA as A, lastB as B);
      }
    }
  }

  static Stream<T> _mergeStreams<T>(Iterable<Stream<T>> streams) async* {
    final master = StreamController<T>();

    for (final stream in streams) {
      stream.listen(
        master.add,
        onError: master.addError,
      );
    }
    yield* master.stream;
  }
}

class _StreamValue<A, B> {
  final A? a;
  final B? b;
  final bool isA;
  _StreamValue({this.a, this.b}) : isA = a != null || (a == null && b == null);
}
