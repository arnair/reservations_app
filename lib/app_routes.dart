import 'package:flutter/material.dart';
import 'package:reservations_app/features/authentication/presentation/login_screen.dart';
import 'package:reservations_app/features/authentication/presentation/signup_screen.dart';
import 'package:reservations_app/features/authentication/presentation/auth_wrapper.dart';
import 'package:reservations_app/features/home/presentation/home_screen.dart';
import 'package:reservations_app/features/reservations/presentation/make_reservations_screen.dart';
import 'package:reservations_app/features/reservations/presentation/delete_reservations_screen.dart';

class AppRoutes {
  // Route names as constants
  static const String initial = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String makeReservations = '/make-reservations';
  static const String deleteReservations = '/delete-reservations';

  // Route definitions
  static Map<String, WidgetBuilder> get routes {
    return {
      initial: (_) => const AuthWrapper(),
      login: (_) => const LoginScreen(),
      signup: (_) => const SignupScreen(),
      home: (_) => const HomeScreen(),
      makeReservations: (_) => const MakeReservationsScreen(),
      deleteReservations: (_) => const DeleteReservationsScreen(),
    };
  }

  // Handle unknown routes
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }

  // Navigation methods
  static void navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndRemove(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false,
        arguments: arguments);
  }

  static void navigateToAndReplace(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
