import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'package:motareb/core/providers/theme_provider.dart';
import 'package:motareb/core/providers/locale_provider.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import 'package:motareb/core/services/remote_config_helper.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/signup_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../../core/widgets/ads/banner_ad_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bookings/screens/my_bookings_screen.dart';
import '../screens/privacy_policy_screen.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    String userName = authProvider.userData?['name'] ?? context.loc.guest;
    String userEmail = authProvider.user?.email ?? context.loc.loginNow;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isDark = themeProvider.isDarkMode;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 1. Expanded Header (Gradient Background)
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(45),
                                      child:
                                          authProvider.userData?['photoUrl'] !=
                                              null
                                          ? CachedNetworkImage(
                                              imageUrl: authProvider
                                                  .userData!['photoUrl'],
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                        Icons.person,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              userName,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userEmail,
                              style: GoogleFonts.cairo(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Floating Stats Card
                    Positioned(
                      bottom: -40,
                      left: 20,
                      right: 20,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: isDark
                                ? Border.all(color: AppTheme.darkBorder)
                                : null,
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF008695,
                                      ).withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context.loc.favorites,
                                favoritesProvider.favorites.length.toString(),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark
                                    ? const Color(0xFF2A3038)
                                    : Colors.grey.shade200,
                              ),
                              _buildStatItem(context.loc.reviews, '0'),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark
                                    ? const Color(0xFF2A3038)
                                    : Colors.grey.shade200,
                              ),
                              if (authProvider.isAuthenticated &&
                                  !authProvider.isGuest)
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('bookings')
                                      .where(
                                        'userId',
                                        isEqualTo: authProvider.user?.uid,
                                      )
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final count =
                                        snapshot.data?.docs.length ?? 0;
                                    return _buildStatItem(
                                      context.loc.myBookings,
                                      count.toString(),
                                    );
                                  },
                                )
                              else
                                _buildStatItem(context.loc.myBookings, '0'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 4. Menu Items
                      if (authProvider.isAuthenticated &&
                          !authProvider.isGuest) ...[
                        _buildProfileMenuItem(
                          context.loc.myBookings,
                          Icons.calendar_today_outlined,
                          delay: 100,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyBookingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildProfileMenuItem(
                          context.loc.favorites,
                          Icons.favorite_border,
                          delay: 200,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FavoritesScreen(),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        _buildProfileMenuItem(
                          context.loc.favorites,
                          Icons.favorite_border,
                          delay: 100,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FavoritesScreen(),
                              ),
                            );
                          },
                        ),
                        _buildProfileMenuItem(
                          context.loc.loginAction,
                          Icons.login,
                          delay: 200,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                        _buildProfileMenuItem(
                          context.loc.createAccount,
                          Icons.person_add_outlined,
                          delay: 300,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Privacy & Policy
                      _buildProfileMenuItem(
                        context.loc.privacyPolicyScreen,
                        Icons.privacy_tip_outlined,
                        delay: 400,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),

                      // Theme Toggle Tile
                      _buildThemeToggle(context, themeProvider),

                      // Language Toggle Tile (Expansion Style)
                      _buildLanguageToggle(context, localeProvider),

                      if (authProvider.isAuthenticated && !authProvider.isGuest)
                        _buildProfileMenuItem(
                          context.loc.logout,
                          Icons.logout,
                          isDestructive: true,
                          delay: 100,
                          onTap: () =>
                              _showLogoutConfirmation(context, authProvider),
                        ),

                      if (authProvider.isAuthenticated && !authProvider.isGuest)
                        _buildProfileMenuItem(
                          context.loc.deleteAccount,
                          Icons.delete_forever_outlined,
                          isDestructive: true,
                          delay: 150,
                          onTap: () =>
                              _showDeleteAccountConfirmation(context, authProvider),
                        ),

                      // Privacy Contact Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: _buildPrivacyContactCard(context, isDark),
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 40),

                      // 5. Large Footer Logo
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Column(
                          children: [
                            Text(
                              'Powered By',
                              style: GoogleFonts.cairo(
                                color: Colors.grey,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () async {
                                final url = RemoteConfigHelper.devXOneUrl;
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).cardTheme.color,
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF008695,
                                            ).withValues(alpha: 0.2),
                                            blurRadius: 25,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                ),
                                 child: CircleAvatar(
                                   radius: 60,
                                   backgroundColor: Colors.transparent,
                                   backgroundImage: CachedNetworkImageProvider(
                                     RemoteConfigHelper.devXLogoUrl,
                                   ),
                                 ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(top: false, child: BannerAdWidget()),
        ),
      ],
    );
  }

  Widget _buildPrivacyContactCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF008695).withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen()),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.loc.privacyPolicy,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? AppTheme.darkBorder : Colors.grey.shade200,
            height: 24,
          ),
          _buildContactInfoRow(
            icon: Icons.location_on_outlined,
            text: 'بني سويف، مصر',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final email = RemoteConfigHelper.supportEmail;
              final uri = Uri.parse('mailto:$email');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: _buildContactInfoRow(
              icon: Icons.email_outlined,
              text: RemoteConfigHelper.supportEmail,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final phone = RemoteConfigHelper.supportPhone;
              final uri = Uri.parse('tel:$phone');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: _buildContactInfoRow(
              icon: Icons.phone_outlined,
              text: RemoteConfigHelper.supportPhone,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF39BB5E), Color(0xFF008695)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDark ? const Color(0xFF9CA3AF) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider provider) {
    bool isDark = provider.isDarkMode;
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => provider.toggleTheme(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF008695).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF39BB5E).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
                size: 22,
              ),
            ),
            title: Text(
              isDark ? context.loc.darkMode : context.loc.lightMode,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (val) => provider.toggleTheme(),
              activeThumbColor: const Color(0xFF16A34A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context, LocaleProvider provider) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isArabic = provider.locale?.languageCode == 'ar';

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF008695).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF39BB5E).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: const Icon(Icons.language, color: Colors.white, size: 22),
            ),
            title: Text(
              context.loc.language,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? 'العربية' : 'English',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF16A34A),
                ),
              ],
            ),
            children: [
              _buildLanguageItem(
                context: context,
                label: 'العربية',
                isSelected: isArabic,
                onTap: () => provider.setLocale(const Locale('ar')),
              ),
              _buildLanguageItem(
                context: context,
                label: 'English',
                isSelected: !isArabic,
                onTap: () => provider.setLocale(const Locale('en')),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF16A34A) : Colors.grey,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20)
          : null,
    );
  }

  Widget _buildStatItem(String label, String count) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(label, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileMenuItem(
    String title,
    IconData icon, {
    bool isDestructive = false,
    int delay = 0,
    VoidCallback? onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF008695).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isDestructive
                    ? LinearGradient(
                        colors: [
                          Colors.red.withValues(alpha: 0.1),
                          Colors.red.withValues(alpha: 0.05),
                        ],
                      )
                    : AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: (isDark || isDestructive)
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF39BB5E).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.white,
                size: 22,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDestructive
                    ? Colors.red
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 15),
              Text(
                context.loc.logout,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(dialogContext).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context
                    .loc
                    .logoutConfirmation, // You might need to add this key or use a hardcoded string if localization is missing
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Theme.of(dialogContext).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Close confirmation dialog
                        Navigator.pop(dialogContext);

                        // Show loading dialog using parent context
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF39BB5E),
                              ),
                            ),
                          );
                        }

                        // Perform sign out
                        await authProvider.signOut();

                        if (context.mounted) {
                          // removing loading dialog
                          Navigator.of(context).pop();

                          // Navigate to LoginScreen
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        context.loc.logout,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        context.loc.cancel,
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 15),
              Text(
                context.loc.deleteAccountTitle,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(dialogContext).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.loc.deleteAccountConfirmation,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Theme.of(dialogContext).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Close confirmation dialog
                        Navigator.pop(dialogContext);

                        // Show loading dialog using parent context
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF39BB5E),
                              ),
                            ),
                          );
                        }

                        try {
                          // Perform delete account
                          await authProvider.deleteAccount();

                          if (context.mounted) {
                            // removing loading dialog
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.loc.deleteAccountSuccess),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Navigate to Splash or Login Screen
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            // removing loading dialog
                            Navigator.of(context).pop();

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.loc.deleteAccountError),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        context.loc.delete,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        context.loc.cancel,
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
