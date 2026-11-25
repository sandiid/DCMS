import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/chargers/presentation/charger_list_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/chargers', builder: (context, state) => const ChargerListScreen()),
  ],
);

class DcmsApp extends StatelessWidget {
  const DcmsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'DCMS',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.dark,
        surface: const Color(0xFF17263B),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B1220)),
      cardTheme: CardThemeData(
        color: const Color(0xFF17263B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    routerConfig: _router,
  );
}
