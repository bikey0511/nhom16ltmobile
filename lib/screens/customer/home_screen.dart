import 'package:flutter/material.dart';
import 'history_screen.dart' show BookingHistory;
import 'account_screen.dart';
import 'service_detail_v2.dart';
import '../../booking_form.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _index;
  final _pages = [
    // Trang chủ với lưới quick actions + banner + có điều hướng
    const _HomeContent(),
    const BookingHistory(),
    // Third tab is Account — remove the unused 'Ưu đãi' placeholder
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoClean'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat hỗ trợ',
          )
        ],
      ),
      drawer: _MainDrawer(onNavigateTab: (tabIndex) {
        Navigator.of(context).pop();
        setState(() => _index = tabIndex);
      }),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đã đặt'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text('Đặt vệ sinh linh hoạt, tiết kiệm',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 18),

        // Service cards shown on home (each navigates to BookingForm preselected)
          _ServiceCard(
          title: 'Vệ sinh nhà ở',
          price: '150.000đ/giờ',
          color: const Color(0xFFE0F2F1),
          icon: Icons.home,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingForm(serviceType: 'Vệ sinh nhà ở'))),
            onLongPress: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailScreenV2(
              title: 'Vệ sinh nhà ở',
              description: 'Dọn dẹp tổng quát, theo giờ hoặc theo ngày. Bao gồm lau chùi, hút bụi, vệ sinh nhà bếp và phòng tắm.',
              price: '150.000đ/giờ',
              imageAssets: [
                'assets/images/1.PNG',
                'assets/images/2.PNG',
              ],
            ))),
        ),
        const SizedBox(height: 12),
        _ServiceCard(
          title: 'Giặt sofa - thảm',
          price: '200.000đ/m2',
          color: const Color(0xFFF3E5F5),
          icon: Icons.weekend,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailScreenV2(
            title: 'Giặt sofa - thảm',
            description: 'Sử dụng thiết bị chuyên dụng để giặt sofa và thảm, loại bỏ vết bẩn và khử khuẩn hiệu quả.',
            price: '200.000đ/m2',
            imageUrls: [
              'https://source.unsplash.com/1200x800/?sofa-cleaning',
              'https://source.unsplash.com/1200x800/?sofa',
              'https://source.unsplash.com/1200x800/?carpet-cleaning',
            ],
            imageAssets: [
              'assets/images/3.PNG',
              'assets/images/4.PNG',
            ],
          ))),
        ),
        const SizedBox(height: 12),
        _ServiceCard(
          title: 'Tổng vệ sinh',
          price: '300.000đ/phòng',
          color: const Color(0xFFFFF3E0),
          icon: Icons.build_circle,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailScreenV2(
            title: 'Tổng vệ sinh',
            description: 'Dịch vụ tổng vệ sinh sau xây dựng hoặc chuyển nhà, làm sạch sâu các khu vực khó tiếp cận.',
            price: '300.000đ/phòng',
            imageUrls: [
              'https://source.unsplash.com/1200x800/?deep-cleaning',
              'https://source.unsplash.com/1200x800/?construction-cleaning',
              'https://source.unsplash.com/1200x800/?post-construction-cleaning',
            ],
            imageAssets: [
              'assets/images/5.PNG',
              'assets/images/6.PNG',
            ],
          ))),
        ),
        const SizedBox(height: 18),

        // quick nav row at bottom for other features
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/services'),
                icon: const Icon(Icons.grid_view),
                label: const Text('Tất cả dịch vụ'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// _QuickAction removed — replaced by service cards on HomeScreen

class _ServiceCard extends StatelessWidget {
  final String title;
  final String price;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ServiceCard({required this.title, required this.price, required this.color, required this.icon, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))]),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
              // price removed per design request
            ],
          ),
        ),
      ),
    );
  }
}

// removed _PlaceholderScreen — no longer used

class AccountEntry extends StatelessWidget {
  const AccountEntry({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed('/account'),
        child: const Text('Mở trang Tài khoản'),
      ),
    );
  }
}

class _MainDrawer extends StatefulWidget {
  final void Function(int tabIndex) onNavigateTab;
  const _MainDrawer({required this.onNavigateTab});

  @override
  State<_MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<_MainDrawer> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() => _userName = user?.displayName);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('GoClean', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text(
                    _userName != null && _userName!.isNotEmpty ? 'Xin chào, $_userName!' : 'Xin chào, Khách',
                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_filled),
              title: const Text('Trang chủ'),
              onTap: () => widget.onNavigateTab(0),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Dịch vụ'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/services');
              },
            ),
            // Removed 'Đặt lịch' from drawer to reduce duplication with bottom nav
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Đã đặt'),
              onTap: () => widget.onNavigateTab(1),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chat hỗ trợ'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Tài khoản'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/account');
              },
            ),
          ],
        ),
      ),
    );
  }
}



