import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable widget for payment method card.
/// When [isApplePay] is true, the card background stays white and the
/// Apple Pay mark area is never recolored — required by Apple HIG (Guideline 4.9).
class PaymentMethodCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final Widget? customIcon;
  final Widget? customBody;
  final bool isApplePay;

  const PaymentMethodCard({
    super.key,
    this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.color,
    this.customIcon,
    this.customBody,
    this.isApplePay = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ HIG compliance: Apple Pay card background must always be white.
    // Never apply a tinted/colored overlay on top of Apple Pay branding.
    final cardColor = isApplePay
        ? Colors.white
        : (isSelected ? const Color(0xFF2596FA).withOpacity(0.1) : Colors.white);

    final borderColor = isSelected
        ? const Color(0xFF2596FA)
        : Colors.grey.shade300;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            if (isSelected && !isApplePay)
              BoxShadow(
                color: const Color(0xFF2596FA).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2596FA)
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF2596FA)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),

            const Spacer(),

            // Content section
            if (customBody != null)
              customBody!
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: const Color(0xFF364A62),
                    ),
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),

            const SizedBox(width: 16),

            // Icon section
            // ✅ HIG: when isApplePay, render the mark on a plain white
            // background with NO additional decoration or color overlay.
            if (customIcon != null)
              isApplePay
                  ? customIcon! // already a RawApplePayButton — no extra wrapping
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (color?.withOpacity(0.1) ??
                                const Color(0xFF2596FA).withOpacity(0.1))
                            : color?.withOpacity(0.1) ??
                                Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: customIcon,
                    )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (color?.withOpacity(0.1) ??
                          const Color(0xFF2596FA).withOpacity(0.1))
                      : color?.withOpacity(0.1) ?? Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (color ?? const Color(0xFF2596FA))
                      : (color ?? Colors.grey.shade700),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
