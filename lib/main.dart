import 'package:chatify_app/pages/login_page.dart';
import 'package:chatify_app/pages/splash_page.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:chatify_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  runApp(
    SplashPage(
      onInitializationComplete: () {
        runApp(const MyApp());
        // Additional setup can be done here if needed
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.bottomNavigationBar,
        ),
      ),
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: 'login',
      routes: {'login': (context) => LoginPage()},
    );
  }
}
