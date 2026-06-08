import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motareb/core/services/remote_config_helper.dart';
import '../../property_details/screens/payment_webview_screen.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/loc_extension.dart';
import '../../property_details/screens/property_details_screen.dart';
import '../../home/screens/privacy_policy_screen.dart';
import '../../../core/models/property_model.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.loc.myBookings)),
        body: const Center(child: Text("Please login first")),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.loc.myBookings,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text(context.loc.noBookings));
            }

            // نعرض بس الحجوزات اللي اتدفع فيها الـ Deposit فعلاً
            final docs = snapshot.data!.docs.where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return d['status'] != 'pending_deposit';
            }).toList();

            if (docs.isEmpty) {
              return Center(child: Text(context.loc.noBookings));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final date = (data['createdAt'] as Timestamp?)?.toDate();
                final bookingId = docs[index].id;

                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: _BookingTimelineCard(
                    bookingId: bookingId,
                    data: data,
                    bookingDate: date,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookingTimelineCard extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> data;
  final DateTime? bookingDate;

  const _BookingTimelineCard({
    required this.bookingId,
    required this.data,
    this.bookingDate,
  });

  @override
  State<_BookingTimelineCard> createState() => _BookingTimelineCardState();
}

class _BookingTimelineCardState extends State<_BookingTimelineCard> {
  bool _acceptedTerms = false;
  bool? _isHotelApartment;

  @override
  void initState() {
    super.initState();
    _checkIfHotelApartment();
  }

  Future<void> _checkIfHotelApartment() async {
    final propertyId = widget.data['propertyId'];
    if (propertyId == null) return;

    // TAJ HOUSE bookings reference `hotel_properties`, not `properties`.
    final isHotelBooking = widget.data['isHotelBooking'] == true;
    if (isHotelBooking) {
      if (mounted) setState(() => _isHotelApartment = true);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _isHotelApartment = data?['isHotelApartment'] ?? false;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String status = widget.data['status'] ?? 'pending';
    bool isDepositPaid =
        status == 'reserved' ||
        status == 'completed' ||
        status == 'paying_remaining';
    bool isFullyPaid = status == 'completed';

    final expiresAtTimestamp = widget.data['expiresAt'] as Timestamp?;
    final expiresAt = expiresAtTimestamp?.toDate();
    final bool isExpired =
        expiresAt != null && expiresAt.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
      ),
      child: Column(
        children: [
          _buildHeader(context, widget.data['propertyId']),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStepCircle(context, "1", isDepositPaid),

                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 2,
                        color: Colors.grey.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                (constraints.constrainWidth() / 10).floor(),
                                (_) => SizedBox(
                                  width: 5,
                                  height: 2,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      if ((status == 'reserved' ||
                              status == 'pending_deposit') &&
                          expiresAt != null)
                        CountdownTimer(expiryDate: expiresAt),
                    ],
                  ),
                ),

                _buildStepCircle(context, "2", isFullyPaid),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildVerticalDashedLine(),
                      _buildDetailCard(
                        context,
                        "Deposit",
                        // Bug #7: قبل الدفع نعرض depositAmount (المطلوب)، بعده نعرض depositPaid (اللي اتدفع)
                        "${isDepositPaid ? (widget.data['depositPaid'] ?? widget.data['depositAmount'] ?? 0) : (widget.data['depositAmount'] ?? widget.data['depositPaid'] ?? 0)} EGP",
                        isDepositPaid ? Colors.green : Colors.orange,
                        isDepositPaid ? "Paid" : "Pending",
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildVerticalDashedLine(),
                      _buildDetailCard(
                        context,
                        "Remaining",
                        "${widget.data['remainingAmount'] ?? 0} EGP",
                        isFullyPaid
                            ? Colors.green
                            : (status == "paying_remaining"
                                  ? Colors.orange
                                  : Colors.grey),
                        isFullyPaid
                            ? "Paid"
                            : (status == "paying_remaining"
                                  ? "Processing"
                                  : "Pending"),
                      ),

                      if (status == 'reserved') ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: double.infinity,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: (_isHotelApartment == true)
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFF3E5AB),
                                        Color(0xFFDFBA6B),
                                        Color(0xFF9E7D3B),
                                      ],
                                    )
                                  : null,
                              color: (_isHotelApartment == true)
                                  ? null
                                  : (isExpired
                                        ? Colors.grey
                                        : AppTheme.brandPrimary),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                minimumSize: const Size(double.infinity, 30),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: isExpired
                                  ? null
                                  : () => _handleRemainingPayment(context),
                              child: Text(
                                "Pay Now",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: (_isHotelApartment == true)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: (_isHotelApartment == true)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildTermsRow(context, isDark),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTermsRow(BuildContext context, bool isDark) {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _acceptedTerms,
              onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
              activeColor: (_isHotelApartment == true)
                  ? const Color(0xFFDFBA6B)
                  : Colors.teal,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  TextSpan(
                    text: 'شروط الخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: (_isHotelApartment == true)
                          ? const Color(0xFFDFBA6B)
                          : Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final uri = Uri.parse(RemoteConfigHelper.lekOraebUrl);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                  ),
                  const TextSpan(text: ' و '),
                  TextSpan(
                    text: 'سياسة الخصوصية',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: (_isHotelApartment == true)
                          ? const Color(0xFFDFBA6B)
                          : Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrivacyPolicyScreen(
                              isHotelApartment: _isHotelApartment == true,
                            ),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRemainingPayment(BuildContext context) async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب الموافقة على شروط الخدمة وسياسة الخصوصية أولاً',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String? localSelectedMethod = RemoteConfigHelper.showCardPayment
            ? 'card'
            : (RemoteConfigHelper.showWalletPayment ? 'wallet' : null);
        String? localWalletNumber;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose Payment Method",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!RemoteConfigHelper.showCardPayment &&
                      !RemoteConfigHelper.showWalletPayment) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
                    if (RemoteConfigHelper.showCardPayment)
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: localSelectedMethod == 'card'
                                ? ((_isHotelApartment == true)
                                      ? const Color(0xFFDFBA6B)
                                      : AppTheme.brandPrimary)
                                : Colors.grey.shade300,
                            width: localSelectedMethod == 'card' ? 2 : 1,
                          ),
                        ),
                        leading: Icon(
                          Icons.credit_card,
                          color:
                              localSelectedMethod == 'card' &&
                                  _isHotelApartment == true
                              ? const Color(0xFFDFBA6B)
                              : Colors.blue,
                        ),
                        title: Text(
                          "Credit/Debit Card",
                          style: GoogleFonts.cairo(
                            fontWeight: localSelectedMethod == 'card'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                localSelectedMethod == 'card' &&
                                    _isHotelApartment == true
                                ? const Color(0xFFDFBA6B)
                                : null,
                          ),
                        ),
                        trailing: localSelectedMethod == 'card'
                            ? Icon(
                                Icons.check_circle,
                                color: (_isHotelApartment == true)
                                    ? const Color(0xFFDFBA6B)
                                    : AppTheme.brandPrimary,
                              )
                            : null,
                        onTap: () => setState(() {
                          localSelectedMethod = 'card';
                          localWalletNumber = null;
                        }),
                      ),
                    if (RemoteConfigHelper.showCardPayment &&
                        RemoteConfigHelper.showWalletPayment)
                      const SizedBox(height: 10),
                    if (RemoteConfigHelper.showWalletPayment)
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: localSelectedMethod == 'wallet'
                                ? ((_isHotelApartment == true)
                                      ? const Color(0xFFDFBA6B)
                                      : AppTheme.brandPrimary)
                                : Colors.grey.shade300,
                            width: localSelectedMethod == 'wallet' ? 2 : 1,
                          ),
                        ),
                        leading: Icon(
                          Icons.account_balance_wallet,
                          color:
                              localSelectedMethod == 'wallet' &&
                                  _isHotelApartment == true
                              ? const Color(0xFFDFBA6B)
                              : Colors.orange,
                        ),
                        title: Text(
                          "Mobile Wallet",
                          style: GoogleFonts.cairo(
                            fontWeight: localSelectedMethod == 'wallet'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                localSelectedMethod == 'wallet' &&
                                    _isHotelApartment == true
                                ? const Color(0xFFDFBA6B)
                                : null,
                          ),
                        ),
                        trailing: localSelectedMethod == 'wallet'
                            ? Icon(
                                Icons.check_circle,
                                color: (_isHotelApartment == true)
                                    ? const Color(0xFFDFBA6B)
                                    : AppTheme.brandPrimary,
                              )
                            : null,
                        onTap: () =>
                            setState(() => localSelectedMethod = 'wallet'),
                      ),
                    if (localSelectedMethod == 'wallet') ...[
                      const SizedBox(height: 15),
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: "Wallet Number",
                          hintText: "01xxxxxxxxx",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.phone_android),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: (_isHotelApartment == true)
                                  ? const Color(0xFFDFBA6B)
                                  : AppTheme.brandPrimary,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => localWalletNumber = val,
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: (_isHotelApartment == true)
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFF3E5AB),
                                  Color(0xFFDFBA6B),
                                  Color(0xFF9E7D3B),
                                ],
                              )
                            : null,
                        color: (_isHotelApartment == true)
                            ? null
                            : AppTheme.brandPrimary,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (!RemoteConfigHelper.showCardPayment &&
                              !RemoteConfigHelper.showWalletPayment) {
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
                          if (localSelectedMethod == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'اختر طريقة الدفع أولاً',
                                  style: GoogleFonts.cairo(),
                                ),
                              ),
                            );
                            return;
                          }
                          if (localSelectedMethod == 'wallet' &&
                              (localWalletNumber == null ||
                                  !RegExp(
                                    r'^01[0-2,5]{1}[0-9]{8}$',
                                  ).hasMatch(localWalletNumber!))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'رقم المحفظة غير صحيح',
                                  style: GoogleFonts.cairo(),
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context, {
                            'method': localSelectedMethod,
                            'wallet': localWalletNumber,
                          });
                        },
                        child: Text(
                          "Continue",
                          style: GoogleFonts.cairo(
                            color: (_isHotelApartment == true)
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    final selectedMethod = result['method'];
    final walletNumber = result['wallet'];

    if (selectedMethod == null) return;
    if (selectedMethod == 'wallet' &&
        (walletNumber == null || walletNumber.length < 11)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid Wallet Number")));
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('createRemainingPayment')
          .call({
            'bookingId': widget.bookingId,
            'paymentMethod': selectedMethod,
            'walletNumber': walletNumber,
          });

      if (!context.mounted) return;
      Navigator.pop(context);

      final resData = result.data as Map<String, dynamic>;
      final paymentToken = resData['paymentToken'];
      final iframeId = resData['iframeId'];
      final paymentId = resData['paymentId'];
      final redirectUrl = resData['redirectUrl'];

      debugPrint("📱 [CLIENT] Remaining Payment Initiated");

      if (selectedMethod == 'wallet' && redirectUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentMethod: selectedMethod,
              paymentToken: "WALLET_TOKEN",
              iframeId: "WALLET_ID",
              paymentId: paymentId?.toString() ?? "",
              bookingId: widget.bookingId,
              paymentType: 'remaining',
              url: redirectUrl,
            ),
          ),
        );
      } else if (paymentToken != null && iframeId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentMethod: selectedMethod,
              paymentToken: paymentToken.toString(),
              iframeId: iframeId.toString(),
              paymentId: paymentId?.toString() ?? "",
              bookingId: widget.bookingId,
              paymentType: 'remaining',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment Error: ${e.toString()}")));
    }
  }

  Widget _buildVerticalDashedLine() {
    return SizedBox(
      height: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          4,
          (index) => Container(
            width: 2,
            height: 4,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(BuildContext context, String number, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive ? AppTheme.primaryGradient : null,
        color: isActive ? null : Colors.grey.shade300,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.brandPrimary.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          number,
          style: GoogleFonts.cairo(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String title,
    String amount,
    Color statusColor,
    String statusText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? propertyId) {
    if (propertyId == null) return const SizedBox.shrink();

    // TAJ HOUSE bookings reference `hotel_properties`, not `properties`.
    final isHotelBooking = widget.data['isHotelBooking'] == true;
    final collection = isHotelBooking ? 'hotel_properties' : 'properties';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection(collection)
          .doc(propertyId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final pData = snapshot.data!.data() as Map<String, dynamic>?;
        if (pData == null) {
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: const Icon(Icons.error_outline, color: Colors.red),
            ),
            title: Text(
              'عقار غير موجود',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              "ID: $propertyId",
              style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
            ),
          );
        }

        final title = pData['title'] ?? 'Unknown Property';

        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
              image:
                  (pData['images'] != null &&
                      (pData['images'] as List).isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage((pData['images'] as List)[0]),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                (pData['images'] == null || (pData['images'] as List).isEmpty)
                ? const Icon(Icons.home)
                : null,
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "ID: $propertyId",
            style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PropertyDetailsScreen(
                  property: Property.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>,
                    snapshot.data!.id,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime expiryDate;
  const CountdownTimer({super.key, required this.expiryDate});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    if (widget.expiryDate.isAfter(now)) {
      setState(() {
        _duration = widget.expiryDate.difference(now);
      });
    } else {
      setState(() {
        _duration = Duration.zero;
      });
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_duration.isNegative || _duration.inSeconds == 0) {
      return Text(
        "Expired",
        style: GoogleFonts.cairo(
          fontSize: 10,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final days = _duration.inDays;
    final hours = _duration.inHours % 24;
    final minutes = _duration.inMinutes % 60;

    String timeStr = "";
    if (days > 0) timeStr += "${days}d ";
    timeStr += "${hours}h ${minutes}m";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 12, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            "Remaining: $timeStr",
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
