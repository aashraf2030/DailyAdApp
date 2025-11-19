import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Models/authority_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class MyRequestPage extends StatefulWidget {
  const MyRequestPage({super.key});

  @override
  MyRequestPageState createState() => MyRequestPageState();
}

class MyRequestPageState extends State<MyRequestPage> with TickerProviderStateMixin {
  List<UserRequest> requests = [];
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showNoData = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();

    // بعد 3 ثواني، إذا لم يتم تحميل البيانات، نعرض "لا توجد طلبات"
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _isLoading && requests.isEmpty) {
        setState(() {
          _showNoData = true;
          _isLoading = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        BlocProvider.of<AuthorityCubit>(context).getMyRequest();
      } catch (e) {
        print('Error loading requests: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              child: Column(
                children: [
                  _buildStatsCards(),
                  SizedBox(height: 16),
                  _buildTabBar(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          BlocBuilder<AuthorityCubit, AuthorityState>(
            builder: (context, state) => _buildRequestsList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            BlocProvider.of<AuthorityCubit>(context).getMyRequest();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "طلباتي",
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
                right: -40,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -60,
                bottom: -60,
                child: Container(
                  width: 220,
                  height: 220,
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

  Widget _buildStatsCards() {
    final createRequests = requests.where((r) => (r as MyRequest).type == "Create").length;
    final renewRequests = requests.where((r) => (r as MyRequest).type == "Renew").length;
    final moneyRequests = requests.where((r) => (r as MyRequest).type == "Money").length;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "إنشاء",
              createRequests.toString(),
              FontAwesomeIcons.circlePlus,
              Color(0xFF2596FA),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "تجديد",
              renewRequests.toString(),
              FontAwesomeIcons.arrowsRotate,
              Color(0xFF27AE60),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "أموال",
              moneyRequests.toString(),
              FontAwesomeIcons.moneyBill,
              Color(0xFFE67E22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Color(0xFF2596FA), Color(0xFF364A62)],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: "الكل"),
          Tab(text: "قيد المراجعة"),
          Tab(text: "نشط"),
        ],
      ),
    );
  }

  Widget _buildRequestsList(AuthorityState state) {
    if (state is AuthorityLoading || (_isLoading && !_showNoData)) {
      return SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: _buildSkeletonLoader(),
      );
    } else if (state is AuthorityRequestDone) {
      requests = state.data;
      _isLoading = false;
      _showNoData = false;
      
      if (requests.isEmpty || _showNoData) {
        return SliverFillRemaining(
          child: _buildEmptyState(),
        );
      }

      final filteredRequests = _getFilteredRequests();

      if (filteredRequests.isEmpty) {
        return SliverFillRemaining(
          child: _buildEmptyState(),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final request = filteredRequests[index] as MyRequest;
              return _buildRequestCard(request, index);
            },
            childCount: filteredRequests.length,
          ),
        ),
      );
    } else if (_showNoData) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    } else {
      return SliverFillRemaining(
        child: _buildErrorState(),
      );
    }
  }

  List<UserRequest> _getFilteredRequests() {
    // Tab 0: All requests
    // Tab 1: Pending requests (Create, Renew)
    // Tab 2: Active/Money requests
    
    if (_tabController.index == 0) {
      return requests;
    } else if (_tabController.index == 1) {
      return requests.where((r) {
        final req = r as MyRequest;
        return req.type == "Create" || req.type == "Renew";
      }).toList();
    } else {
      return requests.where((r) {
        final req = r as MyRequest;
        return req.type == "Money";
      }).toList();
    }
  }

  Widget _buildRequestCard(MyRequest request, int index) {
    final color = _getRequestColor(request.type);
    final icon = _getRequestIcon(request.type);
    final statusText = _getRequestStatusText(request.type);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showRequestDetails(request);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(icon, color: color, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.adName,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(height: 4),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatDate(request.creation),
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (request.type != "Money")
                      IconButton(
                        onPressed: () => _showDeleteDialog(request),
                        icon: Icon(Icons.delete_outline),
                        color: Colors.red.shade400,
                        iconSize: 22,
                      ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.category,
                        "النوع",
                        _getRequestTypeArabic(request.type),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.shade300,
                      ),
                      _buildInfoItem(
                        Icons.schedule,
                        "الحالة",
                        request.type == "Money" ? "تم" : "قيد المراجعة",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: Color(0xFF2596FA)),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
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
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        // Icon placeholder
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title placeholder
                              Container(
                                width: double.infinity,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              SizedBox(height: 8),
                              // Subtitle placeholder
                              Container(
                                width: 120,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        // Button placeholder
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    // Info box placeholder
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: 4, // عرض 4 skeleton cards
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFF2596FA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.folderOpen,
              size: 60,
              color: Color(0xFF2596FA),
            ),
          ),
          SizedBox(height: 24),
          Text(
            "لا توجد طلبات",
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "عندما تنشئ إعلانات جديدة\nستظهر طلباتك هنا",
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16),
          Text(
            "حدث خطأ في التحميل",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              BlocProvider.of<AuthorityCubit>(context).getMyRequest();
            },
            icon: Icon(Icons.refresh),
            label: Text(
              "إعادة المحاولة",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2596FA),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(MyRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "تفاصيل الطلب",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 20),
            _buildDetailRow("اسم الإعلان", request.adName),
            _buildDetailRow("نوع الطلب", _getRequestTypeArabic(request.type)),
            _buildDetailRow("تاريخ الإنشاء", _formatDate(request.creation)),
            _buildDetailRow("الحالة", request.type == "Money" ? "تم التنفيذ" : "قيد المراجعة"),
            SizedBox(height: 20),
            if (request.type != "Money")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteDialog(request);
                  },
                  icon: Icon(Icons.delete),
                  label: Text(
                    "حذف الطلب",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(MyRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_forever, color: Colors.red, size: 40),
            ),
            SizedBox(height: 16),
            Text(
              "حذف الطلب",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Text(
          "هل أنت متأكد من حذف هذا الطلب؟\n\nلن تتمكن من استرجاعه بعد الحذف.",
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "إلغاء",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await BlocProvider.of<AuthorityCubit>(context)
                        .deleteRequest(request.id);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم حذف الطلب بنجاح",
                            style: GoogleFonts.cairo(),
                            textDirection: TextDirection.rtl,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "حذف",
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRequestColor(String type) {
    switch (type) {
      case "Create":
        return Color(0xFF2596FA);
      case "Renew":
        return Color(0xFF27AE60);
      case "Money":
        return Color(0xFFE67E22);
      default:
        return Colors.grey;
    }
  }

  IconData _getRequestIcon(String type) {
    switch (type) {
      case "Create":
        return FontAwesomeIcons.circlePlus;
      case "Renew":
        return FontAwesomeIcons.arrowsRotate;
      case "Money":
        return FontAwesomeIcons.moneyBill;
      default:
        return Icons.error;
    }
  }

  String _getRequestStatusText(String type) {
    switch (type) {
      case "Create":
        return "طلب إنشاء";
      case "Renew":
        return "طلب تجديد";
      case "Money":
        return "طلب مال";
      default:
        return "غير محدد";
    }
  }

  String _getRequestTypeArabic(String type) {
    switch (type) {
      case "Create":
        return "إنشاء إعلان";
      case "Renew":
        return "تجديد إعلان";
      case "Money":
        return "طلب مالي";
      default:
        return "غير محدد";
    }
  }

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
