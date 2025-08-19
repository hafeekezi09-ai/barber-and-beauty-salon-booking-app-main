import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:barber_and_beauty_salon_booking_app/core/gen/fonts.gen.dart';
import 'package:barber_and_beauty_salon_booking_app/core/theme/colors.dart';
import 'package:barber_and_beauty_salon_booking_app/features/home_feature/presentation/screens/tabs/admin_login_screen.dart';
import 'firebase_options.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber and Beauty Salon Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.light,
        ),
        fontFamily: FontFamily.aksharLight,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.whiteColor,
          titleTextStyle: TextStyle(
            fontFamily: FontFamily.aksharBold,
            color: AppColors.blackColor,
            fontSize: 18,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(elevation: 0),
        scaffoldBackgroundColor: AppColors.whiteColor,
      ),
      home: const AdminLoginScreen(),
    );
  }
}
