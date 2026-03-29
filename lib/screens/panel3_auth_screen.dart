import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/app_assets.dart';
import '../core/constants/app_text_styles.dart';
import 'panel4_are_you_ready_screen.dart';

/// Panel 3 — Login / Sign-Up Screen
///
/// Landscape layout: background art fills the screen, a centered
/// wooden-board card holds the auth form (inspired by the reference).
class Panel3AuthScreen extends StatefulWidget {
  const Panel3AuthScreen({super.key});

  @override
  State<Panel3AuthScreen> createState() => _Panel3AuthScreenState();
}

class _Panel3AuthScreenState extends State<Panel3AuthScreen>
    with SingleTickerProviderStateMixin {
  // 0 = Sign Up, 1 = Log In
  int _tabIndex = 0;

  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _boardEnter;
  late final Animation<double> _boardScale;
  late final Animation<double> _boardFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _boardEnter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _boardScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _boardEnter, curve: Curves.easeOutBack));
    _boardFade = CurvedAnimation(parent: _boardEnter, curve: Curves.easeIn);
    _boardEnter.forward();
  }

  @override
  void dispose() {
    _boardEnter.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    _boardEnter.forward(from: 0);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    // Simulate brief auth delay then proceed
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Panel4AreYouReadyScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  // ── Dark-fantasy palette ───────────────────────────────────────
  static const Color _woodDark = Color(0xFF0D0520);   // darkest purple
  static const Color _woodMid = Color(0xFF1A0A2E);    // primary dark purple
  static const Color _woodLight = Color(0xFF2D1550);  // lighter purple
  static const Color _woodBorder = Color(0xFFD4A853); // gold accent
  static const Color _fieldText = Color(0xFFF5EDD8);  // parchment text
  static const Color _greenBtn = Color(0xFFD4A853);   // gold accent
  static const Color _greenBtnDark = Color(0xFFA07030); // darker gold

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ────────────────────────────────────────────────────
          Image.asset(
            AppAssets.authBackground,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF0D0828)),
          ),

          // ── Deep vignette overlay ──────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: const [Color(0x55000000), Color(0xBB000000)],
              ),
            ),
            child: const SizedBox.expand(),
          ),

          // ── Animated board ─────────────────────────────────────────────────
          Center(
            child: ScaleTransition(
              scale: _boardScale,
              child: FadeTransition(
                opacity: _boardFade,
                child: _buildBoard(size),
              ),
            ),
          ),

          // ── Back arrow ────────────────────────────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _woodDark.withAlpha(200),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _woodBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(Size size) {
    // Board occupies ~70% width, ~85% height in landscape
    final boardW = (size.width * 0.68).clamp(340.0, 600.0);
    final boardH = (size.height * 0.88).clamp(240.0, 400.0);

    return Container(
      width: boardW,
      height: boardH,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_woodLight, _woodMid, _woodDark],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _woodBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A853).withAlpha(40),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(140),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Wood grain overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                AppAssets.authBigBoard,
                fit: BoxFit.cover,
                width: boardW,
                height: boardH,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          // Close (X) button — top right
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFCC2222)],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAssets.authButtons,
                  width: 20,
                  height: 20,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),

          // Form content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Tab row ──────────────────────────────────────────────
                _buildTabRow(),
                const SizedBox(height: 10),
                // ── Form ─────────────────────────────────────────────────
                Expanded(child: _buildForm()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TabButton(
          label: 'SIGN UP',
          isActive: _tabIndex == 0,
          asset: AppAssets.authLoginSignup,
          onTap: () => _switchTab(0),
        ),
        const SizedBox(width: 12),
        _TabButton(
          label: 'LOG IN',
          isActive: _tabIndex == 1,
          asset: AppAssets.authLoginSignup,
          onTap: () => _switchTab(1),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sign-up-only row
          if (_tabIndex == 0) ...[
            Row(
              children: [
                Expanded(
                  child: _WoodField(
                    controller: _firstNameCtrl,
                    hint: 'FIRST NAME',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WoodField(
                    controller: _lastNameCtrl,
                    hint: 'LAST NAME',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          _WoodField(
            controller: _emailCtrl,
            hint: 'EMAIL',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 8),

          _WoodField(
            controller: _passwordCtrl,
            hint: 'PASSWORD',
            obscureText: _obscurePassword,
            suffix: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 16,
                color: _fieldText.withAlpha(160),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
          ),

          if (_tabIndex == 0) ...[
            const SizedBox(height: 6),
            Text(
              'BY CLICKING BELOW TO SIGN UP YOU ARE AGREEING\nTO OUR TERMS OF SERVICE AND PRIVACY POLICY',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withAlpha(180),
                fontSize: 8,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.4,
              ),
            ),
          ],

          const Spacer(),

          // ── Submit button ─────────────────────────────────────────────
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final label = _tabIndex == 0 ? 'CREATE MY ACCOUNT' : 'LOG IN';
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_greenBtn.withAlpha(220), _greenBtn, _greenBtnDark],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _greenBtn.withAlpha(180), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _greenBtn.withAlpha(80),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.authCreateAccount,
                      width: 18,
                      height: 18,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 13,
                        letterSpacing: 1.5,
                        color: const Color(0xFF1A0A2E),
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Tab button ───────────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final String asset;
  final VoidCallback onTap;

  static const Color _activeBg = Color(0xFF3A1A6A);
  static const Color _inactiveBg = Color(0xFF1A0A2E);
  static const Color _goldBorder = Color(0xFFD4A853);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _activeBg : _inactiveBg.withAlpha(200),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? _goldBorder : _goldBorder.withAlpha(60),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _goldBorder.withAlpha(40),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              width: 14,
              height: 14,
              color: isActive ? _goldBorder : _goldBorder.withAlpha(100),
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? _goldBorder : _goldBorder.withAlpha(140),
                letterSpacing: 1.5,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wood-styled text field ───────────────────────────────────────────────────

class _WoodField extends StatelessWidget {
  const _WoodField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  static const Color _fieldBg = Color(0xFF14082A);
  static const Color _fieldText = Color(0xFFF5EDD8);
  static const Color _fieldBorder = Color(0xFFD4A853);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.labelMedium.copyWith(
        color: _fieldText,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.labelSmall.copyWith(
          color: _fieldText.withAlpha(130),
          letterSpacing: 1.5,
          fontSize: 10,
        ),
        filled: true,
        fillColor: _fieldBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _fieldBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: _fieldBorder.withAlpha(80), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _fieldBorder, width: 2),
        ),
        errorStyle: AppTextStyles.labelSmall.copyWith(
          color: Colors.red.shade200,
          fontSize: 8,
        ),
        suffixIcon: suffix,
      ),
    );
  }
}
