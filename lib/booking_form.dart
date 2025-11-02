import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vd5_tanphat/screens/customer/payment_screen.dart';


class BookingForm extends StatefulWidget {
  final String? serviceType;
  const BookingForm({super.key, this.serviceType});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  // Địa chỉ: chọn tỉnh/thành -> quận/huyện -> phường/xã -> số nhà
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedWard;
  final TextEditingController _houseController = TextEditingController();

  // Dữ liệu địa phương mẫu (demo). Bạn có thể mở rộng hoặc lấy từ API/Firestore.
  final Map<String, Map<String, List<String>>> _locations = {
    'Hồ Chí Minh': {
      'Quận 1': ['Phường Bến Nghé', 'Phường Bến Thành', 'Phường Cầu Kho', 'Phường Cầu Ông Lãnh', 'Phường Cô Giang', 'Phường Đa Kao', 'Phường Nguyễn Cư Trinh', 'Phường Nguyễn Thái Bình', 'Phường Phạm Ngũ Lão', 'Phường Tân Định'],
      'Quận 3': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14'],
      'Quận 4': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 13', 'Phường 14', 'Phường 15', 'Phường 16', 'Phường 18'],
      'Quận 5': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14'],
      'Quận 6': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14'],
      'Quận 7': ['Phường Tân Thuận Đông', 'Phường Tân Thuận Tây', 'Phường Tân Kiểng', 'Phường Tân Hưng', 'Phường Bình Thuận', 'Phường Tân Quy', 'Phường Phú Thuận', 'Phường Tân Phú', 'Phường Tân Phong', 'Phường Phú Mỹ'],
      'Quận 8': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14', 'Phường 15', 'Phường 16'],
      'Quận 10': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14', 'Phường 15'],
      'Quận 11': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14', 'Phường 15', 'Phường 16'],
      'Quận 12': ['Phường Thạnh Xuân', 'Phường Thạnh Lộc', 'Phường Hiệp Thành', 'Phường Thới An', 'Phường Tân Chánh Hiệp', 'Phường An Phú Đông', 'Phường Tân Thới Hiệp', 'Phường Trung Mỹ Tây', 'Phường Tân Hưng Thuận', 'Phường Đông Hưng Thuận', 'Phường Tân Thới Nhất'],
      'Quận Bình Tân': ['Phường Bình Hưng Hòa', 'Phường Bình Hưng Hoà A', 'Phường Bình Hưng Hoà B', 'Phường Bình Trị Đông', 'Phường Bình Trị Đông A', 'Phường Bình Trị Đông B', 'Phường Tân Tạo', 'Phường Tân Tạo A', 'Phường An Lạc', 'Phường An Lạc A'],
      'Quận Bình Thạnh': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14', 'Phường 15', 'Phường 17', 'Phường 19', 'Phường 21', 'Phường 22', 'Phường 24', 'Phường 25', 'Phường 26', 'Phường 27', 'Phường 28'],
      'Quận Gò Vấp': ['Phường 1', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14', 'Phường 15', 'Phường 16', 'Phường 17'],
      'Quận Phú Nhuận': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 13', 'Phường 15', 'Phường 17'],
      'Quận Tân Bình': ['Phường 1', 'Phường 2', 'Phường 3', 'Phường 4', 'Phường 5', 'Phường 6', 'Phường 7', 'Phường 8', 'Phường 9', 'Phường 10', 'Phường 11', 'Phường 12', 'Phường 13', 'Phường 14', 'Phường 15'],
      'Quận Tân Phú': ['Phường Tân Sơn Nhì', 'Phường Tây Thạnh', 'Phường Sơn Kỳ', 'Phường Tân Quý', 'Phường Tân Thành', 'Phường Phú Thọ Hoà', 'Phường Phú Thạnh', 'Phường Phú Trung', 'Phường Hoà Thạnh', 'Phường Hiệp Tân', 'Phường Tân Thới Hoà'],
      'Thành phố Thủ Đức': ['Phường Linh Xuân', 'Phường Bình Chiểu', 'Phường Linh Trung', 'Phường Tam Bình', 'Phường Tam Phú', 'Phường Hiệp Bình Phước', 'Phường Hiệp Bình Chánh', 'Phường Linh Chiểu', 'Phường Linh Tây', 'Phường Linh Đông', 'Phường Bình Thọ', 'Phường Trường Thọ', 'Phường Long Bình', 'Phường Long Thạnh Mỹ', 'Phường Tân Phú', 'Phường Hiệp Phú', 'Phường Tăng Nhơn Phú A', 'Phường Tăng Nhơn Phú B', 'Phường Phước Long B', 'Phường Phước Long A', 'Phường Trường Thạnh', 'Phường Long Phước', 'Phường Long Trường', 'Phường Phước Bình', 'Phường Phú Hữu', 'Phường Thảo Điền', 'Phường An Phú', 'Phường An Khánh', 'Phường Bình Trưng Đông', 'Phường Bình Trưng Tây', 'Phường Cát Lái', 'Phường Thạnh Mỹ Lợi', 'Phường An Lợi Đông', 'Phường Thủ Thiêm'],
      'Huyện Bình Chánh': ['Thị trấn Tân Túc', 'Xã Phạm Văn Hai', 'Xã Vĩnh Lộc A', 'Xã Vĩnh Lộc B', 'Xã Bình Lợi', 'Xã Lê Minh Xuân', 'Xã Tân Nhựt', 'Xã Tân Kiên', 'Xã Bình Hưng', 'Xã Phong Phú', 'Xã An Phú Tây', 'Xã Hưng Long', 'Xã Đa Phước', 'Xã Tân Quý Tây', 'Xã Quy Đức', 'Xã Bình Chánh'],
      'Huyện Cần Giờ': ['Thị trấn Cần Thạnh', 'Xã Bình Khánh', 'Xã Tam Thôn Hiệp', 'Xã An Thới Đông', 'Xã Thạnh An', 'Xã Long Hòa', 'Xã Lý Nhơn'],
      'Huyện Củ Chi': ['Thị trấn Củ Chi', 'Xã Phú Mỹ Hưng', 'Xã An Phú', 'Xã Trung Lập Thượng', 'Xã An Nhơn Tây', 'Xã Nhuận Đức', 'Xã Phạm Văn Cội', 'Xã Phú Hòa Đông', 'Xã Trung Lập Hạ', 'Xã Trung An', 'Xã Phước Thạnh', 'Xã Phước Hiệp', 'Xã Tân An Hội', 'Xã Phước Vĩnh An', 'Xã Thái Mỹ', 'Xã Tân Thạnh Tây', 'Xã Hòa Phú', 'Xã Tân Thạnh Đông', 'Xã Bình Mỹ', 'Xã Tân Phú Trung', 'Xã Tân Thông Hội'],
      'Huyện Hóc Môn': ['Thị trấn Hóc Môn', 'Xã Tân Hiệp', 'Xã Nhị Bình', 'Xã Đông Thạnh', 'Xã Tân Thới Nhì', 'Xã Thới Tam Thôn', 'Xã Xuân Thới Sơn', 'Xã Tân Xuân', 'Xã Xuân Thới Đông', 'Xã Trung Chánh', 'Xã Xuân Thới Thượng', 'Xã Bà Điểm'],
      'Huyện Nhà Bè': ['Thị trấn Nhà Bè', 'Xã Phước Kiển', 'Xã Phước Lộc', 'Xã Nhơn Đức', 'Xã Phú Xuân', 'Xã Long Thới', 'Xã Hiệp Phước']
    }
  };
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _serviceType = 'Vệ sinh nhà ở';
  final List<String> _serviceOptions = const [
    'Vệ sinh nhà ở',
    'Giặt sofa - thảm',
    'Tổng vệ sinh',
  ];
  bool _isSubmitting = false;
  int _finalAmount = 150000;

  String _formatCurrency(int amount) {
    final s = amount.toString();
    return s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ".");
  }

