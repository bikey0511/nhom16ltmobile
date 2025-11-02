import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatScreen extends StatefulWidget {
  final String? bookingId;
  final String? peerName;
  final String? currentUserId; // ID của người dùng hiện tại (khách hoặc nhân viên)
  const ChatScreen({super.key, this.bookingId, this.peerName, this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _finalUserId;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _setupUserId();
  }
  
  void _setupUserId() async {
    if (widget.currentUserId != null) {
      setState(() => _finalUserId = widget.currentUserId);
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() => _finalUserId = user.uid);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/account', (route) => false);
      }
    }
  }

  Future<void> _send() async {
    if (_finalUserId == null) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final roomId = widget.bookingId ?? _finalUserId!;
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .add({
      'sender': _finalUserId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _pickAndSendImage() async {
    if (_finalUserId == null) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _uploading = true);
    final roomId = widget.bookingId ?? _finalUserId!;
    try {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref().child('chat_images/$roomId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('chats').doc(roomId).collection('messages').add({
        'sender': _finalUserId,
        'imageUrl': url,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi upload ảnh: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomId = widget.bookingId ?? _finalUserId;
    if (roomId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.peerName != null ? 'Chat với ${widget.peerName}' : 'Chat hỗ trợ')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(roomId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final m = docs[index].data();
                    final isMe = m['sender'] == _finalUserId;
                    Widget child;
                    if (m['imageUrl'] != null) {
                      child = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(m['imageUrl'], width: 220, fit: BoxFit.cover),
                      );
                    } else {
                      child = Text(m['text'] ?? '');
                    }
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF0FB2B2).withOpacity(0.15) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _uploading ? null : _pickAndSendImage,
                  icon: const Icon(Icons.photo),
                  tooltip: 'Gửi ảnh',
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }
}




