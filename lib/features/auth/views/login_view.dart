import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Halaman Login & Register — desain terinspirasi dari
/// BOSS0exe/Sign-in-and-Sign-up-page (sliding toggle panel).
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _loginUsernameCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _regUsernameCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regFullNameCtrl = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();

  bool _obscureLoginPw = true;
  bool _obscureRegPw = true;

  // Animation for panel slide
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;
  bool _isSignUp = false; // false = sign-in, true = sign-up

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
    _loginUsernameCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regFullNameCtrl.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _isSignUp = !_isSignUp);
    if (_isSignUp) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    await vm.login(
      _loginUsernameCtrl.text.trim(),
      _loginPasswordCtrl.text.trim(),
    );
  }

  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final success = await vm.register(
      _regUsernameCtrl.text.trim(),
      _regPasswordCtrl.text.trim(),
      _regFullNameCtrl.text.trim(),
    );
    if (success && mounted) {
      _regUsernameCtrl.clear();
      _regPasswordCtrl.clear();
      _regFullNameCtrl.clear();
      _togglePanel(); // switch back to sign-in
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
              // ── Sign In Form (left half) ──
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
                        child: child,
                      ),
                    ),
                  );
                },
                child: _buildSignInForm(),
              ),

              // ── Sign Up Form (slides in from left) ──
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
                        ignoring: !_isSignUp,
                        child: Opacity(
                          opacity: _slideAnim.value,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: _buildSignUpForm(),
              ),

              // ── Toggle Panel (right half, slides left when sign-up) ──
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
                                title: 'Welcome To\nNautica!',
                                subtitle:
                                    'Sign in with your account\nto access the dashboard',
                                buttonText: 'Sign Up',
                                icon: Icons.anchor,
                              ),
                              secondChild: _buildTogglePanelContent(
                                title: 'Hello,\nWorld!',
                                subtitle:
                                    'Create your account\nand join us today',
                                buttonText: 'Sign In',
                                icon: Icons.sailing,
                              ),
                              crossFadeState: _isSignUp
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

  // ── Sign In Form ──
  Widget _buildSignInForm() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Form(
            key: _loginFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign In',
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

                // Error
                if (vm.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
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

                _InputField(
                  controller: _loginUsernameCtrl,
                  hint: 'Username',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Username wajib diisi'
                      : null,
                  onSubmit: (_) => _handleLogin(),
                ),
                const SizedBox(height: 10),
                _InputField(
                  controller: _loginPasswordCtrl,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscure: _obscureLoginPw,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureLoginPw
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppTheme.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _obscureLoginPw = !_obscureLoginPw),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Password wajib diisi'
                      : null,
                  onSubmit: (_) => _handleLogin(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: vm.isLoading ? null : _handleLogin,
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
                Text(
                  'Default: admin / admin123',
                  style: TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Sign Up Form ──
  Widget _buildSignUpForm() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 44),
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
                  'Buat akun baru',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                if (vm.errorMessage != null && _isSignUp) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
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

                _InputField(
                  controller: _regFullNameCtrl,
                  hint: 'Nama Lengkap',
                  icon: Icons.badge_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
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
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Toggle Panel Content ──
  Widget _buildTogglePanelContent({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.white70),
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
