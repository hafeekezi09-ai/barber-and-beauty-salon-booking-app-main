import 'package:flutter/material.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/tabs/nearby_salon_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/tabs/popular_services_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/special_offer_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/category_screen.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/category_list.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/service_list.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/service_title_widget.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/assets.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/dimens.dart';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_search_bar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search bar
          AppSearchBar(),

          // Clickable Banner
          GestureDetector(
            onTap: () {
              // Navigate to Special Offers screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpecialOffersScreen()),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                top: Dimens.padding,
                left: Dimens.largePadding,
                right: Dimens.largePadding,
              ),
              child: Assets.images.banner.image(fit: BoxFit.fitWidth),
            ),
          ),
          const SizedBox(height: Dimens.padding),

          // Categories
          ServiceTitleWidget(
            title: 'Service categories',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryScreen()),
              );
            },
          ),
          CategoryList(),
          const SizedBox(height: Dimens.padding),

          // Special Offers
          ServiceTitleWidget(
            title: 'Special offers',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpecialOffersScreen()),
              );
            },
          ),
          const ServiceList(),
          const SizedBox(height: Dimens.padding),

          // Nearby Salons
          ServiceTitleWidget(
            title: 'Nearby beauty salon',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NearbySalonScreen()),
              );
            },
          ),
          const ServiceList(),
          const SizedBox(height: Dimens.padding),

          // Popular Services
          ServiceTitleWidget(
            title: 'Popular services',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PopularServicesScreen(),
                ),
              );
            },
          ),
          const ServiceList(showAll: true), // small preview on home tab
          const SizedBox(height: Dimens.largePadding),
        ],
      ),
    );
  }
}
