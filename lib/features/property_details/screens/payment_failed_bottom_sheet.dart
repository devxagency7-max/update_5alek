import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentFailedBottomSheet extends StatelessWidget {
  final String? paymentMethod;
  final VoidCallback onRetry;
  final VoidCallback onSupport;

  const PaymentFailedBottomSheet({
    super.key,
    this.paymentMethod,
    required this.onRetry,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'فشلت عملية الدفع',
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            paymentMethod == 'wallet'
                ? 'لم نتمكن من إتمام العملية. يرجى التأكد من وجود رصيد كافٍ في محفظتك وكتابة الرقم السري الصحيح.'
                : 'لم نتمكن من إتمام العملية. يرجى التحقق من بيانات البطاقة أو المحاولة مرة أخرى.',
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onSupport,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Text(
                    'تواصل مع الدعم',
                    style: GoogleFonts.cairo(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008695),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'إعادة المحاولة',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
