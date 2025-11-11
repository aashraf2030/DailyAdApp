import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeProfile extends StatefulWidget{

  const HomeProfile({super.key});

  @override
  ProfilePageState createState () => ProfilePageState();
}

class ProfilePageState extends State<HomeProfile> {

  UserProfile profile = UserProfile();
  bool isGuest = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // فحص وضع الزائر
    final operationalCubit = BlocProvider.of<OperationalCubit>(context);
    isGuest = operationalCubit.isGuest();

    _loadProfile();
  }
  
  Future<void> _loadProfile({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() {
        isLoading = true;
      });
    }
    
    try {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      final fetchedProfile = await authCubit.getProfile(forceRefresh: forceRefresh);
      
      if (mounted) {
        setState(() {
          profile = fetchedProfile;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }
    
    return RefreshIndicator(
      onRefresh: () => _loadProfile(forceRefresh: true),
      color: Color(0xFF2596FA),
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // رسالة Pull to Refresh
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "اسحب لتحديث البيانات",
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Header احترافي مع صورة المستخدم
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2596FA), Color(0xFF364A62)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                    style: GoogleFonts.cairo(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2596FA),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '@${profile.username}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // بطاقة النقاط
        _buildPointsCard(),

        const SizedBox(height: 20),

        // معلومات الحساب
        Text(
          'معلومات الحساب',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF364A62),
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),

        _buildInfoCard(FontAwesomeIcons.envelope, 'البريد الإلكتروني', profile.email),
        _buildInfoCard(FontAwesomeIcons.phone, 'رقم الهاتف', profile.phone),
        _buildInfoCard(FontAwesomeIcons.calendarDays, 'تاريخ الانضمام', _formatDate(profile.join)),

        const SizedBox(height: 24),

        // الأزرار الرئيسية
        Text(
          'الإجراءات',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF364A62),
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),

        _buildActionButton(
          icon: FontAwesomeIcons.arrowRightArrowLeft,
          text: 'تبديل النقاط',
          color: const Color(0xFF2596FA),
          onPressed: () {
            if (isGuest) {
              showGuestWarning(context, 'تبديل النقاط');
            } else {
              exchangePoints(context);
            }
          },
        ),

        const SizedBox(height: 12),

        _buildActionButton(
          icon: FontAwesomeIcons.fileLines,
          text: 'طلباتي',
          color: const Color(0xFF364A62),
          onPressed: () => Navigator.pushNamed(context, "/my_request"),
        ),

        const SizedBox(height: 24),

        // أزرار الخطر (تظهر فقط للمستخدمين المسجلين)
        if (!isGuest) ...[
          _buildDangerButton(
            icon: FontAwesomeIcons.trash,
            text: 'حذف الحساب',
            onPressed: () => deleteAccount(context),
          ),

          const SizedBox(height: 12),

          _buildDangerButton(
            icon: FontAwesomeIcons.rightFromBracket,
            text: 'تسجيل الخروج',
            onPressed: () => logout(context),
          ),
        ],

        const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Skeleton للـ Header
        _buildSkeletonHeader(),
        
        const SizedBox(height: 24),
        
        // Skeleton لبطاقة النقاط
        _buildSkeletonPointsCard(),
        
        const SizedBox(height: 20),
        
        // عنوان قسم معلومات الحساب
        _buildSkeletonSectionTitle(),
        
        const SizedBox(height: 12),
        
        // Skeleton Cards للمعلومات
        _buildSkeletonInfoCard(),
        const SizedBox(height: 12),
        _buildSkeletonInfoCard(),
        const SizedBox(height: 12),
        _buildSkeletonInfoCard(),
        
        const SizedBox(height: 24),
        
        // عنوان قسم الإجراءات
        _buildSkeletonSectionTitle(),
        
        const SizedBox(height: 12),
        
        // Skeleton للأزرار
        _buildSkeletonButton(),
        const SizedBox(height: 12),
        _buildSkeletonButton(),
      ],
    );
  }
  
  // Skeleton للـ Header
  Widget _buildSkeletonHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar Skeleton
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            // Name Skeleton
            Container(
              width: 150,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            // Username Skeleton
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Skeleton لبطاقة النقاط
  Widget _buildSkeletonPointsCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSkeletonPointItem(),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[200],
            ),
            _buildSkeletonPointItem(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkeletonPointItem() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
  
  // Skeleton لعنوان القسم
  Widget _buildSkeletonSectionTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 120,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
  
  // Skeleton لبطاقة معلومات
  Widget _buildSkeletonInfoCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 150,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Skeleton للزر
  Widget _buildSkeletonButton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة النقاط
  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نقاطك',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${profile.points}',
                style: GoogleFonts.cairo(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.star,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // تحويل التاريخ والوقت إلى تاريخ فقط
  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime; // في حالة فشل التحويل، نعرض النص كما هو
    }
  }

  // بطاقة معلومة
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2596FA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              icon,
              color: const Color(0xFF2596FA),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF364A62),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // زر إجراء
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // زر خطر
  Widget _buildDangerButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        side: BorderSide(color: Colors.red.shade700, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void exchangePoints (context) async
  {
    final cubit = BlocProvider.of<AuthorityCubit>(context);

    final res = await cubit.exchangePoints();


    if (res)
      {
        BlocProvider.of<AuthCubit>(context).getProfile().then((x){

          setState(() {
            profile = x;
          });

        });
      }
    else
    {
      showError(context);
    }
  }

  // رسالة للزائر لما يحاول يستخدم ميزة تحتاج تسجيل دخول
  void showGuestWarning(context, String feature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2596FA).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.userLock,
                  color: Color(0xFF2596FA),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "تسجيل الدخول مطلوب",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: const Color(0xFF364A62),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          content: Text(
            "عذراً، أنت في وضع الزائر حالياً.\n\nبرجاء تسجيل الدخول أولاً حتى تتمكن من استخدام ميزة $feature",
            style: GoogleFonts.cairo(
              color: const Color(0xFF364A62),
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade400, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "إلغاء",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2596FA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "تسجيل الدخول",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showError(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.circleExclamation,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "خطأ",
                style: GoogleFonts.cairo(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            "يجب أن يتوفر في حسابك 1000 نقطة على الأقل لتبديل النقاط",
            style: GoogleFonts.cairo(
              color: const Color(0xFF364A62),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "حسناً",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void logout (context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AuthCubit(AuthInitial(), prefs).logout().then((x) {
      Navigator.pushReplacementNamed(context, "/login");
    } );
  }

  void deleteAccount(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.red.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "تأكيد حذف الحساب",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF364A62),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          content: Text(
            "هل أنت متأكد أنك تريد حذف حسابك نهائياً؟\n\nلن تتمكن من استرجاع بياناتك بعد الحذف!",
            style: GoogleFonts.cairo(
              color: Colors.red.shade700,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2596FA),
                      side: const BorderSide(color: Color(0xFF2596FA), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "تراجع",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      delete(context, prefs);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "حذف نهائياً",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void delete(context, prefs)
  {
    AuthCubit(AuthInitial(), prefs).delete().then((x) {
      Navigator.pushReplacementNamed(context, "/login");
    } );
  }
}
