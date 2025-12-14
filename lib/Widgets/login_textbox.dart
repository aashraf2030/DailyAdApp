import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginTextbox extends StatefulWidget{
  LoginTextbox({super.key, required this.padding, required this.icon, required this.hint, this.isPassword = false, this.initialValue});
  final double padding;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final String? initialValue;

  String data = "";

  @override
  TextboxState createState () => TextboxState();
}

class TextboxState extends State<LoginTextbox> {
  bool _isFocused = false;
  bool _isPasswordVisible = false;
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? "");
    widget.data = widget.initialValue ?? ""; // Initialize data
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.padding * 0.6),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused 
              ? Color.fromRGBO(37, 150, 250, 1)
              : Colors.grey.shade300,
            width: _isFocused ? 2 : 1.5,
          ),
          boxShadow: _isFocused ? [
            BoxShadow(
              color: Color.fromRGBO(37, 150, 250, 0.2),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ] : [],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isFocused 
                    ? Color.fromRGBO(37, 150, 250, 0.1)
                    : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  widget.icon,
                  size: 18,
                  color: _isFocused 
                    ? Color.fromRGBO(37, 150, 250, 1)
                    : Color.fromRGBO(102, 134, 180, 1),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Text Field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textDirection: TextDirection.rtl,
                  enableSuggestions: false,
                  autocorrect: false,
                  obscureText: widget.isPassword && !_isPasswordVisible,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    border: InputBorder.none,
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: GoogleFonts.cairo(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (str) {
                    widget.data = str;
                  },
                ),
              ),
              
              // Password visibility toggle
              if (widget.isPassword)
                IconButton(
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                  icon: FaIcon(
                    _isPasswordVisible 
                      ? FontAwesomeIcons.eye 
                      : FontAwesomeIcons.eyeSlash,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}