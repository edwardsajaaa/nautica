import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'kiosk_schedule_view.dart';

class KioskWelcomeView extends StatefulWidget {
  const KioskWelcomeView({super.key});

  @override
  State<KioskWelcomeView> createState() => _KioskWelcomeViewState();
}

class _KioskWelcomeViewState extends State<KioskWelcomeView> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    // Animasi mengambang (naik-turun) lambat untuk logo
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Animasi detak jantung (pulse) untuk tombol CTA
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Animasi putaran lambat untuk elemen background
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Biru laut gelap modern
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const KioskScheduleView(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Stack(
          children: [
            // --- Latar Belakang Animasi Modern ---
            // Gradient Base
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF020c1b), Color(0xFF112240), Color(0xFF233554)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            
            // Elemen Geometris Abstrak Mengambang
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100,
                      left: -100,
                      child: Transform.rotate(
                        angle: _bgController.value * 2 * math.pi,
                        child: Container(
                          width: 600,
                          height: 600,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.blue.withAlpha(20), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -200,
                      right: -100,
                      child: Transform.rotate(
                        angle: -_bgController.value * 2 * math.pi,
                        child: Container(
                          width: 800,
                          height: 800,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.teal.withAlpha(20), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // --- Konten Utama ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Animasi Float
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -20 * _floatController.value),
                          child: child,
                        );
                      },
                      child: Hero(
                        tag: 'nautica_logo',
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 220,
                          height: 220,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.directions_boat,
                            size: 180,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Typografi Modern
                    const Text(
                      'NAUTICA',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 16,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Text(
                        'Self-Service Ticketing Kiosk',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Call To Action Berdenyut (Pulse)
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFE2E8F0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: 48, color: Colors.blue.shade800),
                            const SizedBox(width: 24),
                            Text(
                              'Sentuh Layar Untuk Memulai',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
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
    );
  }
}
