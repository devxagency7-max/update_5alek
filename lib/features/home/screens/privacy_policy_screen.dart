import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/services/remote_config_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motareb/core/theme/app_theme.dart';
import 'package:motareb/core/extensions/loc_extension.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool isHotelApartment;

  const PrivacyPolicyScreen({
    super.key,
    this.isHotelApartment = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          context.loc.privacyPolicy,
          style: GoogleFonts.cairo(
            color: isHotelApartment ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isHotelApartment
                ? const LinearGradient(
                    colors: [
                      Color(0xFFF3E5AB),
                      Color(0xFFDFBA6B),
                      Color(0xFF9E7D3B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppTheme.primaryGradient,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isHotelApartment ? Colors.black : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSectionCard(
              context,
              title: context.loc.privacyPolicyTitle,
              icon: Icons.payments_outlined,
              content: context.loc.privacyPolicyContent,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: context.loc.websiteTitle,
              icon: Icons.language,
              content: context.loc.websiteContent,
              isDark: isDark,
              onTap: () async {
                final url = RemoteConfigHelper.lekOraebUrl;
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: context.loc.refundPolicyTitle,
              icon: Icons.assignment_return_outlined,
              content: context.loc.refundPolicyContent,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: context.loc.contactInfoTitle,
              icon: Icons.contact_support_outlined,
              isDark: isDark,
              contentWidget: _buildContactInfoContent(context, isDark),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: context.loc.businessAddressTitle,
              icon: Icons.business_outlined,
              content: context.loc.businessAddressContent,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: context.loc.aboutAppTitle,
              icon: Icons.info_outline,
              content: context.loc.aboutAppContent,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    String content = '',
    Widget? contentWidget,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final themeColor = isHotelApartment
        ? const Color(0xFFDFBA6B)
        : const Color(0xFF39BB5E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: (isHotelApartment
                            ? const Color(0xFFDFBA6B)
                            : const Color(0xFF008695))
                        .withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: themeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            contentWidget ??
                Text(
                  content,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.8,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  textAlign: TextAlign.justify,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoContent(BuildContext context, bool isDark) {
    final normalStyle = GoogleFonts.cairo(
      fontSize: 14,
      height: 1.8,
      color: isDark ? Colors.grey[300] : Colors.grey[700],
    );
    
    final accentColor = isHotelApartment
        ? const Color(0xFFDFBA6B)
        : const Color(0xFF008695);

    final linkStyle = GoogleFonts.cairo(
      fontSize: 14,
      height: 1.8,
      color: accentColor,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      decorationColor: accentColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إذا كان لديك أي أسئلة أو طلبات استرداد أموال، يرجى التواصل معنا:',
          style: normalStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final email = RemoteConfigHelper.supportEmail;
            final uri = Uri.parse('mailto:$email');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          child: Text(RemoteConfigHelper.supportEmail, style: linkStyle),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final phone = RemoteConfigHelper.supportPhone;
            final uri = Uri.parse('tel:$phone');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          child: Text(RemoteConfigHelper.supportPhone, style: linkStyle),
        ),
      ],
    );
  }
}