  @override
  void initState() {
    super.initState();
    if (widget.serviceType != null) {
      // If provided serviceType exists in known options, preselect it; otherwise leave null so user can pick
      if (_serviceOptions.contains(widget.serviceType)) {
        _serviceType = widget.serviceType!;
      } else {
        _serviceType = '';
      }
    }
    _couponController.addListener(_recomputeAmount);
    _checkAuth();
  }

  void _checkAuth() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Hiển thị dialog sau frame đầu tiên và chuyển đến trang đăng nhập
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Yêu cầu đăng nhập'),
            content: const Text('Bạn cần đăng nhập hoặc đăng ký để đặt lịch.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamed('/account');
                  // close booking form
                  Navigator.of(context).maybePop();
                },
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        );
      });
    }
  }
  void _recomputeAmount() {
    int amount = 150000; // base demo
    final code = _couponController.text.trim().toUpperCase();
    if (code == 'GIAM10') amount = (amount * 0.9).round();
    if (code == 'GIAM20') amount = (amount * 0.8).round();
    if (code == 'GIAM30') amount = (amount * 0.7).round();
    if (code == 'GIAM35') amount = (amount * 0.65).round();
    setState(() => _finalAmount = amount);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
      );
      return;
    }

    // Kiểm tra đăng nhập qua Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập trước khi đặt lịch')),
      );
      Navigator.of(context).pushNamed('/account');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final fullAddress = _selectedCity != null && _selectedDistrict != null && _selectedWard != null
          ? '${_houseController.text.trim()}, ${_selectedWard!}, ${_selectedDistrict!}, ${_selectedCity!}'
          : _addressController.text.trim();

  debugPrint('DEBUG: adding booking for user=${user.uid} scheduledAt=$scheduledDateTime finalAmount=$_finalAmount');
  final doc = await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'userEmail': user.email,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': fullAddress,
        'serviceType': _serviceType,
        'note': _noteController.text.trim(),
        'scheduledAt': Timestamp.fromDate(scheduledDateTime),
        'status': 'pending',
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
        'createdAt': FieldValue.serverTimestamp(),
        'discountCode': _couponController.text.trim().toUpperCase(),
        'amount': 150000,
        'finalAmount': _finalAmount,
  });
  debugPrint('DEBUG: booking created id=${doc.id}');
  // Attempt automatic assignment of a staff based on selected district / area
  try {
    String? matchedArea = _selectedDistrict;
    if (matchedArea == null || matchedArea.isEmpty) {
      // fallback: try match common area names inside fullAddress
      final possible = ['Quận 1', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 7', 'Quận 11'];
      for (final a in possible) {
        if (fullAddress.contains(a)) {
          matchedArea = a;
          break;
        }
      }
    }
    if (matchedArea != null && matchedArea.isNotEmpty) {
      final staffSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'staff')
          .where('area', isEqualTo: matchedArea)
          .get();
      if (staffSnap.docs.isNotEmpty) {
        final staffDoc = staffSnap.docs.first;
        await FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({'staffId': staffDoc.id});
        await FirebaseFirestore.instance.collection('users').doc(staffDoc.id).update({
          'assignments': FieldValue.arrayUnion([doc.id])
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã tự động phân công nhân viên: ${staffDoc.data()['name'] ?? staffDoc.id}')));
      }
    }
  } catch (e) {
    debugPrint('AUTO-ASSIGN ERROR: $e');
  }
  if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch thành công')),
        );
        
        // Use the centralized PaymentScreen for QR/payment UI and guard against errors
        bool? paid;
        try {
          debugPrint('DEBUG: showing PaymentScreen for booking ${doc.id} amount=$_finalAmount');
          // Require explicit action to avoid accidental dismiss on some devices
          paid = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => PaymentScreen(amount: _finalAmount, bookingId: doc.id),
          );
          debugPrint('DEBUG: PaymentScreen returned: $paid');
        } catch (e, st) {
          // If dialog fails, show a message and continue
          debugPrint('ERROR showing PaymentScreen: $e\n$st');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi hiển thị thanh toán: $e')),
          );
          paid = false;
        }

        // Fallback: if paid is null (dialog dismissed unexpectedly), show a simple confirmation dialog
        if (mounted && paid == null) {
          debugPrint('DEBUG: Payment dialog returned null, showing fallback alert');
          paid = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Thanh toán'),
              content: Text('Vui lòng thanh toán ${_formatCurrency(_finalAmount)}đ theo thông tin chuyển khoản.\nSau khi đã chuyển, nhấn "Đã thanh toán".'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Đã thanh toán')),
              ],
            ),
          );
          debugPrint('DEBUG: fallback dialog returned: $paid');
        }

        // Nếu người dùng xác nhận đã thanh toán (PaymentScreen trả về true) thì reset form
        if (mounted) {
          if (paid == true) {
            // Cập nhật trạng thái thanh toán trong Firebase
            await FirebaseFirestore.instance
                .collection('bookings')
                .doc(doc.id)
                .update({'status': 'paid'});

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cảm ơn bạn, đơn đã được thanh toán')),
            );
            _formKey.currentState!.reset();
            setState(() {
              _selectedDate = null;
              _selectedTime = null;
              _serviceType = 'Vệ sinh nhà ở';
              _couponController.clear();
            });
            Navigator.of(context).pushNamedAndRemoveUntil('/history', (route) => false);
          } else {
            // Nếu không thanh toán, giữ nguyên form để người dùng có thể thử lại
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trả về từ thanh toán — đơn vẫn chưa hoàn tất')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch dịch vụ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Thông tin đặt dịch vụ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Service summary card when a service is preselected or chosen
            if (_serviceType.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.cleaning_services, color: Colors.teal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_serviceType, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Tổng: ${_formatCurrency(_finalAmount)}đ', style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 9) ? 'SĐT không hợp lệ' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _serviceOptions.contains(_serviceType) ? _serviceType : null,
              items: _serviceOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _serviceType = v ?? ''),
              decoration: const InputDecoration(labelText: 'Loại dịch vụ'),
              hint: const Text('Chọn loại dịch vụ'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range),
                    label: Text(_selectedDate == null
                        ? 'Chọn ngày'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime == null
                        ? 'Chọn giờ'
                        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // Địa chỉ theo phân cấp: Thành phố -> Quận/Huyện -> Phường/Xã -> Số nhà
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
              items: _locations.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedCity = v;
                  _selectedDistrict = null;
                  _selectedWard = null;
                });
              },
              validator: (v) => (v == null || v.isEmpty) ? 'Chọn tỉnh/thành' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              decoration: const InputDecoration(labelText: 'Quận/Huyện'),
              items: (_selectedCity != null
                      ? _locations[_selectedCity!]!.keys.toList()
                      : <String>[])
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedDistrict = v;
                  _selectedWard = null;
                });
              },
              validator: (v) => (v == null || v.isEmpty) ? 'Chọn quận/huyện' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedWard,
              decoration: const InputDecoration(labelText: 'Phường/Xã'),
              items: (_selectedCity != null && _selectedDistrict != null
                      ? _locations[_selectedCity!]![_selectedDistrict!]!
                      : <String>[])
                  .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedWard = v),
              validator: (v) => (v == null || v.isEmpty) ? 'Chọn phường/xã' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _houseController,
              decoration: const InputDecoration(labelText: 'Số nhà / Tên đường'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập số nhà' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _couponController,
              decoration: const InputDecoration(
                labelText: 'Mã ưu đãi (ví dụ: GIAM10, GIAM20)',
                prefixIcon: Icon(Icons.card_giftcard),
              ),
            ),
            const SizedBox(height: 12),
            // Hiển thị tổng tiền cập nhật theo mã ưu đãi (nổi bật)
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('${_formatCurrency(_finalAmount)}đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Đặt lịch & Thanh toán — ${_formatCurrency(_finalAmount)}đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}


