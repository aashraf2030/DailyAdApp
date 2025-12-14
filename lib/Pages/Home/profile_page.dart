import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/auth_models.dart';
import 'package:ads_app/Models/saved_account_model.dart';
import 'package:ads_app/Widgets/account_switcher_widget.dart';
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
  List<SavedAccount> savedAccounts = [];
  SavedAccount? currentAccount;

  @override
  void initState() {
    super.initState();


    final operationalCubit = BlocProvider.of<OperationalCubit>(context);
    isGuest = operationalCubit.isGuest();

    _loadProfile();
    _loadSavedAccounts();
  }
  
  Future<void> _loadProfile({bool forceRefresh = false}) async {
    print("🔍 ProfilePage: Loading profile... (forceRefresh: $forceRefresh)");
    
    if (forceRefresh) {
      setState(() {
        isLoading = true;
      });
    }
    
    try {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      final operationalCubit = BlocProvider.of<OperationalCubit>(context);
      
      print("🔍 ProfilePage: Calling authCubit.getProfile()");
      
      final fetchedProfile = await authCubit.getProfile(forceRefresh: forceRefresh);
      
      print("✅ ProfilePage: Profile fetched successfully");
      print("   Name: ${fetchedProfile.name}");
      print("   Username: ${fetchedProfile.username}");
      print("   Points: ${fetchedProfile.points}");
      
      // تحديث حالة الزائر بعد جلب البيانات
      final isGuestMode = operationalCubit.isGuest();
      print("   Is Guest: $isGuestMode");
      
      if (mounted) {
        setState(() {
          profile = fetchedProfile;
          isGuest = isGuestMode;  // تحديث حالة الزائر
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ ProfilePage: Error loading profile: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSavedAccounts() async {
    try {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      final accounts = await authCubit.getSavedAccounts();
      final current = await authCubit.getCurrentAccount();
      
      if (mounted) {
        setState(() {
          savedAccounts = accounts;
          currentAccount = current;
        });
      }
    } catch (e) {
      print('Error loading saved accounts: $e');
    }
  }

  Future<void> _switchAccount(SavedAccount account) async {
    try {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF2596FA),
              ),
            ),
          ),
        ),
      );

      final success = await authCubit.switchAccount(account);
      
      Navigator.of(context).pop(); // Close loading
      
      if (success) {
        // Reload profile and accounts
        await _loadProfile(forceRefresh: true);
        await _loadSavedAccounts();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم التبديل إلى حساب ${account.name} بنجاح',
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل التبديل إلى الحساب. يرجى المحاولة مرة أخرى',
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading if still open
      print('Error switching account: $e');
    }
  }

  Future<void> _deleteAccount(SavedAccount account) async {
    try {
      final authCubit = BlocProvider.of<AuthCubit>(context);
      final success = await authCubit.removeSavedAccount(account);
      
      if (success) {
        await _loadSavedAccounts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف الحساب بنجاح',
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error deleting account: $e');
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


        _buildPointsCard(),

        const SizedBox(height: 20),


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

        // Saved Accounts Section
        if (!isGuest && savedAccounts.isNotEmpty) ...[
          AccountSwitcherWidget(
            accounts: savedAccounts,
            currentAccount: currentAccount,
            onAccountTap: _switchAccount,
            onAccountDelete: _deleteAccount,
            onAddAccount: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 24),
        ],

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

        _buildSkeletonHeader(),
        
        const SizedBox(height: 24),
        

        _buildSkeletonPointsCard(),
        
        const SizedBox(height: 20),
        

        _buildSkeletonSectionTitle(),
        
        const SizedBox(height: 12),
        

        _buildSkeletonInfoCard(),
        const SizedBox(height: 12),
        _buildSkeletonInfoCard(),
        const SizedBox(height: 12),
        _buildSkeletonInfoCard(),
        
        const SizedBox(height: 24),
        

        _buildSkeletonSectionTitle(),
        
        const SizedBox(height: 12),
        

        _buildSkeletonButton(),
        const SizedBox(height: 12),
        _buildSkeletonButton(),
      ],
    );
  }
  

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

            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: 150,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),

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
                _formatPoints(profile.points),
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


  String _formatDate(String dateTime) {
    try {

      final date = DateTime.parse(dateTime);
      

      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {

      return dateTime;
    }
  }

  String _formatPoints(double points) {
    // If points is a whole number, show without decimals
    // Otherwise show with 1 decimal place
    if (points == points.truncateToDouble()) {
      return points.toInt().toString();
    } else {
      return points.toStringAsFixed(1);
    }
  }

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
    BlocProvider.of<AuthCubit>(context).logout().then((x) {
      Navigator.pushReplacementNamed(context, "/login");
    } );
  }

  void deleteAccount(context) async {
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
                      delete(context);
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

  void delete(context)
  {
    BlocProvider.of<AuthCubit>(context).delete().then((x) {
      Navigator.pushReplacementNamed(context, "/login");
    } );
  }
}
