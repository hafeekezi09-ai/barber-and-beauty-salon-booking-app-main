import 'package:barber_and_beauty_salon_booking_app/core/gen/assets.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/dimens.dart';
import 'package:flutter/material.dart';

class UserProfileImageWidget extends StatelessWidget {
  const UserProfileImageWidget({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      child: SizedBox(
        width: width ?? 50.0,
        height: height ?? 50.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            Assets.images.profileImage.path,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
