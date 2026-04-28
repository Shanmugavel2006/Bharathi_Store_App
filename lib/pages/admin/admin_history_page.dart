import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'dart:async';

class AdminHistoryPage extends StatefulWidget {
  const AdminHistoryPage({super.key});

  @override
  State<AdminHistoryPage> createState() => _AdminHistoryPageState();
}

class _AdminHistoryPageState extends State<AdminHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF094D22)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Complete History',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF094D22),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getFullActivityStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ));
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No history found',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              );
            }

            final activities = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(height: 24, color: isDark ? Colors.grey[800] : Colors.grey[200]),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityRow(
                  activity['title'], 
                  activity['time'], 
                  isDark: isDark
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getFullActivityStream() {
    // Fetch up to 100 recent items across collections
    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
        
    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();

    return RxHelper.combineLatest2<QuerySnapshot, QuerySnapshot, List<Map<String, dynamic>>>(
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
        return activities;
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    if (timestamp is! Timestamp) return 'Unknown time';
    
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
              const SizedBox(height: 4),
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

// Simple Rx implementation helper
class RxHelper {
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
