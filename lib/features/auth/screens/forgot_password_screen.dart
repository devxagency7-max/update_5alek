import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/services/remote_config_helper.dart';
import '../providers/auth_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/error_handler.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await context.read<AuthProvider>().sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: context.loc.resetEmailSent,
          isError: false,
        );
        // Wait 2 seconds and go back to LoginScreen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Background Decorations
            _buildBackgroundDecorations(isDark),

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.transparent),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32.0,
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 20),

                              // Lock Icon with Animation
                              FadeInDown(
                                delay: const Duration(milliseconds: 200),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.teal.withOpacity(0.1),
                                    ),
                                    child: const Icon(
                                      Icons.lock_open_rounded,
                                      size: 80,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Title with Shader Gradient
                              FadeInDown(
                                delay: const Duration(milliseconds: 300),
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFF39BB5E),
                                          Color(0xFF008695),
                                        ],
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                      ).createShader(bounds),
                                  child: Text(
                                    context.loc.forgotPassword,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Subtitle
                              FadeInDown(
                                delay: const Duration(milliseconds: 400),
                                child: Text(
                                  context.loc.forgotPasswordSubtitle,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Email input field
                              FadeInUp(
                                delay: const Duration(milliseconds: 500),
                                child: _buildEmailField(isDark),
                              ),

                              const SizedBox(height: 30),

                              // Send Link Button
                              FadeInUp(
                                delay: const Duration(milliseconds: 600),
                                child: _buildSendButton(),
                              ),

                              const Spacer(),

                              FadeInUp(
                                delay: const Duration(milliseconds: 700),
                                child: Column(
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          height: 1.6,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: context
                                                .loc
                                                .noInboxSupportPrefix,
                                          ),
                                          TextSpan(
                                            text: context.loc.contactUsAction,
                                            style: GoogleFonts.cairo(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                final url = Uri.parse(
                                                  RemoteConfigHelper
                                                      .supportWebsiteUrl,
                                                );
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(
                                                    url,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                }
                                              },
                                          ),
                                          TextSpan(
                                            text: context
                                                .loc
                                                .noInboxSupportSuffix,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.loc.enterEmail;
        }
        if (!value.contains('@')) {
          return context.loc.invalidEmail;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'example@mail.com',
        hintStyle: GoogleFonts.cairo(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: Colors.teal,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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

  Widget _buildSendButton() {
    return Container(
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
            color: const Color(0xFF008695).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Selector<AuthProvider, bool>(
        selector: (context, auth) => auth.isLoading,
        builder: (context, isLoading, child) {
          return ElevatedButton(
            onPressed: isLoading ? null : _sendResetEmail,
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
                    context.loc.sendResetLink,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
