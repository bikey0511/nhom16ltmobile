import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import '../staff/staff_dashboard_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../booking_history.dart';
import 'package:flutter/services.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _isLogin = true;
  String _role = 'customer'; // mặc định là khách hàng
  User? _currentUser = FirebaseAuth.instance.currentUser;

  // -------------------- GOOGLE SIGN-IN --------------------
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

    final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user!;
    await _saveUserToFirestore(user);

    // Block login if account is disabled
    final allowed = await _postSignInCheck(user);
    if (!allowed) return;

    _navigateAfterLogin(user.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập Google thành công!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng nhập Google: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // -------------------- EMAIL SIGN-IN / REGISTER --------------------
  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        // Đăng nhập
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Block login if account is disabled
        final user = userCredential.user!;
        final allowed = await _postSignInCheck(user);
        if (!allowed) return;
        _navigateAfterLogin(userCredential.user!.uid);
      } else {
        // Đăng ký
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user?.updateDisplayName(_nameController.text);
        await _saveUserToFirestore(userCredential.user!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công!')),
        );

        // Sau khi đăng ký, chuyển về màn hình đăng nhập
        setState(() {
          _isLogin = true;
          _emailController.clear();
          _passwordController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.message}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // -------------------- SAVE USER TO FIRESTORE --------------------
  Future<void> _saveUserToFirestore(User user) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': user.displayName ?? _nameController.text,
        'email': user.email,
        'role': _role,
        'provider': user.providerData.first.providerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // -------------------- CHUYỂN HƯỚNG SAU KHI ĐĂNG NHẬP --------------------
  Future<void> _navigateAfterLogin(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!mounted) return;

    final role = doc.exists ? (doc.data()?['role'] as String?) : null;
    if (role == 'staff') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffDashboardScreen()),
      );
    } else if (role == 'admin') {
      // admin -> open admin dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // -------------------- LOGOUT --------------------
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    setState(() => _currentUser = null);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã đăng xuất!')));
  }

  // -------------------- POST-SIGNIN DISABLED CHECK --------------------
  /// Returns true if account is allowed (not disabled). If disabled, signs out and shows message.
  Future<bool> _postSignInCheck(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final disabled = doc.exists ? (doc.data()?['disabled'] ?? false) as bool : false;
      if (disabled) {
        // Sign out and show message
        await FirebaseAuth.instance.signOut();
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
        setState(() => _currentUser = null);
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Tài khoản bị vô hiệu hóa'),
              content: const Text('Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên để biết thêm chi tiết.'),
              actions: [
                ElevatedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đóng')),
              ],
            ),
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      // On error, allow login (or you may choose to block); we'll allow but log
      debugPrint('Error checking disabled flag: $e');
      return true;
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser != null
              ? _buildUserProfile()
              : _buildAuthForm(),
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: _currentUser!.photoURL != null ? NetworkImage(_currentUser!.photoURL!) : null,
            child: _currentUser!.photoURL == null ? const Icon(Icons.person, size: 48) : null,
          ),
          const SizedBox(height: 16),
          Text('Xin chào,', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 6),
          Text(_currentUser!.displayName ?? 'Người dùng', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_currentUser!.email ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingHistory())),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Đã đặt'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng Thông báo đang phát triển')));
                },
                icon: const Icon(Icons.notifications),
                label: const Text('Thông báo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                    ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Đăng xuất')),
                  ],
                ),
              );
              if (confirm == true) await _logout();
            },
            label: const Text('Đăng xuất'),
          ),
          const SizedBox(height: 10),
          // Account management buttons
          OutlinedButton.icon(
            onPressed: () async {
              // Copy profile info to clipboard
              final info = 'Tên: ${_currentUser!.displayName}\nEmail: ${_currentUser!.email}';
              await Clipboard.setData(ClipboardData(text: info));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thông tin đã được sao chép')));
            },
            icon: const Icon(Icons.copy),
            label: const Text('Sao chép thông tin'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (!_isLogin)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
            if (!_isLogin) const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.length < 6
                  ? 'Mật khẩu phải có ít nhất 6 ký tự'
                  : null,
            ),
            const SizedBox(height: 16),
            if (!_isLogin)
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Khách hàng')),
                  DropdownMenuItem(value: 'staff', child: Text('Nhân viên')),
                ],
                onChanged: (value) => setState(() => _role = value!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Loại tài khoản',
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleEmailSignIn,
              child: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? 'Chưa có tài khoản? Đăng ký'
                    : 'Đã có tài khoản? Đăng nhập',
              ),
            ),
            const Divider(height: 32),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập bằng Google'),
            ),
          ],
        ),
      ),
    );
  }
}
