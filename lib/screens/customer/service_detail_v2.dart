import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../booking_form.dart';

/// Clean implementation of service detail screen (v2).
class ServiceDetailScreenV2 extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final List<String>? imageUrls;
  final List<String>? imageAssets; // optional local asset fallbacks

  const ServiceDetailScreenV2({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrls,
    this.imageAssets,
  });

  @override
  State<ServiceDetailScreenV2> createState() => _ServiceDetailScreenV2State();
}

class _ServiceDetailScreenV2State extends State<ServiceDetailScreenV2> {
  int _page = 0;

  Map<String, dynamic> _getDetailsFor(String title) {
    // Provide richer, service-specific details
    if (title.toLowerCase().contains('sofa') || title.toLowerCase().contains('thảm')) {
      return {
        'process': [
          'Kiểm tra vết bẩn và phân loại vải',
          'Hút bụi tổng thể',
          'Tiền xử lý vết bẩn',
          'Giặt chuyên sâu bằng máy hơi nước/thiết bị chuyên dụng',
          'Sấy và kiểm tra lần cuối',
        ],
        'duration': '30–90 phút tùy kích thước và mức độ bẩn',
        'materials': 'Máy giặt hơi nước, chất tẩy sinh học an toàn cho vải, khăn microfibre',
        'warranty': 'Bảo hành 24 giờ cho các vết bẩn đã xử lý lại nếu không đạt',
        'faq': [
          'Có thể xử lý mùi hôi không? Có, sử dụng liệu pháp ozone nhẹ hoặc chất khử mùi chuyên dụng.',
          'Bao lâu thì khô? Thường 2–6 giờ tùy điều kiện thông gió.'
        ],
      };
    }
    // Default: house cleaning / deep cleaning
    return {
      'process': [
        'Dọn dẹp sơ bộ và phân vùng khu vực',
        'Thực hiện lau chùi, hút bụi, vệ sinh bề mặt',
        'Vệ sinh khu vực bếp và nhà tắm chuyên sâu',
        'Khử khuẩn bề mặt thường xuyên chạm',
        'Kiểm tra và bàn giao',
      ],
      'duration': '2–4 giờ (tùy diện tích và mức độ)',
      'materials': 'Hóa chất an toàn, máy hút bụi, khăn microfiber, cây lau',
      'warranty': 'Hỗ trợ xử lý các vấn đề phát sinh trong 24 giờ',
      'faq': [
        'Cần chuẩn bị gì trước khi nhân viên tới? Dọn gọn đồ cá nhân và mở cửa các khu vực cần vệ sinh.',
        'Có thể yêu cầu hóa chất không mùi không? Có, vui lòng ghi chú khi đặt lịch.'
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
  final images = widget.imageAssets != null && widget.imageAssets!.isNotEmpty
    ? widget.imageAssets!
    : (widget.imageUrls ?? <String>[]);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                images.isEmpty
                    ? Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
                      )
                    : PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (context, index) {
                          final src = images[index];
                          // If imageAssets were provided, they are asset paths; otherwise src is a network URL
                          final useAsset = widget.imageAssets != null && widget.imageAssets!.isNotEmpty;
                          if (useAsset) {
                            return Image.asset(
                              src,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.broken_image, size: 48)),
                              ),
                            );
                          }
                          return CachedNetworkImage(
                            imageUrl: src,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (c, s) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (c, s, e) => Container(
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.broken_image, size: 48)),
                            ),
                          );
                        },
                      ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _page == i ? Colors.white : Colors.white70,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.price_check, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(widget.price, style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 12),
                const Text('Bao gồm:', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('- Lau bụi, hút bụi, lau sàn\n- Vệ sinh phòng bếp và nhà tắm\n- Khử khuẩn bề mặt thường xuyên chạm vào', style: TextStyle(height: 1.4)),
                const SizedBox(height: 12),
                // Additional detailed sections
                Builder(builder: (context) {
                  final details = _getDetailsFor(widget.title);
                  final process = details['process'] as List<String>;
                  final duration = details['duration'] as String;
                  final materials = details['materials'] as String;
                  final warranty = details['warranty'] as String;
                  final faq = details['faq'] as List<String>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quy trình thực hiện', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      ...process.map((s) => Text('- $s')),
                      const SizedBox(height: 12),
                      Text('Thời gian ước tính: $duration', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Thiết bị & Hóa chất: $materials'),
                      const SizedBox(height: 8),
                      Text('Chính sách: $warranty'),
                      const SizedBox(height: 12),
                      const Text('Câu hỏi thường gặp', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      ...faq.map((q) => Text('- $q')),
                      const SizedBox(height: 18),
                    ],
                  );
                }),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Đặt lịch'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingForm(serviceType: widget.title)));
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
