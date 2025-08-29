import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/tabs/feedback_appointment_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/assets.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/fonts.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/colors.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/dimens.dart';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_light_text.dart';
import 'package:barber_and_beauty_salon_booking_app/core/widgets/app_svg_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceList extends StatelessWidget {
  final bool showAll;
  const ServiceList({super.key, this.showAll = false});

  @override
  Widget build(BuildContext context) {
    final List<String> defaultImages = [
      Assets.images.hairStyle.path,
      Assets.images.hairCut.path,
      Assets.images.washingHair.path,
      Assets.images.womenHairStyle.path,
    ];

    return SizedBox(
      height: 230,
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('salons')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No salons available."));
          }

          final salons = snapshot.data!.docs;
          final itemCount = showAll ? salons.length : 4;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final salon = salons[index];
              final name = salon['name'] ?? 'Unknown';
              final location = salon['location'] ?? 'Unknown';
              final imageUrl = salon['imageUrl'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FeedbackAppointmentScreen(
                            shopName: name,
                            serviceName: name,
                            imagePath: imageUrl,
                            address: location,
                          ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  margin: EdgeInsets.symmetric(
                    horizontal:
                        index == 0 ? Dimens.largePadding : Dimens.padding,
                    vertical: Dimens.padding,
                  ),
                  padding: EdgeInsets.all(Dimens.padding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)],
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
                          child:
                              (imageUrl.isNotEmpty && imageUrl != "string")
                                  ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              defaultImages[index %
                                                  defaultImages.length],
                                              fit: BoxFit.cover,
                                            ),
                                  )
                                  : Image.asset(
                                    defaultImages[index % defaultImages.length],
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(fontFamily: FontFamily.aksharMedium),
                      ),
                      const SizedBox(height: 4),
                      AppLightText(location),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppLightText('486 Reviews'),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(
                                Dimens.corners,
                              ),
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
          );
        },
      ),
    );
  }
}
