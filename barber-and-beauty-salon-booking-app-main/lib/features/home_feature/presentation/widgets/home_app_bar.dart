import 'dart:typed_data';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/profile_notifier.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: AppBar(
        title: ValueListenableBuilder<ProfileInfo>(
          valueListenable: profileInfoNotifier,
          builder: (context, info, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      info.location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: UserProfileImageWidget(),
        ),
        leadingWidth: 85,
        titleSpacing: 16.0,
        actions: const [],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(AppBar().preferredSize.height + 16.0);
}

/// Profile Image Widget with tap to edit
class UserProfileImageWidget extends StatelessWidget {
  const UserProfileImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: profileImageNotifier,
      builder: (context, value, _) {
        return GestureDetector(
          onTap: () async {
            // Changes automatically reflected via ValueNotifier
          },
          child: CircleAvatar(
            radius: 25,
            backgroundImage:
                value != null
                    ? MemoryImage(value)
                    : const AssetImage('assets/images/profile-image.jpg')
                        as ImageProvider,
          ),
        );
      },
    );
  }
}
