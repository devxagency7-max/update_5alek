import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/services/remote_config_helper.dart';

import 'package:motareb/core/extensions/loc_extension.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/privacy_policy_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/error_handler.dart';
import '../widgets/user_type_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await context.read<AuthProvider>().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: context.loc.loginSuccess,
          isError: false,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: ErrorHandler.getMessage(e),
          isError: true,
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    // Show Selection Dialog first
    final bool? isOwner = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const UserTypeDialog(),
    );

    if (isOwner == null) return; // User cancelled

    try {
      await context.read<AuthProvider>().signInWithGoogle(isOwner: isOwner);
      if (mounted && context.read<AuthProvider>().isAuthenticated) {
        CustomSnackBar.show(
          context: context,
          message: context.loc.googleLoginSuccess,
          isError: false,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: ErrorHandler.getMessage(e),
          isError: true,
        );
      }
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await context.read<AuthProvider>().signInAnonymously();
      if (mounted && context.read<AuthProvider>().isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: ErrorHandler.getMessage(e),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Background UI
            _buildBackgroundDecorations(isDark),

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.transparent),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32.0,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),

                            // Logo
                            FadeInDown(
                              delay: const Duration(milliseconds: 200),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 110,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Title
                            FadeInDown(
                              delay: const Duration(milliseconds: 300),
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                ).createShader(bounds),
                                child: Text(
                                  context.loc.welcomeBack,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),
                            FadeInDown(
                              delay: const Duration(milliseconds: 400),
                              child: Text(
                                context.loc.loginToContinue,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Fields
                            FadeInUp(
                              delay: const Duration(milliseconds: 500),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildEmailField(isDark),
                                    const SizedBox(height: 16),
                                    _buildPasswordField(isDark),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            _buildForgotPasswordButton(),

                            const SizedBox(height: 20),

                            // Login Button
                            _buildLoginButton(),

                            const SizedBox(height: 16),

                            // Google Button
                            _buildGoogleButton(isDark),

                            const SizedBox(height: 12),

                            // Guest Button
                            _buildGuestButton(isDark),

                            const Spacer(),
                            const SizedBox(height: 30),

                            // Signup Link
                            _buildSignupLink(isDark),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.teal.withOpacity(0.1)
                  : const Color(0xFFE0F2F1).withOpacity(0.8),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.teal.withOpacity(0.1)
                  : const Color(0xFFE0F2F1).withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isDark) {
    return TextFormField(
      controller: _emailController,
      style: GoogleFonts.cairo(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          (value == null || value.isEmpty) ? context.loc.enterEmail : null,
      decoration: InputDecoration(
        hintText: 'example@mail.com',
        hintStyle: GoogleFonts.cairo(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          fontSize: 13,
        ),
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        errorStyle: GoogleFonts.cairo(
          color: Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return TextFormField(
      controller: _passwordController,
      style: GoogleFonts.cairo(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) =>
          (value == null || value.isEmpty) ? context.loc.enterPassword : null,
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: GoogleFonts.cairo(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          fontSize: 13,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        errorStyle: GoogleFonts.cairo(
          color: Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const ForgotPasswordScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // انزلاق جانبي من اليمين لليسار
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            context.loc.forgotPassword,
            style: GoogleFonts.cairo(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 700),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF39BB5E), Color(0xFF008695)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF008695).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Selector<AuthProvider, bool>(
          selector: (context, auth) => auth.isLoading,
          builder: (context, isLoading, child) {
            return ElevatedButton(
              onPressed: isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      context.loc.loginAction,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoogleButton(bool isDark) {
    return FadeInUp(
      delay: const Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade200,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: _signInWithGoogle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/google.png', height: 32, width: 32),
                const SizedBox(width: 12),
                Text(
                  context.loc.continueWithGoogle,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestButton(bool isDark) {
    return FadeInUp(
      delay: const Duration(milliseconds: 850),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade200,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: _signInAnonymously,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, color: Colors.teal, size: 22),
                const SizedBox(width: 12),
                Text(
                  context.loc.continueAsGuest,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupLink(bool isDark) {
    return FadeInUp(
      delay: const Duration(milliseconds: 900),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.loc.noAccount,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black87),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: Text(
                  context.loc.createAccount,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              children: [
                const TextSpan(text: 'بالتسجيل أنت توافق على '),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: GoogleFonts.cairo(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    final phone = RemoteConfigHelper.supportPhone;
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  child: Row(
                    children: [
                      Text(
                        RemoteConfigHelper.supportPhone,
                        style: GoogleFonts.cairo(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.phone_outlined, color: Colors.teal, size: 16),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '|',
                    style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final email = RemoteConfigHelper.supportEmail;
                    final uri = Uri.parse('mailto:$email');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  child: Row(
                    children: [
                      Text(
                        RemoteConfigHelper.supportEmail,
                        style: GoogleFonts.cairo(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.email_outlined, color: Colors.teal, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'شرق النيل - بني سويف',
                style: GoogleFonts.cairo(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.location_on_outlined, color: Colors.teal, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
