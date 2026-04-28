import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalysisPage extends StatefulWidget {
  const AdminAnalysisPage({super.key});

  @override
  State<AdminAnalysisPage> createState() => _AdminAnalysisPageState();
}

class _AdminAnalysisPageState extends State<AdminAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Analysis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
            ),
            const SizedBox(height: 6),
            Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFF81C784), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            
            // Payment Analysis Chart
            const Text('Weekly Payment Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 24),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[value.toInt()], style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value % 5000 == 0) {
                            return Text('₹${(value / 1000).toInt()}k', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5000),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeGroupData(0, 12000),
                    _makeGroupData(1, 15000),
                    _makeGroupData(2, 8000),
                    _makeGroupData(3, 18000),
                    _makeGroupData(4, 11000),
                    _makeGroupData(5, 14000),
                    _makeGroupData(6, 16000),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Payment Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(child: _buildSimpleStat('Completed', '₹85,420', Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildSimpleStat('Pending', '₹12,250', Colors.orange)),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF094D22),
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
        ],
      ),
    );
  }
}
