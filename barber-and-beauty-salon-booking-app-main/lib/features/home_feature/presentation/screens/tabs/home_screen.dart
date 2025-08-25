import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_scaffold.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/home_app_bar.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/admin_dashboard.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/calendar_tab.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/home_tab.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/profile_tab.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/tabs/search_tab.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  List<Widget> _tabs = [];
  List<SalomonBottomBarItem> _bottomBarItems = [];
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetupTabs();
  }

  Future<void> _loadRoleAndSetupTabs() async {
    final role = await storage.read(key: 'role') ?? '';
    final tabs = [
      const HomeTab(),
      const SearchTab(),
      const CalendarTab(),
      const ProfileTab(),
    ];
    final bottomItems = [
      bottomBarItem(
        iconWidget: const Icon(Icons.home),
        title: 'Home',
        isSelected: _currentIndex == 0,
      ),
      bottomBarItem(
        iconWidget: const Icon(Icons.search),
        title: 'Search',
        isSelected: _currentIndex == 1,
      ),
      bottomBarItem(
        iconWidget: const Icon(Icons.calendar_today),
        title: 'Calendar',
        isSelected: _currentIndex == 2,
      ),
      bottomBarItem(
        iconWidget: const Icon(Icons.person),
        title: 'Profile',
        isSelected: _currentIndex == 3,
      ),
    ];

    // ✅ FIXED: Don't cast to StatefulWidget
    if (role == 'SuperAdmin') {
      tabs.add(
        AdminDashboardScreen(role: role) as StatefulWidget,
      ); // <-- this is the fix
      bottomItems.add(
        bottomBarItem(
          iconWidget: const Icon(Icons.admin_panel_settings, size: 20),
          title: 'Admin',
          isSelected: _currentIndex == tabs.length - 1,
        ),
      );
    }

    setState(() {
      _role = role;
      _tabs = tabs;
      _bottomBarItems = bottomItems;

      if (_currentIndex >= _tabs.length) _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body:
          _tabs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _tabs[_currentIndex],
      appBar: _buildAppBar(),
      padding: EdgeInsets.zero,
      bottomNavigationBar:
          _bottomBarItems.isEmpty
              ? null
              : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: SalomonBottomBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: _bottomBarItems,
                ),
              ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_currentIndex == 0) {
      return HomeAppBar();
    } else if (_currentIndex == 2) {
      return AppBar(title: const Text('Calendar'));
    } else if (_currentIndex == 4 && _role == 'SuperAdmin') {
      return AppBar(title: const Text('Admin Dashboard'));
    } else {
      return null;
    }
  }

  SalomonBottomBarItem bottomBarItem({
    Widget? iconWidget,
    required String title,
    required bool isSelected,
  }) {
    return SalomonBottomBarItem(
      icon: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Center(child: iconWidget),
      ),
      title: Text(title),
      selectedColor: Colors.deepOrange,
    );
  }
}
