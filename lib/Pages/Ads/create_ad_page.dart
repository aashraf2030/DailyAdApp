import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Pages/Ads/ad_payment_selection_page.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/category_manager.dart';
import 'package:ads_app/Widgets/image_picker_button.dart';
import 'package:ads_app/Widgets/input_text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ads_app/Widgets/gradient_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ads_app/core/ad_pricing_config.dart';

class CreateAdPage extends StatefulWidget {
  CreateAdPage({super.key});

  InputTextForm name = InputTextForm("اسم الاعلان", FontAwesomeIcons.rectangleAd);
  // InputTextForm target removed in favor of dropdown in state
  InputTextForm keys = InputTextForm("كلمات مفتاحية", FontAwesomeIcons.key);
  InputTextForm link = InputTextForm("رابط الاعلان", FontAwesomeIcons.link);
  int category = 11; // متنوع (Other) كقيمة افتراضية
  int type = 0; // Dynamic للمستخدمين العاديين

  ImagePickerButton picker = ImagePickerButton("اختار الصورة", FontAwesomeIcons.image);

  @override
  CreateAdPageState createState() => CreateAdPageState();
}

class CreateAdPageState extends State<CreateAdPage> with SingleTickerProviderStateMixin {
  bool isSending = false;
  bool isAdmin = false;
  final TextEditingController _viewsController = TextEditingController();
  double _priceEstimate = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Fetch pricing when page loads
    context.read<OperationalCubit>().repo.fetchPricing().then((_) {
      if(mounted) setState(() {});
    });
    
