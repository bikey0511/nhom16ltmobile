import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class BookingHistory extends StatelessWidget {
  const BookingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // If user is not logged in, show no bookings and prompt to login
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn chưa đăng nhập'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/account'),
              child: const Text('Đăng nhập / Đăng ký'),
            ),
          ],
        ),
      );
    }

    // Query without server-side ordering to avoid composite-index requirement.
    // We'll sort the documents locally by 'createdAtMs'.
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        debugPrint('DEBUG BookingHistory: connectionState=${snapshot.connectionState} hasData=${snapshot.hasData} docs=${snapshot.data?.docs.length ?? 0} fromCache=${snapshot.data?.metadata.isFromCache} error=${snapshot.error}');
        if (snapshot.hasError) {
          // Common cause: Firestore requires a composite index for the query. Show helpful message.
          debugPrint('BookingHistory stream error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Lỗi khi lấy lịch đặt từ server.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 12),
                  const Text('Nếu log báo "The query requires an index", hãy mở link trong log để tạo Index trong Firebase Console.'),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Chưa có lịch đặt'));
        }
        // Copy docs and sort locally by createdAtMs (descending)
        final items = snapshot.data!.docs.toList();
        items.sort((a, b) {
          final ma = a.data()['createdAtMs'];
          final mb = b.data()['createdAtMs'];
          final ia = ma is int ? ma : (ma is num ? ma.toInt() : 0);
          final ib = mb is int ? mb : (mb is num ? mb.toInt() : 0);
          return ib.compareTo(ia);
        });
        // log document ids and key fields for debugging
        for (final d in items) {
          final map = d.data();
          debugPrint('DEBUG BookingHistory doc: id=${d.id} userId=${map['userId']} status=${map['status']} scheduledAt=${map['scheduledAt']} createdAtMs=${map['createdAtMs']}');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = items[index].data();
            final ts = data['scheduledAt'];
            DateTime? scheduled;
            if (ts is Timestamp) scheduled = ts.toDate();
            final when = scheduled == null
                ? '—'
                : DateFormat('dd/MM/yyyy HH:mm').format(scheduled);
            final status = (data['status'] ?? 'pending').toString();
            final isPaid = status.toLowerCase() == 'paid' || status.toLowerCase() == 'completed' || status.toLowerCase() == 'done';
            return Card(
              child: ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: Text(data['serviceType'] ?? 'Dịch vụ'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thời gian: $when'),
                    Text('Địa chỉ: ${data['address'] ?? ''}', overflow: TextOverflow.visible),
                  ],
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.shade600 : Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Sao chép thông tin đặt',
                      onPressed: () async {
                        final info = 'Dịch vụ: ${data['serviceType'] ?? ''}\nThời gian: $when\nĐịa chỉ: ${data['address'] ?? ''}\nTrạng thái: $status';
                        await Clipboard.setData(ClipboardData(text: info));
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thông tin đã được sao chép')));
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


