import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable widget for payment method card
class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final Widget? customIcon;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.color,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2596FA).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF2596FA) : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Color(0xFF2596FA).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
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

            // Icon Section
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Color(0xFF2596FA) 
                    : color ?? Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: customIcon ?? Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            
            // Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Color(0xFF2596FA) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
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
          ],
        ),
      ),
    );
  }
}
