import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/features/auth/bloc/auth_bloc.dart';
import 'package:lacquer/features/auth/bloc/auth_state.dart';
import 'package:lacquer/presentation/pages/auth/forgot_password_page.dart';
import 'package:lacquer/presentation/pages/auth/login_page.dart';
import 'package:lacquer/presentation/pages/auth/verify_page.dart';
import 'package:lacquer/presentation/pages/camera/camera_page.dart';
import 'package:lacquer/presentation/pages/camera/about_screen.dart';

import 'package:lacquer/presentation/pages/mainscreen.dart';
import 'package:flutter/widgets.dart';

class RouteName {
  static const String home = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verify = '/verify';
  static const String register = '/register';
  static const String camera = '/camera';
  static const String about = '/about';

  static const publicRoutes = [login, forgotPassword, verify, register];
}

GoRoute noTransitionRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    path: path,
    pageBuilder:
        (context, state) => NoTransitionPage(child: builder(context, state)),
  );
}

final router = GoRouter(
  redirect: (context, state) {
    if (RouteName.publicRoutes.contains(state.fullPath)) {
      return null;
    }
    if (context.read<AuthBloc>().state is AuthAuthenticatedSuccess) {
      return null;
    }
    return RouteName.login;
  },
  routes: [
    noTransitionRoute(
      path: RouteName.home,
      builder: (context, state) => MainScreen(),
    ),
    noTransitionRoute(
      path: RouteName.login,
      builder: (context, state) => LoginPage(),
    ),
    noTransitionRoute(
      path: RouteName.forgotPassword,
      builder: (context, state) => ForgotPasswordPage(),
    ),
    noTransitionRoute(
      path: RouteName.verify,
      builder: (context, state) => VerifyEmailPage(),
    ),
    noTransitionRoute(
      path: RouteName.camera,
      builder: (context, state) => const CameraPage(),
    ),
    noTransitionRoute(
      path: RouteName.about,
      builder: (context, state) {
        final imagePath = state.extra as String;
        return AboutScreen(imagePath: imagePath);
      },
    ),
  ],
);
