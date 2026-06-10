import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../kiosk/views/kiosk_welcome_view.dart';

/// Halaman Login & Register — desain terinspirasi dari
/// BOSS0exe/Sign-in-and-Sign-up-page (sliding toggle panel).
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  // Controllers for Admin
  final _adminUsernameCtrl = TextEditingController();
  final _adminPasswordCtrl = TextEditingController();
  final _adminLoginFormKey = GlobalKey<FormState>();

  // Controllers for Customer
  final _customerUsernameCtrl = TextEditingController();
  final _customerPasswordCtrl = TextEditingController();
  final _customerLoginFormKey = GlobalKey<FormState>();

  // Controllers for Register
  final _regUsernameCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regFullNameCtrl = TextEditingController();
  final _regLocationCtrl = TextEditingController();
  final _regFormKey = GlobalKey<FormState>();

  bool _obscureAdminPw = true;
  bool _obscureCustomerPw = true;
  bool _obscureRegPw = true;

  // Animation for panel slide
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;
  bool _isAdminMode = false; // false = customer (white left), true = admin (white right)
  bool _isCustomerRegister = false; // toggles internal form on customer side

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _adminUsernameCtrl.dispose();
    _adminPasswordCtrl.dispose();
    _customerUsernameCtrl.dispose();
    _customerPasswordCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regFullNameCtrl.dispose();
    _regLocationCtrl.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isAdminMode = !_isAdminMode;
      if (_isAdminMode) {
        _isCustomerRegister = false; // reset customer form state
      }
    });
    if (_isAdminMode) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  Future<void> _handleAdminLogin() async {
    if (!_adminLoginFormKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    await vm.login(
      _adminUsernameCtrl.text.trim(),
      _adminPasswordCtrl.text.trim(),
    );
  }

  Future<void> _handleCustomerLogin() async {
    if (!_customerLoginFormKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    await vm.login(
      _customerUsernameCtrl.text.trim(),
      _customerPasswordCtrl.text.trim(),
    );
  }

  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final success = await vm.register(
      _regUsernameCtrl.text.trim(),
      _regPasswordCtrl.text.trim(),
      _regFullNameCtrl.text.trim(),
      location: _regLocationCtrl.text.trim(),
    );
    if (success && mounted) {
      _regUsernameCtrl.clear();
      _regPasswordCtrl.clear();
      _regFullNameCtrl.clear();
      _regLocationCtrl.clear();
      setState(() => _isCustomerRegister = false); // switch back to customer sign-in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final halfW = constraints.maxWidth / 2;

          return Stack(
            children: [
              // ── Customer Form (left half) ──
              AnimatedBuilder(
                animation: _slideAnim,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: halfW,
                    child: Transform.translate(
                      offset: Offset(_slideAnim.value * halfW, 0),
                      child: Opacity(
                        opacity: 1.0 - _slideAnim.value * 0.3,
                        child: IgnorePointer(
                          ignoring: _isAdminMode,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: _buildCustomerForm(),
              ),

              // ── Admin Form (slides in from left to right) ──
              AnimatedBuilder(
                animation: _slideAnim,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: halfW,
                    child: Transform.translate(
                      offset: Offset(_slideAnim.value * halfW, 0),
                      child: IgnorePointer(
                        ignoring: !_isAdminMode,
                        child: Opacity(
                          opacity: _slideAnim.value,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: _buildAdminForm(),
              ),

              // ── Toggle Panel (right half, slides left when admin mode) ──
              AnimatedBuilder(
                animation: _slideAnim,
                builder: (context, _) {
                  return Positioned(
                    left: halfW - (_slideAnim.value * halfW),
                    top: 0,
                    bottom: 0,
                    width: halfW,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7C4DFF),
                            Color(0xFF6C63FF),
                            Color(0xFF5A52D5),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            top: -60,
                            right: -60,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(18),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -70,
                            left: -40,
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(12),
                              ),
                            ),
                          ),
                          Positioned(
                            top: constraints.maxHeight * 0.4,
                            right: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(8),
                              ),
                            ),
                          ),

                          // Toggle content
                          Center(
                            child: AnimatedCrossFade(
                              firstChild: _buildTogglePanelContent(
                                title: 'Admin\nPortal',
                                subtitle:
                                    'Are you an administrator?\nManage system and bookings',
                                buttonText: 'Admin Login',
                              ),
                              secondChild: _buildTogglePanelContent(
                                title: 'Customer\nPortal',
                                subtitle:
                                    'Are you a customer?\nLogin to book tickets',
                                buttonText: 'Customer Login',
                              ),
                              crossFadeState: _isAdminMode
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 400),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerForm() {
    return AnimatedCrossFade(
      firstChild: _buildCustomerSignInForm(),
      secondChild: _buildSignUpForm(),
      crossFadeState: _isCustomerRegister
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              key: bottomKey,
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: bottomChild,
            ),
            Positioned(
              key: topKey,
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: topChild,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomerSignInForm() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: SingleChildScrollView(
            child: Form(
              key: _customerLoginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Customer Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk ke akun Anda',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (vm.errorMessage != null && !_isAdminMode && !_isCustomerRegister) ...[
                    _buildErrorBox(vm.errorMessage!),
                  ],

                  _InputField(
                    controller: _customerUsernameCtrl,
                    hint: 'Username',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Username wajib diisi'
                        : null,
                    onSubmit: (_) => _handleCustomerLogin(),
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _customerPasswordCtrl,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _obscureCustomerPw,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCustomerPw
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppTheme.textHint,
                      ),
                      onPressed: () => setState(
                          () => _obscureCustomerPw = !_obscureCustomerPw),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Password wajib diisi'
                        : null,
                    onSubmit: (_) => _handleCustomerLogin(),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: vm.isLoading ? null : _handleCustomerLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isCustomerRegister = true),
                    child: const Text(
                      'Belum punya akun? Buat akun di sini',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpForm() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: SingleChildScrollView(
            child: Form(
              key: _regFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buat akun customer baru',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (vm.errorMessage != null && !_isAdminMode && _isCustomerRegister) ...[
                    _buildErrorBox(vm.errorMessage!),
                  ],

                  _InputField(
                    controller: _regFullNameCtrl,
                    hint: 'Nama Loket',
                    icon: Icons.storefront_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama loket wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _regUsernameCtrl,
                    hint: 'Username',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Username wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _regLocationCtrl,
                    hint: 'Lokasi Dermaga (opsional)',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _regPasswordCtrl,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _obscureRegPw,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegPw
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppTheme.textHint,
                      ),
                      onPressed: () =>
                          setState(() => _obscureRegPw = !_obscureRegPw),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (v.trim().length < 4) return 'Minimal 4 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: vm.isLoading ? null : _handleRegister,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isCustomerRegister = false),
                    child: const Text(
                      'Sudah punya akun? Sign In',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminForm() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: SingleChildScrollView(
            child: Form(
              key: _adminLoginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Admin Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk sebagai administrator',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (vm.errorMessage != null && _isAdminMode) ...[
                    _buildErrorBox(vm.errorMessage!),
                  ],

                  _InputField(
                    controller: _adminUsernameCtrl,
                    hint: 'Username',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Username wajib diisi'
                        : null,
                    onSubmit: (_) => _handleAdminLogin(),
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _adminPasswordCtrl,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _obscureAdminPw,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureAdminPw
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppTheme.textHint,
                      ),
                      onPressed: () => setState(
                          () => _obscureAdminPw = !_obscureAdminPw),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Password wajib diisi'
                        : null,
                    onSubmit: (_) => _handleAdminLogin(),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: vm.isLoading ? null : _handleAdminLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorBox(String message) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.danger.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Toggle Panel Content ──
  Widget _buildTogglePanelContent({
    required String title,
    required String subtitle,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: 120, height: 120),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(200),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: _togglePanel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(
                horizontal: 44,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ── Reusable input field (styled like the reference) ──
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmit;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      validator: validator,
      onFieldSubmitted: onSubmit,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppTheme.textHint,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textHint),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
      ),
    );
  }
}
