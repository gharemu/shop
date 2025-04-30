import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:Deals/login/user_provider.dart';
import 'package:Deals/screen/checkout_page.dart';
import 'package:Deals/login/profile_account.dart';
import 'package:Deals/screen/cashondel.dart';
import 'package:Deals/screen/onlinepayment.dart';
import 'package:Deals/login/login_page.dart';
import 'package:Deals/screen/custome_app_bar.dart';
import 'package:Deals/providers/badge_provider.dart';
// Assuming you have this

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deals',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: const Color(0xFFFF3E6C),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3E6C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Define all app routes
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/checkout': (context) => const CheckoutPage(),
        '/login/profile_account.dart': (context) => const ProfilePage(),
        '/userProfileFromCheckout':
            (context) => const ProfilePage(fromCheckout: true),
        '/cashOnDelivery': (context) => const CashOnDeliveryPage(),
        '/onlinePayment': (context) => const OnlinePaymentPage(),
        '/login': (context) => AuthScreen(), // Assuming you have this
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes or routes with parameters
        if (settings.name == '/checkout_from_profile') {
          return MaterialPageRoute(builder: (context) => const CheckoutPage());
        }
        return null;
      },
    );
  }
}
