import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../customer/chat_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  Future<Map<String, String?>> _getStaffInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
        
    return {
      'email': user?.email,
      'name': user?.displayName ?? userDoc.data()?['name'],
      'uid': user?.uid,
    };
  }
  
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getStaffInfo(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
  final staffUid = snap.data?['uid'];
  final staffName = snap.data?['name'];

        return Scaffold(
          appBar: AppBar(
            // Simple logo/avatar at leading (replace with Image.asset if you add a real logo)
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text('VP', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            title: const Text('Dashboard Nhân viên'),
            actions: [
              IconButton(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                tooltip: 'Đăng xuất',
              )
            ],
          ),
          body: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                // show name if available, otherwise show UID
                title: Text(staffName ?? staffUid ?? ''),
                subtitle: const Text('Nhân viên vệ sinh'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Các booking được giao', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                    .collection('bookings')
                    // bookings should match assigned staff by UID
                    .where('staffId', isEqualTo: staffUid)
                    .orderBy('createdAtMs', descending: true)
                    .snapshots(),
                  builder: (ctx, bookingSnap) {
                    if (bookingSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = bookingSnap.data?.docs ?? [];
                    if (docs.isEmpty) return const Center(child: Text('Chưa có lịch được giao'));
                    
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final bookingDoc = docs[i];
                        final d = bookingDoc.data();
                        return ListTile(
                          leading: const Icon(Icons.cleaning_services),
                          title: Text(d['serviceType'] ?? 'Dịch vụ'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Khách: ${d['name'] ?? ''}'),
                              Text('SĐT: ${d['phone'] ?? ''}'),
                              Text('Địa chỉ: ${d['address'] ?? ''}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.chat),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  bookingId: bookingDoc.id,
                                  peerName: d['name'] ?? 'Khách',
                                  currentUserId: staffUid, // ID của nhân viên (UID)
                                ),
                              ));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ChatScreen(),
              ));
            },
            child: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat hỗ trợ',
          ),
        );
      },
    );
  }
}
