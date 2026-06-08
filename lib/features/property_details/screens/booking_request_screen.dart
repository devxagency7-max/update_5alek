import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/services/remote_config_helper.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:motareb/core/extensions/loc_extension.dart';
import '../../../../core/models/property_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/booking_request_provider.dart';
import 'payment_webview_screen.dart';
import '../../home/screens/privacy_policy_screen.dart';
import '../../home/widgets/hotel_package_card.dart';

class BookingRequestScreen extends StatelessWidget {
  final Property property;
  final String selectionDetails;
  final double price;
  final List<String> selections;
  final bool isWhole;
  final int? bedCount;

  const BookingRequestScreen({
    super.key,
    required this.property,
    required this.selectionDetails,
    required this.price,
    required this.selections,
    required this.isWhole,
    this.bedCount,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingRequestProvider(
        property: property,
        selectionDetails: selectionDetails,
        price: price,
        selections: selections,
        isWhole: isWhole,
        bedCount: bedCount,
      ),
      child: const _BookingRequestContent(),
    );
  }
}

class _BookingRequestContent extends StatefulWidget {
  const _BookingRequestContent();

  @override
  State<_BookingRequestContent> createState() => _BookingRequestContentState();
}

class _BookingRequestContentState extends State<_BookingRequestContent> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  final TextEditingController _notesController = TextEditingController();

  // Payment Selection
  String _paymentMethod = 'card'; // 'card' or 'wallet'
  final TextEditingController _walletNumberController = TextEditingController();

  // ─── Hotel Tier Helpers ──────────────────────────────────────────────────
  HotelTier? _detectTier(Property property) {
    if (!property.isHotelApartment) return null;
    final id = property.id.toLowerCase();
    if (id.contains('premium')) return HotelTier.premium;
    if (id.contains('plus'))    return HotelTier.plus;
    if (id.contains('basic'))   return HotelTier.basic;
    return HotelTier.premium; // fallback
  }

  List<Color> _tierColors(Property property) {
    final tier = _detectTier(property);
    return switch (tier) {
      HotelTier.premium => [const Color(0xFFDFBA6B), const Color(0xFF9E7D3B)],
      HotelTier.plus    => [const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
      HotelTier.basic   => [const Color(0xFF39BB5E), const Color(0xFF008695)],
      null              => [const Color(0xFF39BB5E), const Color(0xFF008695)],
    };
  }

  Color _primaryColor(Property property) => _tierColors(property).first;

  /// true = dark text on light (gold) background, false = white text
  bool _darkLabel(Property property) => _detectTier(property) == HotelTier.premium;

  // Coupon State
  final TextEditingController _couponController = TextEditingController();
  bool _isValidatingCoupon = false;
  String? _couponError;
  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  String? _couponDiscountType;
  double? _couponDiscountValue;

  Future<void> _validateCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
      _couponError = null;
      _appliedCouponCode = null;
      _discountAmount = 0.0;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('coupons')
          .doc(code)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        setState(() {
          _couponError = "الكوبون غير موجود";
          _isValidatingCoupon = false;
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final usedCount = data['usedCount'] as int? ?? 0;
      final usageLimit = data['usageLimit'] as int? ?? 999999;
      final isActive = data['isActive'] ?? true;
      final expiryDate = data['expiryDate'] as Timestamp?;
      final isExpired =
          expiryDate != null && expiryDate.toDate().isBefore(DateTime.now());

      if (!isActive) {
        setState(() {
          _couponError = "الكوبون غير نشط";
          _isValidatingCoupon = false;
        });
        return;
      }

      if (isExpired) {
        setState(() {
          _couponError = "الكوبون منتهي الصلاحية";
          _isValidatingCoupon = false;
        });
        return;
      }

      if (usedCount >= usageLimit) {
        setState(() {
          _couponError = "تم استخدام الكوبون للحد الأقصى";
          _isValidatingCoupon = false;
        });
        return;
      }

      final provider = context.read<BookingRequestProvider>();
      final commission =
          (provider.property.fixedCommission != null &&
              provider.property.fixedCommission! > 0)
          ? provider.property.fixedCommission!
          : (provider.price / 2);

      final discountType = data['discountType'] as String? ?? 'fixed';
      final discountValue = (data['discountValue'] as num?)?.toDouble() ?? 0.0;

      double discount = 0.0;
      if (discountType == 'percentage') {
        discount = commission * (discountValue / 100);
      } else {
        discount = discountValue;
      }

      if (discount > commission) {
        discount = commission;
      }

      setState(() {
        _appliedCouponCode = code;
        _couponDiscountType = discountType;
        _couponDiscountValue = discountValue;
        _discountAmount = discount;
        _couponError = null;
        _isValidatingCoupon = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _couponError = "حدث خطأ أثناء التحقق من الكوبون";
          _isValidatingCoupon = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final userData = authProvider.userData;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: userData?['phone'] ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');

    // Set default payment method based on Remote Config visibility
    if (RemoteConfigHelper.showCardPayment) {
      _paymentMethod = 'card';
    } else if (RemoteConfigHelper.showWalletPayment) {
      _paymentMethod = 'wallet';
    } else {
      _paymentMethod = ''; // Both disabled
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _walletNumberController.dispose();
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingRequestProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
              gradient: LinearGradient(
                colors: _tierColors(provider.property),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            context.loc.bookingRequest, // "طلب الحجز"
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkLabel(provider.property) ? Colors.black : Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: _darkLabel(provider.property) ? Colors.black : Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                // Booking Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.bookingDetails,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${provider.selectionDetails} - ${provider.property.localizedTitle(context)}',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                Text(
                                  provider.property.localizedLocation(context),
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: provider.property.isHotelApartment
                                        ? const Color(
                                            0xFFDFBA6B,
                                          ).withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: provider.property.isHotelApartment
                                          ? const Color(
                                              0xFFDFBA6B,
                                            ).withValues(alpha: 0.4)
                                          : Colors.grey.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        provider.property.isHotelApartment
                                            ? Icons.hotel
                                            : Icons.home_outlined,
                                        size: 13,
                                        color:
                                            provider.property.isHotelApartment
                                            ? const Color(0xFFDFBA6B)
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        provider.property.isHotelApartment
                                            ? 'شقة فندقية ✨'
                                            : 'شقة عادية',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              provider.property.isHotelApartment
                                              ? const Color(0xFFDFBA6B)
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.location_on_outlined,
                            color: provider.property.isHotelApartment
                                ? _primaryColor(provider.property)
                                : const Color(0xFF008695),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.loc.monthlyPriceLabel,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${provider.price} ${context.loc.currency}',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: provider.property.isHotelApartment
                                  ? _primaryColor(provider.property)
                                  : (isDark
                                        ? Colors.white
                                        : const Color(0xFF008695)),
                            ),
                          ),
                        ],
                      ),
                      if (provider.property.requiredDeposit != null &&
                          provider.property.requiredDeposit! > 0) ...[
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.loc.requiredDeposit,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${provider.property.requiredDeposit} ${context.loc.currency}',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD35400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // User Data Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.yourData,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _nameController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: context.loc.name,
                          labelStyle: GoogleFonts.cairo(fontSize: 13),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? context.loc.required
                            : null,
                      ),
                      const SizedBox(height: 10),

                      if (RemoteConfigHelper.showPhoneField) ...[
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            labelText: context.loc.phone,
                            labelStyle: GoogleFonts.cairo(fontSize: 13),
                            prefixIcon: const Icon(Icons.phone_outlined),
                            hintText: context.loc.examplePhoneNumber,
                          ),
                          validator: (value) {
                            if (!RemoteConfigHelper.showPhoneField) return null;
                            return (value == null || value.isEmpty)
                                ? context.loc.required
                                : null;
                          },
                        ),
                        const SizedBox(height: 10),
                      ],

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: context.loc.email,
                          labelStyle: GoogleFonts.cairo(fontSize: 13),
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).inputDecorationTheme.fillColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Coupon Code Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "كوبون الخصم",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _couponController,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                labelText: "أدخل كود الكوبون",
                                labelStyle: GoogleFonts.cairo(fontSize: 13),
                                prefixIcon: const Icon(
                                  Icons.local_offer_outlined,
                                ),
                                errorText: _couponError,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _isValidatingCoupon
                                ? null
                                : _validateCoupon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  provider.property.isHotelApartment
                                  ? _primaryColor(provider.property)
                                  : const Color(0xFF008695),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            child: _isValidatingCoupon
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "تطبيق",
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      if (_appliedCouponCode != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF39BB5E),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "تم تطبيق الكوبون '$_appliedCouponCode' بنجاح! خصم ${_discountAmount.toStringAsFixed(0)} ${context.loc.currency}",
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFF39BB5E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _couponController.clear();
                                  _appliedCouponCode = null;
                                  _discountAmount = 0.0;
                                  _couponDiscountType = null;
                                  _couponDiscountValue = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Method Selection
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "طريقة الدفع", // context.loc.paymentMethod
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (!RemoteConfigHelper.showCardPayment &&
                          !RemoteConfigHelper.showWalletPayment) ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "طرق الدفع الإلكتروني غير متوفرة حالياً",
                              style: GoogleFonts.cairo(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            if (RemoteConfigHelper.showCardPayment)
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _paymentMethod = 'card'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _paymentMethod == 'card'
                                          ? _primaryColor(provider.property).withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _paymentMethod == 'card'
                                            ? _primaryColor(provider.property)
                                            : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.credit_card,
                                          color: _paymentMethod == 'card'
                                              ? _primaryColor(provider.property)
                                              : Colors.grey,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "بطاقة بنكية", // context.loc.payWithCard
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: _paymentMethod == 'card'
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: _paymentMethod == 'card'
                                                ? _primaryColor(provider.property)
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (RemoteConfigHelper.showCardPayment &&
                                RemoteConfigHelper.showWalletPayment)
                              const SizedBox(width: 15),
                            if (RemoteConfigHelper.showWalletPayment)
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _paymentMethod = 'wallet'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _paymentMethod == 'wallet'
                                          ? _primaryColor(provider.property).withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _paymentMethod == 'wallet'
                                            ? _primaryColor(provider.property)
                                            : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet,
                                          color: _paymentMethod == 'wallet'
                                              ? _primaryColor(provider.property)
                                              : Colors.grey,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "محفظة إلكترونية", // context.loc.payWithWallet
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: _paymentMethod == 'wallet'
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: _paymentMethod == 'wallet'
                                                ? _primaryColor(provider.property)
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (_paymentMethod == 'wallet') ...[
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _walletNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText:
                                "رقم المحفظة", // context.loc.walletNumber
                            hintText: "01xxxxxxxxx",
                            prefixIcon: const Icon(Icons.phone_android),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (_paymentMethod == 'wallet') {
                              if (value == null || value.isEmpty) {
                                return context.loc.required;
                              }
                              if (!RegExp(
                                r'^01[0-2,5]{1}[0-9]{8}$',
                              ).hasMatch(value)) {
                                return "رقم هاتف غير صحيح"; // context.loc.invalidPhoneNumber
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildPrivacyContactCard(provider.property.isHotelApartment),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: _tierColors(provider.property),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: provider.isSubmitting
                    ? null
                    : () async {
                        // 1. Validate Form
                        if (!_formKey.currentState!.validate()) return;

                        // Validate that at least one payment method is available and selected
                        if (_paymentMethod.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'طرق الدفع الإلكتروني غير متوفرة حالياً، يرجى المحاولة لاحقاً',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                          return;
                        }

                        // 2. User Info
                        final user = context.read<AuthProvider>().user;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.loc.guestActionRestrictedDesc,
                              ),
                            ),
                          );
                          return;
                        }

                        // 3. Price validation
                        if (provider.price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'سعر الوحدة المختارة غير صحيح، يرجى التواصل مع الدعم',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                          return;
                        }

                        await _showPaymentSummary(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: provider.isSubmitting
                    ? CircularProgressIndicator(
                        color: _darkLabel(provider.property) ? Colors.black : Colors.white,
                      )
                    : Text(
                        context.loc.submitRequest, // "دفع العربون وحجز"
                        style: GoogleFonts.cairo(
                          color: _darkLabel(provider.property) ? Colors.black : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> startDepositPayment() async {
    final provider = context.read<BookingRequestProvider>();
    setState(() {});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Prepare User Info
      final userInfo = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text,
        'email': _emailController.text,
        'notes': _notesController.text,
      };

      final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('createDepositBooking')
          .call({
            "propertyId": provider.property.id,
            "userInfo": userInfo,
            "paymentMethod": _paymentMethod,
            "selections": provider.selections,
            "isWhole": provider.isWhole,
            "walletNumber": _paymentMethod == 'wallet'
                ? _walletNumberController.text
                : null,
            "couponCode": _appliedCouponCode,
            "bedCount": provider.bedCount,
          });

      Navigator.pop(context); // Close loading dialog

      final data = result.data as Map<String, dynamic>;

      // Handle Wallet Redirection
      // Handle Wallet Redirection
      if (_paymentMethod == 'wallet') {
        final redirectUrl = data['redirectUrl'] as String?;

        if (redirectUrl != null &&
            redirectUrl.isNotEmpty &&
            redirectUrl.startsWith('http')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebViewScreen(
                paymentMethod: _paymentMethod,
                url: redirectUrl,
                paymentToken: '', // Not used for direct URL
                iframeId: '',
                paymentId: data['paymentId'].toString(),
                bookingId: data['bookingId'].toString(),
                paymentType: 'deposit',
              ),
            ),
          );
          return;
        } else {
          // Fall through to error or handle explicitly
          throw 'Invalid wallet redirection URL received';
        }
      }

      final paymentToken = data['paymentToken'];
      final iframeId = data['iframeId'];
      final paymentId = data['paymentId'];
      final bookingId = data['bookingId'];

      if (paymentToken != null && iframeId != null) {
        if (!mounted) return;

        // Navigate to the new Secure WebView Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentMethod: 'card',
              paymentToken: paymentToken.toString(),
              iframeId: iframeId.toString(),
              paymentId: paymentId.toString(),
              bookingId: bookingId.toString(),
              paymentType: 'deposit',
            ),
          ),
        );
      } else {
        throw 'Missing payment data from server';
      }
    } on FirebaseFunctionsException catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading

      String errorMessage;

      // Parse known error codes
      if (e.code == 'failed-precondition' &&
          e.message?.contains('being booked') == true) {
        errorMessage = context.loc.paymentErrorPropertyReserved;
      } else if (e.code == 'not-found') {
        errorMessage = context.loc.paymentErrorUnavailable;
      } else {
        errorMessage = context.loc.paymentErrorGeneric(e.message ?? e.code);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.loc.error),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.loc.confirm),
            ),
          ],
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.loc.error),
          content: Text(context.loc.paymentErrorGeneric(e.toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.loc.confirm),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPrivacyContactCard(bool isHotelApartment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) =>
          FractionalTranslation(translation: offset, child: child!),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: const Color(0xFF2F3640)) : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: isHotelApartment
                        ? const Color(0xFFDFBA6B).withValues(alpha: 0.05)
                        : const Color(0xFF008695).withValues(alpha: 0.05),
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
                  builder: (_) =>
                      PrivacyPolicyScreen(isHotelApartment: isHotelApartment),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _tierColors(
                          context.read<BookingRequestProvider>().property,
                        ),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
              color: isDark ? const Color(0xFF2F3640) : Colors.grey.shade200,
              height: 24,
            ),
            _buildContactRow(
              icon: Icons.location_on_outlined,
              text: 'بني سويف، مصر',
              isDark: isDark,
              isHotelApartment: isHotelApartment,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final email = RemoteConfigHelper.supportEmail;
                final uri = Uri.parse('mailto:$email');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: _buildContactRow(
                icon: Icons.email_outlined,
                text: RemoteConfigHelper.supportEmail,
                isDark: isDark,
                isHotelApartment: isHotelApartment,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final phone = RemoteConfigHelper.supportPhone;
                final uri = Uri.parse('tel:$phone');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: _buildContactRow(
                icon: Icons.phone_outlined,
                text: RemoteConfigHelper.supportPhone,
                isDark: isDark,
                isHotelApartment: isHotelApartment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
    required bool isDark,
    required bool isHotelApartment,
  }) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: _tierColors(
              context.read<BookingRequestProvider>().property,
            ),
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

  Future<void> _showPaymentSummary(BuildContext context) async {
    final provider = context.read<BookingRequestProvider>();

    final deposit = provider.property.requiredDeposit ?? 0.0;
    final commission =
        (provider.property.fixedCommission != null &&
            provider.property.fixedCommission! > 0)
        ? provider.property.fixedCommission!
        : (provider.price / 2);
    final remaining = (commission - _discountAmount - deposit) < 0
        ? 0.0
        : (commission - _discountAmount - deposit);

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              context.loc.bookingSummary,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryRow(
              context,
              context.loc.propertyLabel,
              provider.property.localizedTitle(context),
              isBold: true,
            ),
            const Divider(height: 30),
            _buildSummaryRow(
              context,
              context.loc.depositAmount,
              "$deposit ${context.loc.currency}",
              valueColor: const Color(0xFFD35400),
              isBold: true,
            ),
            if (_appliedCouponCode != null) ...[
              const SizedBox(height: 10),
              _buildSummaryRow(
                context,
                "خصم الكوبون ($_appliedCouponCode)",
                "-${_discountAmount.toStringAsFixed(0)} ${context.loc.currency}",
                valueColor: const Color(0xFF39BB5E),
                isBold: true,
              ),
            ],
            const SizedBox(height: 10),
            _buildSummaryRow(
              context,
              context.loc.remainingAmount,
              "$remaining ${context.loc.currency}",
              valueColor: Colors.grey,
            ),
            const SizedBox(height: 30),
            // Wallet Specific Notice
            if (_paymentMethod == 'wallet')
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "سيتم تحويلك للدفع عبر المحفظة. تأكد من وجود رصيد كافٍ.",
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _primaryColor(provider.property).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _primaryColor(provider.property).withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _primaryColor(provider.property),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "سيتم تحويلك لصفحة الدفع الآمنة", // context.loc.paymentRedirectNotice
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _primaryColor(provider.property),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: provider.property.isHotelApartment
                          ? BorderSide(color: _primaryColor(provider.property))
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      context.loc.cancel,
                      style: GoogleFonts.cairo(
                        color: provider.property.isHotelApartment
                            ? _primaryColor(provider.property)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _tierColors(provider.property),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        startDepositPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        context.loc.confirmAndPay,
                        style: GoogleFonts.cairo(
                          color: _darkLabel(provider.property) ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.phone_outlined,
                          color: provider.property.isHotelApartment
                              ? _primaryColor(provider.property)
                              : Colors.teal,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '|',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]
                            : Colors.grey[400],
                      ),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.email_outlined,
                          color: provider.property.isHotelApartment
                              ? _primaryColor(provider.property)
                              : Colors.teal,
                          size: 16,
                        ),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.location_on_outlined,
                  color: provider.property.isHotelApartment
                      ? _primaryColor(provider.property)
                      : Colors.teal,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.cairo(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}
