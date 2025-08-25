import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/tabs/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/assets.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/fonts.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/colors.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/dimens.dart';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_light_text.dart';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_svg_viewer.dart';

class ServiceList extends StatelessWidget {
  final bool showAll;

  const ServiceList({super.key, this.showAll = false});

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      Assets.images.hairStyle.path,
      Assets.images.hairCut.path,
      Assets.images.washingHair.path,
      Assets.images.womenHairStyle.path,
    ];

    final List<String> titles = [
      "MODERN SALON",
      "SK BARBER SHOP",
      "SIMON BARBERS",
      "SMART HAIRSTYLES",
    ];

    final List<String> addresses = [
      " 939 8th Ave, Thiruvallur",
      " 56th St, Perambur",
      " 939 8th Ave, Arakkonam",
      "56th St, Guindy",
    ];

    final int itemCount = showAll ? titles.length : 4;

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => FeedbackScreen(
                        shopName: titles[index],
                        serviceName: titles[index], // dynamic service name
                        imagePath: images[index],
                        address: addresses[index],
                      ),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: EdgeInsets.symmetric(
                horizontal: index == 0 ? Dimens.largePadding : Dimens.padding,
                vertical: Dimens.padding,
              ),
              padding: EdgeInsets.all(Dimens.padding),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
                borderRadius: BorderRadius.circular(Dimens.corners),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 114,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.corners),
                      child: Image.asset(images[index], fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    titles[index],
                    style: TextStyle(fontFamily: FontFamily.aksharMedium),
                  ),
                  const SizedBox(height: 4),
                  AppLightText(addresses[index]),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppLightText('486 Reviews'),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(Dimens.corners),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: AppSvgViewer(
                          Assets.icons.arrowRight,
                          color: AppColors.whiteColor,
                          width: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
