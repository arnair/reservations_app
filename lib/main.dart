import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reservations_app/app_routes.dart';
import 'package:reservations_app/features/authentication/data/firebase_options.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
      onUnknownRoute: AppRoutes.onUnknownRoute,
      title: 'Reservations App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ));
  }
}
