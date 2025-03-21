import 'package:flutter/material.dart';

class AppPageTransition extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;

  AppPageTransition({required this.page, required this.settings})
      : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = animation.drive(
              Tween(begin: 0.5, end: 1.0).chain(
                CurveTween(curve: curve),
              ),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 300),
        );
}

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return AppPageTransition(
      settings: settings,
      page: _getPageForRouteName(settings),
    );
  }

  static Widget _getPageForRouteName(RouteSettings settings) {
    // Add your route cases here
    switch (settings.name) {
      // case '/login':
      //   return LoginPage();
      default:
        return Scaffold(
          body: Center(
            child: Text('Route not found: ${settings.name}'),
          ),
        );
    }
  }
}
