import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cleaner_detail_screen.dart';

class CleanersListScreen extends StatelessWidget {
  const CleanersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhân viên vệ sinh')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('cleaners').orderBy('rating', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có nhân viên'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final c = doc.data();
              final photo = c['photoUrl'] as String?;
              final double rating = (c['rating'] ?? 0).toDouble();
              final int reviews = (c['reviewsCount'] ?? 0).toInt();
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: photo != null && photo.isNotEmpty ? NetworkImage(photo) : null,
                    child: photo == null || photo.isEmpty ? Text((c['name'] ?? 'N')[0]) : null,
                  ),
                  title: Text(c['name'] ?? 'Nhân viên', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children:[const Icon(Icons.star,size:13,color:Colors.amber), SizedBox(width:3), Text('${rating.toStringAsFixed(1)} (${reviews})')]),
                        if (c['specialty']!=null) Text('Chuyên môn: ${c['specialty']}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (c['exp']!=null) Text('Kinh nghiệm: ${c['exp']}'),
                        if (c['phone']!=null) Text('SĐT: ${c['phone']}'),
                        if (c['birthYear']!=null) Text('Năm sinh: ${c['birthYear']}'),
                        if (c['address']!=null) Text('Địa chỉ: ${c['address']}'),
                        if (c['email']!=null) Text('Email: ${c['email']}'),
                        if (c['bio']!=null && c['bio']!='') Text('Mô tả: ${c['bio']}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CleanerDetailScreen(cleanerId: doc.id, cleaner: c),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




