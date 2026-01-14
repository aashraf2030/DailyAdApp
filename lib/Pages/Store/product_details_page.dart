import 'package:ads_app/API/base.dart';
import 'package:ads_app/Bloc/Store/store_cubit.dart';
import 'package:ads_app/Bloc/Store/store_state.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Pages/Store/admin_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailsPage extends StatefulWidget {
  final dynamic product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              FutureBuilder<bool>(
                future: context.read<AuthCubit>().isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: Colors.blue, size: 20),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: context.read<StoreCubit>()),
                                    BlocProvider.value(value: context.read<AuthCubit>()),
                                  ],
                                  child: AdminProductPage(product: widget.product),
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.delete, color: Colors.red, size: 20),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("حذف المنتج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                                content: Text("هل أنت متأكد من حذف هذا المنتج؟", style: GoogleFonts.cairo(), textDirection: TextDirection.rtl),
                                actions: [
                                  TextButton(
                                    child: Text("إلغاء", style: GoogleFonts.cairo()),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                  TextButton(
                                    child: Text("حذف", style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      context.read<StoreCubit>().deleteProduct(widget.product['id']);
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.product['image'] != null ? "${BackendAPI.base}store/image/${widget.product['image']}" : 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['name'],
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF364A62),
                          ),
                        ),
                      ),
                      Text(
                        "${widget.product['price']} ريال سعودي",
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2596FA),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF2596FA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product['category'],
                      style: GoogleFonts.cairo(
                        color: Color(0xFF2596FA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "الوصف",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product['description'],
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Text(
                        "الكمية",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                            ),
                            Text(
                              "$quantity",
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<StoreCubit>().addToCart(widget.product, quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("تمت الإضافة للسلة", style: GoogleFonts.cairo()),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2596FA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.cartPlus, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "إضافة للسلة",
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
