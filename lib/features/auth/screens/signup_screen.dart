import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

import '../../../utils/custom_snackbar.dart';
import '../../../utils/error_handler.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';
import '../widgets/user_type_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/services/remote_config_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isOwner = false; // false = Seeker (Default), true = Owner
  bool _isConfirmPasswordVisible = false;
  bool _acceptedTerms = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_acceptedTerms) {
      CustomSnackBar.show(
        context: context,
        message: context.loc.agreeTermsError,
        isError: true,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackBar.show(
        context: context,
        message: context.loc.passwordsNotMatch,
        isError: true,
      );
      return;
    }

    try {
      await context.read<AuthProvider>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        isOwner: _isOwner,
      );

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: context.loc.accountCreatedSuccess,
          isError: false,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarAction? action;
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          action = SnackBarAction(
            label: context.loc.login,
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context); // Go back to Login Screen
            },
          );
        }

        CustomSnackBar.show(
          context: context,
          message: ErrorHandler.getMessage(e),
          isError: true,
          action: action,
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Scrollable Layout as requested
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true, // Allow background to go behind AppBar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white70 : Colors.teal,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Background: Light Green Semi-Circle Top-Right
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
          // Background: Light Green Semi-Circle Bottom-Left
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
          // Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  FadeInDown(
                    duration: const Duration(seconds: 1),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 120, // Adjusted size
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ).createShader(bounds),
                      child: Text(
                        context.loc.createNewAccount,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInDown(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      context.loc.signupSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Form
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Type Toggle (Sliding Animation)
                        Container(
                          height: 55,
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // 1. Sliding Background
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                alignment: _isOwner
                                    ? AlignmentDirectional.centerEnd
                                    : AlignmentDirectional.centerStart,
                                child: Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 56) /
                                      2,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // 2. Buttons Row
                              Row(
                                children: [
                                  // Seeker Option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _isOwner = false),
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: !_isOwner ? 16 : 14,
                                            color: !_isOwner
                                                ? const Color(0xFF008695)
                                                : (isDark
                                                      ? Colors.grey[600]
                                                      : Colors.grey),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_search_outlined,
                                                size: !_isOwner ? 22 : 18,
                                                color: !_isOwner
                                                    ? const Color(0xFF008695)
                                                    : (isDark
                                                          ? Colors.grey[600]
                                                          : Colors.grey),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: !_isOwner
                                                    ? ShaderMask(
                                                        shaderCallback: (bounds) =>
                                                            const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFF39BB5E,
                                                                ),
                                                                Color(
                                                                  0xFF008695,
                                                                ),
                                                              ],
                                                              begin: Alignment
                                                                  .centerRight,
                                                              end: Alignment
                                                                  .centerLeft,
                                                            ).createShader(
                                                              bounds,
                                                            ),
                                                        child: Text(
                                                          context
                                                              .loc
                                                              .seekerRole,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                      )
                                                    : Text(
                                                        context.loc.seekerRole,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Colors.grey[600]
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Owner Option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _isOwner = true),
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: _isOwner ? 16 : 14,
                                            color: _isOwner
                                                ? const Color(0xFF39BB5E)
                                                : (isDark
                                                      ? Colors.grey[600]
                                                      : Colors.grey),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.apartment_rounded,
                                                size: _isOwner ? 22 : 18,
                                                color: _isOwner
                                                    ? const Color(0xFF39BB5E)
                                                    : (isDark
                                                          ? Colors.grey[600]
                                                          : Colors.grey),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: _isOwner
                                                    ? ShaderMask(
                                                        shaderCallback: (bounds) =>
                                                            const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFF39BB5E,
                                                                ),
                                                                Color(
                                                                  0xFF008695,
                                                                ),
                                                              ],
                                                              begin: Alignment
                                                                  .centerRight,
                                                              end: Alignment
                                                                  .centerLeft,
                                                            ).createShader(
                                                              bounds,
                                                            ),
                                                        child: Text(
                                                          context.loc.ownerRole,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                      )
                                                    : Text(
                                                        context.loc.ownerRole,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Colors.grey[600]
                                                              : Colors.grey,
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
                            ],
                          ),
                        ),

                        _buildLabel(context.loc.fullName, isDark),
                        TextField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            'أحمد محمد',
                            Icons.person_outline,
                            isDark,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(context.loc.email, isDark),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            'example@domain.com',
                            Icons.email_outlined,
                            isDark,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(context.loc.password, isDark),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _inputDecoration(
                            '........',
                            Icons.lock_outline,
                            isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(context.loc.confirmPassword, isDark),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: _inputDecoration(
                            '........',
                            Icons.verified_user_outlined,
                            isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Terms
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          activeColor: Colors.teal,
                          onChanged: (val) =>
                              setState(() => _acceptedTerms = val!),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.cairo(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: context.loc.agreeTo),
                                TextSpan(
                                  text: context.loc.termsOfService,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final url = RemoteConfigHelper.lekOraebUrl;
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url));
                                      }
                                    },
                                ),
                                TextSpan(text: context.loc.and),
                                TextSpan(
                                  text: context.loc.privacyPolicy,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final url = RemoteConfigHelper.lekOraebUrl;
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url));
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF008695,
                            ).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Selector<AuthProvider, bool>(
                        selector: (context, auth) => auth.isLoading,
                        builder: (context, isLoading, child) {
                          return ElevatedButton(
                            onPressed: isLoading ? null : _signUp,
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
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    context.loc.signup,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Google Sign In Button
                  _buildGoogleButton(isDark),

                  const SizedBox(height: 20),

                  // Back to Login
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.loc.alreadyHaveAccount,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back to Login
                          },
                          child: Text(
                            context.loc.login,
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildGoogleButton(bool isDark) {
    return FadeInUp(
      delay: const Duration(milliseconds: 700),
      child: Container(
        width: double.infinity,
        height: 55,
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
                Image.asset('assets/images/google.png', height: 40, width: 40),
                const SizedBox(width: 15),
                Text(
                  context.loc.continueWithGoogle,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
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

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 5),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.teal[200] : const Color(0xFF004D40),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    bool isDark, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.teal),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal),
      ),
    );
  }

  // Widget _socialButton(IconData icon, String label) { ... } // Removed
}