    _viewsController.addListener(() {
      setState(() {
        int views = int.tryParse(_viewsController.text) ?? 0;
        _priceEstimate = AdPricingConfig.calculatePrice(views);
      });
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    BlocProvider.of<AuthCubit>(context).isAdmin().then((x) {
      setState(() {
        isAdmin = x;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _viewsController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "إنشاء إعلان جديد",
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        gradient: LinearGradient(
          colors: [
            Color(0xFF2596FA),
            Color(0xFF364A62),
          ],
          transform: GradientRotation(0.5),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_forward_outlined, color: Colors.white),
          )
        ],
      ),
      backgroundColor: Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: buildMenu(context),
          ),
        ),
      ),
    );
  }

  List<Widget> buildMenu(BuildContext context) {
    List<Widget> res = [
      // Header Section
      _buildHeader(),
      
      SizedBox(height: 24),

      // معلومات الإعلان الأساسية
      _buildSectionTitle("معلومات الإعلان", FontAwesomeIcons.rectangleAd),
      SizedBox(height: 12),
      _buildCard([
        widget.name,
        SizedBox(height: 16),
        widget.link,
      ]),

      SizedBox(height: 24),

      // صورة الإعلان
      _buildSectionTitle("صورة الإعلان", FontAwesomeIcons.image),
      SizedBox(height: 12),
      _buildCard([widget.picker]),

      SizedBox(height: 24),

      // التفاصيل
      _buildSectionTitle("التفاصيل", FontAwesomeIcons.circleInfo),
      SizedBox(height: 12),
      _buildCard([
        // _buildViewsDropdown(), // Replaced by text field
        SizedBox(height: 16),
                      
        // Target Views Input
        Text(
          "عدد المشاهدات المستهدفة (أقل عدد ${AdPricingConfig.minViews})",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _viewsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "أدخل عدد المشاهدات",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixText: "مشاهدة",
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "الرجاء إدخال عدد المشاهدات";
            }
            int? views = int.tryParse(value);
            if (views == null) {
               return "الرجاء إدخال رقم صحيح";
            }
            if (views < AdPricingConfig.minViews) {
               return "أقل عدد مشاهدات هو ${AdPricingConfig.minViews}";
            }
            return null;
          },
        ),
        SizedBox(height: 8),
        Text(
          "التكلفة التقديرية: ${_priceEstimate.toStringAsFixed(2)} ${AdPricingConfig.currency}",
          style: GoogleFonts.cairo(
            color: Color(0xFF2596FA),
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),

      SizedBox(height: 24),

      // فئة الإعلان
      _buildSectionTitle("فئة الإعلان", FontAwesomeIcons.layerGroup),
      SizedBox(height: 12),
      _buildCard([
        _buildCategoryDropdown(),
      ]),
    ];

    // عرض اختيار نوع الإعلان للأدمن فقط
    if (isAdmin) {
      res.addAll([
        SizedBox(height: 24),
        _buildSectionTitle("نوع الإعلان", FontAwesomeIcons.arrowsUpToLine),
        SizedBox(height: 12),
        _buildCard([
          _buildTypeDropdown(),
        ]),
      ]);
    }

    res.addAll([
      SizedBox(height: 24),

      // كلمات مفتاحية
      _buildSectionTitle("تحسين الظهور", FontAwesomeIcons.hashtag),
      SizedBox(height: 12),
      _buildCard([widget.keys]),

      SizedBox(height: 32),

      // Submit Button
      buildSubmitButton(),
      
      SizedBox(height: 24),
    ]);

    return res;
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2596FA),
            Color(0xFF364A62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2596FA).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FontAwesomeIcons.bullhorn,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "أنشئ إعلانك الآن",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "املأ البيانات التالية لإنشاء إعلان احترافي",
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF2596FA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Color(0xFF2596FA),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField(
      items: buildCategories(),
      onChanged: (x) {
        widget.category = x ?? -1;
      },
      hint: Text(
        "اختر فئة الإعلان",
        style: GoogleFonts.cairo(color: Colors.grey.shade600),
      ),
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2596FA)),
      style: GoogleFonts.cairo(color: Color(0xFF2C3E50), fontSize: 15),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2596FA), width: 2),
        ),
        prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF2596FA)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField(
      items: [
        DropdownMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(FontAwesomeIcons.shuffle, size: 16, color: Color(0xFF2596FA)),
              SizedBox(width: 12),
              Text("متغيير", style: GoogleFonts.cairo()),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(FontAwesomeIcons.thumbtack, size: 16, color: Color(0xFF2596FA)),
              SizedBox(width: 12),
              Text("ثابت", style: GoogleFonts.cairo()),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(FontAwesomeIcons.crown, size: 16, color: Colors.amber),
              SizedBox(width: 12),
              Text("مميز", style: GoogleFonts.cairo()),
            ],
          ),
        ),
      ],
      onChanged: (x) {
        widget.type = x ?? 0;
      },
      value: 0,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2596FA)),
      style: GoogleFonts.cairo(color: Color(0xFF2C3E50), fontSize: 15),
      decoration: InputDecoration(
        labelText: "نوع الإعلان",
        labelStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2596FA), width: 2),
        ),
        prefixIcon: Icon(FontAwesomeIcons.arrowsUpToLine, color: Color(0xFF2596FA)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  // This method is no longer used as a TextFormField is used instead
  Widget _buildViewsDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedViews,
      items: AdPricingConfig.pricingTiers.entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Row(
            children: [
              Icon(FontAwesomeIcons.eye, size: 16, color: Color(0xFF2596FA)),
              SizedBox(width: 12),
              Text(
                "${entry.key} مشاهدة - ${entry.value} ر.س",
                style: GoogleFonts.cairo(),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            selectedViews = val;
          });
        }
      },
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2596FA)),
      style: GoogleFonts.cairo(color: Color(0xFF2C3E50), fontSize: 15),
      decoration: InputDecoration(
        labelText: "عدد المشاهدات",
        labelStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2596FA), width: 2),
        ),
        prefixIcon: Icon(FontAwesomeIcons.layerGroup, color: Color(0xFF2596FA)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  List<DropdownMenuItem> buildCategories() {
    List<DropdownMenuItem> res = [];

    for (var cat in CategoryManager.getAllCategories()) {
      if (cat.id == 0) {
        continue;
      }

      res.add(
        DropdownMenuItem(
          value: cat.id,
          child: Row(
            children: [
              Icon(cat.icon, size: 18, color: Color(0xFF2596FA)),
              SizedBox(width: 12),
              Text(cat.name, style: GoogleFonts.cairo()),
            ],
          ),
        ),
      );
    }

    return res;
  }

  Widget buildSubmitButton() {
    if (!isSending) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Color(0xFF2596FA),
              Color(0xFF364A62),
            ],
          ),
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
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              submit(context);
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    "إضافة الإعلان",
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
    } else {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF2596FA),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(width: 16),
              Text(
                "جارٍ الإنشاء...",
                style: GoogleFonts.cairo(
                  color: Color(0xFF2596FA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void submit(BuildContext context) async {
    setState(() {
      isSending = true;
    });

    if (widget.name.out.isEmpty ||
        !widget.picker.imageIsSelected ||
        widget.link.out.isEmpty ||
        widget.keys.out.isEmpty ||
        _viewsController.text.isEmpty) { // Added check for views controller
      showErrorMessage(context, "بيانات الإعلان غير مكتملة", "برجاء ملء جميع الحقول المطلوبة");
      setState(() {
        isSending = false;
      });
    } else if (!Uri.parse(widget.link.out).isAbsolute) {
      showErrorMessage(context, "رابط الإعلان غير صالح", "برجاء إدخال رابط صحيح يبدأ بـ https://");
      setState(() {
        isSending = false;
      });
    } else {
      int? target = int.tryParse(_viewsController.text);
      if (target == null || target < AdPricingConfig.minViews) {
        showErrorMessage(context, "عدد المشاهدات غير صالح", "برجاء إدخال عدد مشاهدات صحيح لا يقل عن ${AdPricingConfig.minViews}");
        setState(() {
          isSending = false;
        });
        return;
      }

      // Map Type
      String adType = "Dynamic";
      if (widget.type == 1) {
        adType = "Fixed";
      } else if (widget.type == 2) {
        adType = "Premium";
      }

      setState(() {
        isSending = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: BlocProvider.of<OperationalCubit>(context),
            child: AdPaymentSelectionPage(
              name: widget.name.out,
              imagePath: widget.picker.out!.path,
              imageName: widget.picker.out!.name,
              adLink: widget.link.out,
              type: adType,
              targetViews: target,
              category: widget.category,
              keywords: widget.keys.out,
            ),
          ),
        ),
      );
    }
  }

  void showSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.circleCheck,
                    color: Colors.green.shade600,
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "تم بنجاح!",
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "تم إنشاء إعلانك بنجاح\nسيتم مراجعته قريباً",
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // The provided snippet for onTap was syntactically incorrect.
                        // Assuming the intent was to add a check before navigating,
                        // but placing it here in a success dialog's "Awesome!" button
                        // doesn't make logical sense.
                        // Reverting to original onTap logic for success message.
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text(
                          "رائع!",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.red.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.red.shade600,
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  message,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Color(0xFF2596FA), Color(0xFF364A62)],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text(
                          "محاولة مرة أخرى",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```
