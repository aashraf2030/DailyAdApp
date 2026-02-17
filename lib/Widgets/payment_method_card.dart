import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable widget for payment method card
class PaymentMethodCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final Widget? customIcon;
  final Widget? customBody;

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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2596FA).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF2596FA) : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
               BoxShadow(
                color: Color(0xFF2596FA).withOpacity(0.1), 
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            // Selection Indicator (Right side in RTL, Start in Row)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF2596FA) : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? Color(0xFF2596FA) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            
            Spacer(),

            // Content Section
            if (customBody != null)
              customBody!
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Align text to right (Start in RTL) ? No, typically text in Arabic is Right aligned.
                // But here we want the text block to naturally sit.
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Match Ads page boldness logic
                      color: Color(0xFF364A62), // Match Ads page color
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
            
            SizedBox(width: 16),
            
            // Icon Section (Left side in RTL, End in Row)
            if (customIcon != null)
              customIcon!
            else
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (color?.withOpacity(0.1) ?? Color(0xFF2596FA).withOpacity(0.1))
                      : color?.withOpacity(0.1) ?? Colors.grey.shade200,
                   borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? (color ?? Color(0xFF2596FA)) : (color ?? Colors.grey.shade700),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
