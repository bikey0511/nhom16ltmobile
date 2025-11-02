import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../customer/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../customer/chat_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tab = 0;
  final ImagePicker _picker = ImagePicker();
  

  @override
  Widget build(BuildContext context) {
    final pages = [
      _BookingsTab(),
      _AccountsTab(),
      _StaffTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // sign out and return to home
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: pages[_tab],
      floatingActionButton: _tab == 2
          ? FloatingActionButton(
              onPressed: () => _showAddStaffDialog(context),
              child: const Icon(Icons.person_add),
              tooltip: 'Thêm nhân viên',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đặt lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Nhân viên'),
        ],
      ),
    );
  }

  // admin sign-in removed

  Future<void> _showAddStaffDialog(BuildContext ctx) async {
    final _formKey = GlobalKey<FormState>();
    final nameCtr = TextEditingController();
    final emailCtr = TextEditingController();
    final phoneCtr = TextEditingController();
    String? area;
    XFile? pickedImage;

    await showDialog<void>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('Thêm nhân viên'),
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            width: 360,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final p = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (p != null) setState(() => pickedImage = p);
                      },
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: pickedImage != null ? FileImage(File(pickedImage!.path)) as ImageProvider : null,
                        child: pickedImage == null ? const Icon(Icons.camera_alt) : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(controller: nameCtr, decoration: const InputDecoration(labelText: 'Họ và tên'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên' : null),
                    TextFormField(controller: emailCtr, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập email' : null),
                    TextFormField(controller: phoneCtr, decoration: const InputDecoration(labelText: 'SĐT'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập SĐT' : null),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: area,
                      decoration: const InputDecoration(labelText: 'Khu vực'),
                      items: ['Quận 1', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 7', 'Quận 11']
                          .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                          .toList(),
                      onChanged: (v) => setState(() => area = v),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              // validate duplicate email
              final usersCol = FirebaseFirestore.instance.collection('users');
              final email = emailCtr.text.trim();
              final dup = await usersCol.where('email', isEqualTo: email).limit(1).get();
              if (dup.docs.isNotEmpty) {
                // show error and keep dialog open
                if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Email đã tồn tại')));
                return;
              }
              Navigator.of(dctx).pop();
              // perform upload and create user doc
              final newDoc = usersCol.doc();
              String? imageUrl;
              if (pickedImage != null) {
                final ref = FirebaseStorage.instance.ref().child('staff_photos/${newDoc.id}.jpg');
                final task = await ref.putFile(File(pickedImage!.path));
                imageUrl = await task.ref.getDownloadURL();
              }
              await newDoc.set({
                'name': nameCtr.text.trim(),
                'email': email,
                'phone': phoneCtr.text.trim(),
                'role': 'staff',
                'area': area ?? '',
                'profileImageUrl': imageUrl ?? '',
                'assignments': [],
                'createdAtMs': DateTime.now().millisecondsSinceEpoch,
              });
              if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Thêm nhân viên thành công')));
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAtMs', descending: true).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final d = docs[i].data();
            return ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: Text(d['serviceType'] ?? 'Dịch vụ'),
              subtitle: d['staffId'] != null && (d['staffId'] as String).isNotEmpty
                  ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance.collection('users').doc(d['staffId'] as String).get(),
                      builder: (ctx, staffSnap) {
                        final staffName = staffSnap.hasData ? (staffSnap.data!.data()?['name'] ?? (d['staffId'] as String)) : (d['staffId'] as String);
                        return Text('Khách: ${d['name'] ?? ''}\nTrạng thái: ${d['status'] ?? ''}\nNhân viên: $staffName');
                      },
                    )
                  : Text('Khách: ${d['name'] ?? ''}\nTrạng thái: ${d['status'] ?? ''}\nNhân viên: Chưa phân công'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'assign') {
                    // simple assign UI: pick staff by id
                    final staffId = await _pickStaffId(context);
                    if (staffId != null) {
                      final bookingRef = FirebaseFirestore.instance.collection('bookings').doc(docs[i].id);
                      await bookingRef.update({'staffId': staffId});
                      // update staff assignments history
                      await FirebaseFirestore.instance.collection('users').doc(staffId).update({
                        'assignments': FieldValue.arrayUnion([docs[i].id])
                      });
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phân công nhân viên thành công')));
                    }
                  } else if (v == 'chat') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(bookingId: docs[i].id, peerName: d['name'])));
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'assign', child: Text('Phân công nhân viên')),
                  const PopupMenuItem(value: 'chat', child: Text('Mở chat với khách')),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _pickStaffId(BuildContext context) async {
    final staffSnap = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'staff').get();
    return showDialog<String?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn nhân viên'),
        children: staffSnap.docs.map((d) {
          final m = d.data();
          return SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(d.id),
            child: Text(m['name'] ?? d.id),
          );
        }).toList(),
      ),
    );
  }
}

class _AccountsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final disabled = (d['disabled'] ?? false) as bool;
            final role = (d['role'] ?? 'user') as String;
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(d['name'] ?? docs[i].id),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['email'] ?? ''),
                  if (disabled) const Text('Tài khoản: Đã vô hiệu hóa', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(role),
                  const SizedBox(width: 8),
                  // Admin accounts cannot be disabled
                  Switch(
                    value: disabled,
                    onChanged: role == 'admin'
                        ? null
                        : (v) async {
                            await FirebaseFirestore.instance.collection('users').doc(docs[i].id).update({'disabled': v});
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v ? 'Vô hiệu hóa tài khoản thành công' : 'Kích hoạt tài khoản thành công')));
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StaffTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'staff').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final m = docs[i].data();
            return ListTile(
              leading: (m['profileImageUrl'] != null && (m['profileImageUrl'] as String).isNotEmpty)
                  ? CircleAvatar(radius: 22, backgroundImage: NetworkImage(m['profileImageUrl'] as String))
                  : const Icon(Icons.person_pin),
              title: Text(m['name'] ?? docs[i].id),
              subtitle: Text('Khu vực: ${m['area'] ?? 'Chưa phân công'}'),
              trailing: TextButton(
                onPressed: () async {
                  final area = await _pickArea(context, m['area'] as String?);
                  if (area != null) {
                    await FirebaseFirestore.instance.collection('users').doc(docs[i].id).update({'area': area});
                  }
                },
                child: const Text('Phân công'),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _pickArea(BuildContext context, String? current) async {
    final areas = ['Quận 1', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 7', 'Quận 11'];
    return showDialog<String?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn khu vực'),
        children: areas.map((a) => SimpleDialogOption(onPressed: () => Navigator.of(ctx).pop(a), child: Text(a))).toList(),
      ),
    );
  }
}
