import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login/login_page.dart';
import 'login/api_service.dart';
import 'adminfiles/admin_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deals',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: FutureBuilder<bool>(
        future: ApiService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.data == true) {
            // User is logged in, check if admin
            return FutureBuilder<bool>(
              future: ApiService.isAdmin(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                return adminSnapshot.data == true 
                    ? const AdminDashboard() 
                    : const HomeScreen();
              },
            );
          } else {
            // User is not logged in
            return Loginnnn();
          }
        },
      ),
    );
  }
}
