import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() => _currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa đăng nhập, hiển thị lời nhắc và nút tới trang Tài khoản
    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Vui lòng đăng nhập để xem lịch đặt', 
              style: TextStyle(fontSize: 16, color: Colors.grey)
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/account'),
              child: const Text('Đăng nhập / Đăng ký'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: _currentUser!.uid)
          // Order ưu tiên theo createdAtMs (client), fallback createdAt (server)
          .orderBy('createdAtMs', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        print('📊 History snapshot: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, docs: ${snapshot.data?.docs.length ?? 0}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cleaning_services, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chưa có lịch đặt', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Hãy đặt dịch vụ để xem lịch sử', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        final items = snapshot.data!.docs;
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
            return Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (data['status'] ?? 'pending') == 'paid' 
                      ? Colors.green 
                      : Colors.orange,
                  child: Icon(
                    (data['status'] ?? 'pending') == 'paid' 
                        ? Icons.check 
                        : Icons.schedule,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  data['serviceType'] ?? 'Dịch vụ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('👤 ${data['name'] ?? ''}'),
                    Text('📞 ${data['phone'] ?? ''}'),
                    Text('📍 ${data['address'] ?? ''}'),
                    Text('🕒 $when'),
                    if (data['note']?.isNotEmpty == true)
                      Text('📝 ${data['note']}'),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (data['status'] ?? 'pending') == 'paid' 
                        ? Colors.green 
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (data['status'] ?? 'pending') == 'paid' ? 'Đã thanh toán' : 'Chờ thanh toán',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

