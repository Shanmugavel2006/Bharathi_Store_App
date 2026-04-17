import 'package:flutter/material.dart';

class UserOrderSuccessPage extends StatelessWidget {
  const UserOrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: const Text('Bharathi Store', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_bag, color: Color(0xFF094D22)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: const Color(0xFF98F598), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.check_circle, color: Color(0xFF094D22), size: 48),
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Placed\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Thank you for choosing Bharathi Departmental Store.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORDER DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Date', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                            SizedBox(height: 4),
                            Text('October 24, 2023', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('Time', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                            SizedBox(height: 4),
                            Text('10:30 AM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('DELIVERY ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                    SizedBox(height: 16),
                    Text('Alex Thompson', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                    SizedBox(height: 4),
                    Text('+1 (555) 012-3456', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    SizedBox(height: 16),
                    Text('742 Evergreen Terrace,\nSpringfield, Orchard District,\nFL 32789', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: const Color(0xFF094D22), borderRadius: BorderRadius.circular(16)),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Icon(Icons.eco, color: Colors.white.withOpacity(0.08), size: 150),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ORDER SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF86EFAC))),
                          const SizedBox(height: 16),
                          const Text('Total Amount Paid', style: TextStyle(fontSize: 11, color: Color(0xFF86EFAC))),
                          const SizedBox(height: 4),
                          const Text('\$142.50', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(12)),
                            child: const Text('PAID VIA CREDIT CARD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094D22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Continue Shopping', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
