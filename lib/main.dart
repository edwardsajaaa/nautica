import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/constants/app_theme.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/tour_catalog/views/tour_catalog_view.dart';
import 'features/tour_catalog/viewmodels/tour_catalog_viewmodel.dart';
import 'features/booking/views/booking_view.dart';
import 'features/booking/viewmodels/booking_viewmodel.dart';
import 'features/admin_dashboard/views/admin_dashboard_view.dart';
import 'features/admin_dashboard/viewmodels/admin_dashboard_viewmodel.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TourCatalogViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
      ],
      child: const NauticaApp(),
    ),
  );
}

class NauticaApp extends StatelessWidget {
  const NauticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nautica',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

/// Gerbang autentikasi — tampilkan LoginView atau MainShell
/// berdasarkan status login.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AuthViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        if (auth.isLoggedIn) {
          return const MainShell();
        }
        return const LoginView();
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    TourCatalogView(),
    BookingView(),
    AdminDashboardView(),
  ];

  static const _navItems = [
    _NavItem(Icons.sailing, 'Destinations'),
    _NavItem(Icons.event_note, 'Booking'),
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // ── Sidebar ──
          Container(
            width: 220,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: AppTheme.divider, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.anchor,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Nautica',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nav items
                ...List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  final isSelected = _selectedIndex == index;
                  // Settings tidak memiliki halaman
                  final isClickable = index < 3;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: Material(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isClickable
                            ? () => setState(() => _selectedIndex = index)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // ── User info + Logout ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            (auth.currentUser?.fullName ?? 'A')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          auth.currentUser?.fullName ?? 'Admin',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${auth.currentUser?.username ?? 'admin'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => auth.logout(),
                            icon: const Icon(Icons.logout, size: 16),
                            label: const Text(
                              'Logout',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.danger,
                              side: BorderSide(
                                color: AppTheme.danger.withAlpha(80),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content Area ──
          Expanded(
            child: _selectedIndex < 3
                ? _pages[_selectedIndex]
                : const Center(child: Text('Settings')),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
