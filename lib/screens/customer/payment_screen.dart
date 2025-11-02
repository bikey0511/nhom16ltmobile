import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatelessWidget {
  final int amount;
  final String bookingId;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    final qrUrl =
        'https://img.vietqr.io/image/970423-04041963968-HlYXCD9.jpg'
        '?accountName=NGUYEN%20VAN%20AN'
        '&amount=$amount'
        '&addInfo=DV$bookingId';

    String formattedAmount() {
      final s = amount.toString();
      return s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ".") + 'đ';
    }

    final transferInfo = 'Ngân hàng: TPBank\nSTK: 04041963968\nChủ TK: NGUYEN VAN AN\nNội dung: DV$bookingId\nSố tiền: $amount VNĐ';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quét mã để thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrUrl,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text('Số tiền: ${formattedAmount()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ngân hàng: TPBank', style: TextStyle(color: Colors.blue.shade800)),
                          const SizedBox(height: 4),
                          const Text('STK: 04041963968', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          const Text('Chủ TK: NGUYEN VAN AN'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: transferInfo));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép thông tin chuyển khoản')));
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Sao chép thông tin'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context, true),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Đã thanh toán'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
