import 'package:ads_app/Models/category_manager.dart';
import 'package:flutter/material.dart';
import 'package:ads_app/Pages/Store/store_page.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryButton extends StatefulWidget {
  const CategoryButton(this.id, {super.key});

  final int id;

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  
  List<Color> _getGradientColors() {
    final gradients = [
      [Color(0xFF667eea), Color(0xFF764ba2)], 
      [Color(0xFFf093fb), Color(0xFFf5576c)], 
      [Color(0xFF4facfe), Color(0xFF00f2fe)], 
      [Color(0xFF43e97b), Color(0xFF38f9d7)], 
      [Color(0xFFfa709a), Color(0xFFfee140)], 
      [Color(0xFF30cfd0), Color(0xFF330867)], 
      [Color(0xFFa8edea), Color(0xFFfed6e3)], 
      [Color(0xFFff9a9e), Color(0xFFfecfef)], 
      [Color(0xFFffecd2), Color(0xFFfcb69f)], 
      [Color(0xFFff6e7f), Color(0xFFbfe9ff)], 
    ];
    return gradients[widget.id % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final category = CategoryManager.getSearchCategoryById(widget.id);
    final colors = _getGradientColors();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        clicked(context);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 0,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => clicked(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: Icon(
                        category.icon,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    
                    Flexible(
                      child: Text(
                        category.name,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    SizedBox(height: 4),
                    
                    
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void clicked(context) {
    if (widget.id == 12) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => StorePage()));
      return;
    }
    Navigator.pushNamed(context, "/show_cat",
        arguments: CategoryManager.getSearchCategoryById(widget.id));
  }
}