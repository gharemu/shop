import 'package:flutter/material.dart';
import 'package:Deals/home_screen.dart';
//import 'package:Deals/signin_page.dart';
//import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:  FirebaseOptions(
    apiKey: 'AIzaSyAjNsmdvVw6y_249rbU4kaQHdh_YgMlmPc',
    appId: '1:743244419249:android:ee16c3e414757c5f03d290',
    messagingSenderId: '743244419249',
    projectId: 'login-fe73f',
    databaseURL: 'https://login-fe73f-default-rtdb.firebaseio.com',
    storageBucket: 'login-fe73f.firebasestorage.app',
  ));
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
      home: HomeScreen(),
    );
  }
}
