import 'package:flutter/material.dart';
import '../../booking_form.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = const [
      {
        'title': 'Vệ sinh nhà ở',
        'desc': 'Dọn dẹp tổng quát, theo giờ/ngày',
        'price': '150.000đ/giờ',
        'icon': Icons.home,
        'color': Color(0xFF4CAF50),
      },
      {
        'title': 'Giặt sofa - thảm',
        'desc': 'Thiết bị chuyên dụng, khử khuẩn',
        'price': '200.000đ/m2',
        'icon': Icons.chair,
        'color': Color(0xFF2196F3),
      },
      {
        'title': 'Tổng vệ sinh',
        'desc': 'Sau xây dựng, chuyển nhà',
        'price': '300.000đ/phòng',
        'icon': Icons.build,
        'color': Color(0xFFFF9800),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dịch vụ')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = services[i];
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingForm(serviceType: s['title'] as String),
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: (s['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        s['icon'] as IconData,
                        color: s['color'] as Color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['title'] as String,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['desc'] as String,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s['price'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0FB2B2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}