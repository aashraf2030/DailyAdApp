import 'dart:async';
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Models/authority_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class AdminAdRequestPage extends StatefulWidget{
  const AdminAdRequestPage({super.key});


  @override
  AdminAdRequestPageState createState() => AdminAdRequestPageState();
}

class AdminAdRequestPageState extends State<AdminAdRequestPage> with TickerProviderStateMixin{

  List<UserRequest> requests = [];
  bool _showNoData = false;
  bool _isLoading = true;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();

    _timer = Timer(Duration(seconds: 3), () {
      if (mounted && _isLoading && requests.isEmpty) {
        setState(() {
          _showNoData = true;
          _isLoading = false;
        });
      }
    });

    BlocProvider.of<AuthorityCubit>(context).getUserRequests(null).then((x){
      setState(() {
        requests = x;
        _isLoading = false;
        _timer?.cancel();
      });
    }).catchError((e) {
      print("Error fetching requests: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorityCubit, AuthorityState>(builder: buildRequests);
  }

  Widget buildRequests(context, state)
  {
    if (state is AuthorityLoading || (_isLoading && requests.isEmpty && !_showNoData))
      {
        return _buildSkeletonLoader();
      }
    else if (state is AuthorityRequestDone)
      {
        requests = state.data;
        _isLoading = false;
        _timer?.cancel();
        
        if (requests.isNotEmpty)
          {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.sizeOf(context).width / 300).round(),
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: requestBuilder,
                itemCount: requests.length,
                padding: EdgeInsets.all(16),
              ),
            );
          }
        else{
          return _buildEmptyState();
        }
      }
    else if (_showNoData || (requests.isEmpty && !_isLoading))
      {
        return _buildEmptyState();
      }
    else
      {
        return _buildErrorState();
      }
  }

  Widget _buildSkeletonLoader() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery.sizeOf(context).width / 300).round(),
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.folderOpen,
                size: 80,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "لا توجد طلبات",
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "سيتم عرض الطلبات هنا عندما يتم إرسالها",
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade100, Colors.orange.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.triangleExclamation,
                size: 80,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "حدث خطأ",
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "حاول مرة أخرى",
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _showNoData = false;
                });
                BlocProvider.of<AuthorityCubit>(context).getUserRequests(null);
              },
              icon: Icon(Icons.refresh),
              label: Text(
                "إعادة المحاولة",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget requestBuilder (context, int i)
  {
    final req = requests[i];

    if (req is DefaultRequest)
      {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.orange.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Badge
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/imgs/LoadingImage.gif',
                        image: req.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Category Icon Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FaIcon(
                          req.category.icon,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    // "جديد" Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          "جديد",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ad Name
                        Text(
                          req.adName,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 8),
                        
                        // User info
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.user, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                req.username,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        
                        // Ad Type
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.tag, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 6),
                            Text(
                              req.type,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        
                        // Target views
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.eye, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 6),
                            Text(
                              "${req.target} مشاهدة",
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        
                        Spacer(),
                        
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {acceptButton(req);},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: Icon(FontAwesomeIcons.check, size: 16),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {rejectButton(req);},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: Icon(FontAwesomeIcons.x, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    else if (req is RenewRequest)
      {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Badge
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/imgs/LoadingImage.gif',
                        image: req.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Category Icon Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FaIcon(
                          req.category.icon,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    // "تجديد" Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          "تجديد",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ad Name
                        Text(
                          req.adName,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 8),
                        
                        // User info
                        _buildInfoRow(FontAwesomeIcons.user, req.username),
                        _buildInfoRow(FontAwesomeIcons.phone, req.userPhone),
                        _buildInfoRow(FontAwesomeIcons.layerGroup, req.tier),
                        
                        // Views
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.eye, size: 12, color: Colors.grey[600]),
                            SizedBox(width: 6),
                            Text(
                              "${req.views}/${req.target}",
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: req.views / req.target,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                            minHeight: 6,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {acceptButton(req);},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Icon(FontAwesomeIcons.check, size: 14),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {rejectButton(req);},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: Icon(FontAwesomeIcons.x, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    else{
      return Text("");
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  void acceptButton (req)
  {
    showDialog(context: context, builder: (_) {

      return AlertDialog(

        title: Center(child: Text("تاكيد", style: GoogleFonts.cairo(),)),
        content: Center(heightFactor: 0, child: Text("هل تود تاكيد نشر الاعلان ؟", style: GoogleFonts.cairo(),)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,

        actions: [
          OutlinedButton(onPressed: () {Navigator.pop(context);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.red), child: Text("إلغاء",
            style: GoogleFonts.cairo(color: Colors.white),),),

          OutlinedButton(onPressed: () {handleReq(req, true);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.green), child: Text("حفظ",
              style: GoogleFonts.cairo(color: Colors.white)),)
        ],

      );

    });
  }

  void rejectButton (req)
  {
    showDialog(context: context, builder: (_) {

      return AlertDialog(

        title: Center(child: Text("تاكيد", style: GoogleFonts.cairo(),)),
        content: Center(heightFactor: 0, child: Text("هل تود تاكيد حذف الاعلان ؟", style: GoogleFonts.cairo(),)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,

        actions: [
          OutlinedButton(onPressed: () {Navigator.pop(context);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.red), child: Text("إلغاء",
              style: GoogleFonts.cairo(color: Colors.white),),),

          OutlinedButton(onPressed: () {handleReq(req, false);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.green), child: Text("حفظ",
                style: GoogleFonts.cairo(color: Colors.white)),)
        ],

      );

    });
  }

  void handleReq(req, bool accept) async
  {
    final cubit = BlocProvider.of<AuthorityCubit>(context);

    if (req is DefaultRequest)
      {
        await cubit.handleRequest(req.id, accept);
      }
    else if (req is RenewRequest)
      {
        await cubit.handleRequest(req.id, accept);
      }

    Navigator.pop(context);
    cubit.getUserRequests(null);
  }
}