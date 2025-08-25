import 'package:flutter/material.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/widgets/service_list.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/dimens.dart';

class NearbySalonScreen extends StatelessWidget {
  const NearbySalonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Beauty Salons')),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.largePadding),
        child: const ServiceList(), // Use the same ServiceList widget
      ),
    );
  }
}
