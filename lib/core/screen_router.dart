import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/UI/email_verify_screen.dart';
import '../auth/UI/login_screen.dart';
import '../auth/model/auth_status.dart';
import '../auth/providers/auth_provider.dart';
import '../calorie_tracking/UI/home_ui.dart';

class ScreenRouter extends StatefulWidget {
  const ScreenRouter({super.key});

  @override
  State<ScreenRouter> createState() => _ScreenRouterState();
}

class _ScreenRouterState extends State<ScreenRouter> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.authenticating:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.emailConfirmation:
        return const EmailVerifyScreen();
      case AuthStatus.loggedIn:
        return HomeScreen();
      default:
        return const LoginScreen();
    }
  }
}
