import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tms_useweb_app/routes/routes.dart';
import 'provider/filter_provider.dart';
import 'provider/getReport_provider.dart';
import 'provider/raisedata_provider.dart';
import 'view/LoginPage/login_page.dart';

void main() async {
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyA6-g-Dbb6c5B_hFhGvANlznlixlPgKx6k",
          authDomain: "tmsapp-53ebc.firebaseapp.com",
          projectId: "tmsapp-53ebc",
          storageBucket: "tmsapp-53ebc.appspot.com",
          messagingSenderId: "190167031121",
          appId: "1:190167031121:android:f2cd05b74edb7dd 581c770",
          measurementId: "G-88TQTEM40C"))  ;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // ChangeNotifierProvider(create: (context) => PiechartProvider()),
          // ChangeNotifierProvider(create: (context) => NotificationProvider()),
          ChangeNotifierProvider(create: (context) => FilterProvider()),
          ChangeNotifierProvider(create: (context) => RaiseDataProvider()),
          ChangeNotifierProvider(create: (context) => ReportProvider()),
        ],
        child: GetMaterialApp(
          getPages: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
          title: 'TMS_USER_APP',
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
    //     HomePage(
    //   userId: 'KM1737',
    // );
  }
}
