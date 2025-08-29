import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_scaffold.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/home_app_bar.dart';
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

  final List<Widget> _tabs = const [
    HomeTab(),
    SearchTab(),
    CalendarTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Bottom navigation items created inside build() to safely use Theme.of(context)
    final bottomBarItems = [
      _bottomBarItem(
        iconWidget: const Icon(Icons.home),
        title: 'Home',
        isSelected: _currentIndex == 0,
        context: context,
      ),
      _bottomBarItem(
        iconWidget: const Icon(Icons.search),
        title: 'Search',
        isSelected: _currentIndex == 1,
        context: context,
      ),
      _bottomBarItem(
        iconWidget: const Icon(Icons.calendar_today),
        title: 'Calendar',
        isSelected: _currentIndex == 2,
        context: context,
      ),
      _bottomBarItem(
        iconWidget: const Icon(Icons.person),
        title: 'Profile',
        isSelected: _currentIndex == 3,
        context: context,
      ),
    ];

    return AppScaffold(
      body: _tabs[_currentIndex],
      appBar: _buildAppBar(),
      padding: EdgeInsets.zero,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: bottomBarItems,
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_currentIndex == 0) {
      return HomeAppBar();
    } else if (_currentIndex == 2) {
      return AppBar(title: const Text('Calendar'));
    } else {
      return null;
    }
  }

  SalomonBottomBarItem _bottomBarItem({
    required Widget? iconWidget,
    required String title,
    required bool isSelected,
    required BuildContext context,
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
      selectedColor: const Color.fromARGB(255, 60, 200, 216),
    );
  }
}
