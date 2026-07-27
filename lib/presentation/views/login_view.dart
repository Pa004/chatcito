import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'register_view.dart';
import 'usuarios_view.dart';

class LoginView extends ConsumerStatefulWidget {
  final bool delayAnimations;
  const LoginView({super.key, this.delayAnimations = false});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  late final AnimationController _animCtrl;
  late final Animation<double> _iconAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _inputAnim;
  late final Animation<double> _buttonAnim;
  late final Animation<Offset> _iconSlide;
  late final Animation<Offset> _titleSlide;
  late final Animation<Offset> _inputSlide;
  late final Animation<Offset> _buttonSlide;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconAnim = _buildAnim(0.0, 0.25);
    _titleAnim = _buildAnim(0.15, 0.40);
    _inputAnim = _buildAnim(0.30, 0.55);
    _buttonAnim = _buildAnim(0.45, 0.70);
    _iconSlide = _buildSlide(0.0, 0.25);
    _titleSlide = _buildSlide(0.15, 0.40);
    _inputSlide = _buildSlide(0.30, 0.55);
    _buttonSlide = _buildSlide(0.45, 0.70);

    if (widget.delayAnimations) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _animCtrl.forward();
      });
    } else {
      _animCtrl.forward();
    }
  }

  Animation<double> _buildAnim(double start, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _buildSlide(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Future<void> _entrar() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Ingresa correo y contraseña');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _error = 'Formato de correo invalido');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).iniciarSesion(
            email: email,
            password: password,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        AppTheme.smoothRoute(const UsuariosView()),
      );
    } catch (e) {
      setState(() {
        _error = 'Correo o contraseña incorrectos';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1E3345), AppTheme.chatBgDark],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.whatsappTeal, AppTheme.telegramBlue],
                    ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF2A3D4A), AppTheme.incomingDark],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFF5F0EA)],
                          ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _iconAnim,
                        child: SlideTransition(
                          position: _iconSlide,
                          child: _buildIcon(isDark),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _titleAnim,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: _buildTitle(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _titleAnim,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: _buildSubtitle(isDark),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _inputAnim,
                        child: SlideTransition(
                          position: _inputSlide,
                          child: _buildForm(isDark),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _buttonAnim,
                        child: SlideTransition(
                          position: _buttonSlide,
                          child: _buildButton(isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppTheme.smoothRoute(const RegisterView(delayAnimations: true)),
                          );
                        },
                        child: Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: isDark ? AppTheme.whatsappDarkTeal : AppTheme.whatsappTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? AppTheme.whatsappDarkTeal.withValues(alpha: 0.6)
              : AppTheme.whatsappTeal.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: isDark
            ? AppTheme.whatsappDarkTeal.withValues(alpha: 0.15)
            : AppTheme.whatsappTeal.withValues(alpha: 0.12),
        child: Icon(
          Icons.forum_rounded,
          size: 40,
          color: isDark ? AppTheme.whatsappDarkTeal : AppTheme.whatsappTeal,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Chatcito',
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      'Inicia sesión para continuar',
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      children: [
        TextField(
          controller: _emailCtrl,
          decoration: InputDecoration(
            hintText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: isDark
                    ? AppTheme.whatsappDarkTeal.withValues(alpha: 0.3)
                    : AppTheme.whatsappTeal.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: isDark ? AppTheme.whatsappDarkTeal : AppTheme.whatsappTeal,
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passCtrl,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: isDark
                    ? AppTheme.whatsappDarkTeal.withValues(alpha: 0.3)
                    : AppTheme.whatsappTeal.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: isDark ? AppTheme.whatsappDarkTeal : AppTheme.whatsappTeal,
                width: 2,
              ),
            ),
          ),
          obscureText: true,
          textInputAction: TextInputAction.go,
          onChanged: (_) => setState(() => _error = null),
          onSubmitted: (_) => _entrar(),
        ),
      ],
    );
  }

  Widget _buildButton(bool isDark) {
    final hasEmail = _emailCtrl.text.trim().isNotEmpty;
    final hasPass = _passCtrl.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: hasEmail && hasPass && !_isLoading ? _entrar : null,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.arrow_forward_rounded),
        label: Text(_isLoading ? 'Entrando...' : 'Entrar'),
      ),
    );
  }
}
