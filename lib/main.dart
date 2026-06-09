import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/constants/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/database/database_helper.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/ticketing/views/dashboard_view.dart';
import 'features/ticketing/viewmodels/ticketing_viewmodel.dart';
import 'features/manifest/views/manifest_report_view.dart';
import 'features/manifest/viewmodels/manifest_viewmodel.dart';

import 'features/kiosk/viewmodels/kiosk_viewmodel.dart';
import 'features/kiosk/views/kiosk_welcome_view.dart';
import 'features/management/viewmodels/management_viewmodel.dart';
import 'features/management/views/ship_management_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TicketingViewModel()),
        ChangeNotifierProvider(create: (_) => ManifestViewModel()),

        ChangeNotifierProvider(create: (_) => KioskViewModel()),
        ChangeNotifierProvider(create: (_) => ManagementViewModel()),
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
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const KioskWelcomeView(),
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
    DashboardView(),
    ManifestReportView(),
    ShipManagementView(),
  ];

  static const _navItems = [
    _NavItem(Icons.dashboard, 'Beranda'),
    _NavItem(Icons.assignment, 'Laporan Manifest'),
    _NavItem(Icons.settings, 'Manajemen Kapal'),
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
                      Image.asset(
                        'assets/images/logo.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
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
                  // Settings sekarang mengarah ke Manajemen Kapal
                  final isClickable = index < 3;

                  // Tambahkan badge untuk Laporan Manifest (Index 1)
                  Widget iconWidget = Icon(
                    item.icon,
                    size: 20,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  );

                  if (index == 1) {
                    // Dapatkan total tiket terjual untuk badge notifikasi
                    final vm = context.watch<TicketingViewModel>();
                    final totalSold = vm.schedules.fold<int>(0, (prev, s) => prev + (s['sold_seats'] as int));
                    
                    if (totalSold > 0) {
                      iconWidget = Badge(
                        label: Text(totalSold.toString()),
                        backgroundColor: AppTheme.danger,
                        child: iconWidget,
                      );
                    }
                  }

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
                              iconWidget,
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
