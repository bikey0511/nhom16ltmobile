import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../booking_form.dart';

class CleanerDetailScreen extends StatelessWidget {
  final String? cleanerId;
  final Map<String, dynamic> cleaner;
  const CleanerDetailScreen({super.key, this.cleanerId, required this.cleaner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cleaner['name'] ?? 'Nhân viên')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
              children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: (cleaner['photoUrl'] ?? '').toString().isNotEmpty
                    ? NetworkImage(cleaner['photoUrl'])
                    : null,
                child: ((cleaner['photoUrl'] ?? '').toString().isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleaner['name'] ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${(cleaner['rating'] ?? 0).toString()} (${(cleaner['reviewsCount'] ?? 0)})'),
                      ]),
                      Text('Năm sinh: ${cleaner['birthYear'] ?? '—'}'),
                      Text('Tình trạng: ${cleaner['status'] ?? '—'}'),
                    ],
                  ),
                )
              ],
          ),
          const SizedBox(height: 16),
          Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(cleaner['bio'] ?? '—'),
          const SizedBox(height: 16),
          Text('Bình luận', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (cleanerId != null)
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('cleaners')
                  .doc(cleanerId)
                  .collection('comments')
                  .orderBy('createdAtMs', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = (snapshot.data as dynamic)?.docs ?? [];
                if (docs.isEmpty) return const Text('Chưa có bình luận');
                return Column(
                  children: [
                    for (final d in docs)
                      ListTile(
                        leading: const Icon(Icons.comment),
                        title: Text(d['content'] ?? ''),
                        subtitle: Text(d['author'] ?? 'Ẩn danh'),
                      )
                  ],
                );
              },
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingForm()));
              },
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Đặt lịch với nhân viên này'),
            ),
          )
        ],
      ),
    );
  }
}




