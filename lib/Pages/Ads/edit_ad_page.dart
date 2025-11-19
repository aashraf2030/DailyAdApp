import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../Bloc/Auth/auth_cubit.dart';

class EditAdPage extends StatefulWidget {
  const EditAdPage({super.key, required this.ad});

  final AdData ad;

  @override
  EditAdPageState createState() => EditAdPageState();
}

class EditAdPageState extends State<EditAdPage> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _keysController;
  late TextEditingController _linkController;
  
  int _selectedCategory = 11;
  int _selectedType = 0;
  bool _changeImage = false;
  XFile? _newImage;
  
  bool _isSending = false;
  bool _isAdmin = false;
  
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.ad.name);
    _targetController = TextEditingController(text: widget.ad.targetViews.toString());
    _keysController = TextEditingController(text: widget.ad.keywords);
    _linkController = TextEditingController(text: widget.ad.path);
    _selectedCategory = 11;
    _selectedType = widget.ad.isFixed ? 1 : 0;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    
    BlocProvider.of<AuthCubit>(context).isAdmin().then((x) {
      if (mounted) {
        setState(() {
          _isAdmin = x;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _keysController.dispose();
    _linkController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCurrentAdInfo(),
                    
                    SizedBox(height: 24),
                    
                    _buildEditForm(),
                    
                    SizedBox(height: 32),
                    
                    _buildSubmitButton(),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "تعديل الإعلان",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2596FA),
                Color(0xFF364A62),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -50,
                bottom: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAdInfo() {
    final progress = widget.ad.targetViews > 0 
      ? (widget.ad.views / widget.ad.targetViews).clamp(0.0, 1.0)
      : 0.0;
      
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.ad.isFixed ? Colors.redAccent : Color(0xFF2596FA),
            widget.ad.isFixed ? Colors.red.shade700 : Color(0xFF364A62),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (widget.ad.isFixed ? Colors.redAccent : Color(0xFF2596FA)).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    widget.ad.isFixed ? Icons.star : Icons.flash_on,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.ad.name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.ad.isFixed ? "ثابت" : "ديناميكي",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.visibility,
                "${widget.ad.views}",
                "المشاهدات",
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                Icons.flag,
                "${widget.ad.targetViews}",
                "الهدف",
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                Icons.trending_up,
                "${(progress * 100).toStringAsFixed(0)}%",
                "التقدم",
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تعديل البيانات",
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textDirection: TextDirection.rtl,
          ),
          
          SizedBox(height: 24),
          
          _buildTextField(
            controller: _nameController,
            label: "اسم الإعلان",
            icon: FontAwesomeIcons.rectangleAd,
            hint: "أدخل اسم الإعلان",
          ),
          
          SizedBox(height: 20),
          
          _buildTextField(
            controller: _linkController,
            label: "رابط الإعلان",
            icon: FontAwesomeIcons.link,
            hint: "https://example.com",
            keyboardType: TextInputType.url,
          ),
          
          SizedBox(height: 20),
          
          _buildImageSection(),
          
          SizedBox(height: 20),
          
          _buildTextField(
            controller: _targetController,
            label: "عدد المشاهدات المطلوبة",
            icon: FontAwesomeIcons.streetView,
            hint: "مثال: 1000",
            keyboardType: TextInputType.number,
          ),
          
          SizedBox(height: 20),
          
          if (_isAdmin) ...[
            _buildTypeDropdown(),
            SizedBox(height: 20),
          ],
          
          SizedBox(height: 20),
          
          _buildTextField(
            controller: _keysController,
            label: "الكلمات المفتاحية",
            icon: FontAwesomeIcons.key,
            hint: "مثال: تسويق، إعلانات",
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            fontSize: 15,
            color: Color(0xFF2C3E50),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: Color(0xFF2596FA), size: 20),
            filled: true,
            fillColor: Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF2596FA), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: Text(
            "صورة الإعلان",
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            children: [
              if (!_changeImage)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: FadeInImage.assetNetwork(
                    placeholder: "assets/imgs/Loading.gif",
                    image: widget.ad.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey.shade500),
                      );
                    },
                  ),
                ),
              
              if (_changeImage && _newImage != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 60),
                        SizedBox(height: 8),
                        Text(
                          "تم اختيار صورة جديدة",
                          style: GoogleFonts.cairo(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _newImage!.name,
                          style: GoogleFonts.cairo(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickNewImage,
                        icon: Icon(Icons.photo_library, size: 20),
                        label: Text(
                          _changeImage ? "تغيير الصورة" : "اختر صورة جديدة",
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2596FA),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    if (_changeImage) ...[
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _changeImage = false;
                            _newImage = null;
                          });
                        },
                        child: Icon(Icons.close, size: 20),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(50, 50),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickNewImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImage = image;
        _changeImage = true;
      });
    }
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: Text(
            "فئة الإعلان",
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        DropdownButtonFormField<int>(
          value: _selectedCategory,
          items: CategoryManager.getAllCategories()
              .where((cat) => cat.id != 0)
              .map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text(
                      cat.name,
                      style: GoogleFonts.cairo(),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value ?? -1;
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category, color: Color(0xFF2596FA)),
            filled: true,
            fillColor: Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF2596FA), width: 2),
            ),
          ),
          style: GoogleFonts.cairo(color: Color(0xFF2C3E50)),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8, bottom: 8),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.orange, size: 18),
              SizedBox(width: 6),
              Text(
                "نوع الإعلان (للمسؤولين فقط)",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        DropdownButtonFormField<int>(
          value: _selectedType,
          items: [
            DropdownMenuItem(
              value: 0,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.flash_on, color: Color(0xFF2596FA), size: 20),
                  SizedBox(width: 8),
                  Text("ديناميكي", style: GoogleFonts.cairo()),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 1,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.star, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text("ثابت", style: GoogleFonts.cairo()),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedType = value ?? 0;
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(FontAwesomeIcons.arrowsUpToLine, color: Colors.orange),
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.orange.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
          style: GoogleFonts.cairo(color: Color(0xFF2C3E50)),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2596FA),
            Color(0xFF364A62),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2596FA).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _isSending ? null : _submit,
          child: Center(
            child: _isSending
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "جاري الحفظ...",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "حفظ التعديلات",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      _showErrorDialog("اسم الإعلان مطلوب");
      return;
    }

    if (_linkController.text.isEmpty || !Uri.parse(_linkController.text).isAbsolute) {
      _showErrorDialog("رابط الإعلان غير صالح");
      return;
    }

    if (_keysController.text.isEmpty) {
      _showErrorDialog("الكلمات المفتاحية مطلوبة");
      return;
    }

    int targetViews;
    try {
      targetViews = int.parse(_targetController.text);
      if (targetViews < 50) {
        _showErrorDialog("عدد المشاهدات يجب أن يكون 50 على الأقل");
        return;
      }
    } catch (e) {
      _showErrorDialog("عدد المشاهدات غير صالح");
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final cubit = BlocProvider.of<OperationalCubit>(context);
      
      final success = await cubit.editAd(
        widget.ad.id,
        _nameController.text,
        _changeImage ? _newImage?.path : null,
        _changeImage && _newImage != null ? _newImage!.name : "",
        _linkController.text,
        _selectedType == 1 ? "Fixed" : "Dynamic",
        targetViews,
        _selectedCategory,
        _keysController.text,
      );

      if (mounted) {
        if (success) {
          _showSuccessDialog();
        } else {
          _showErrorDialog("فشل في تعديل الإعلان. حاول مرة أخرى.");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("حدث خطأ غير متوقع");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 12),
            Text(
              "خطأ",
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Color(0xFF2C3E50),
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "حسناً",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2596FA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "تم التعديل بنجاح!",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "تم حفظ تعديلاتك على الإعلان",
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "رائع!",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
