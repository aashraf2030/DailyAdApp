import 'package:ads_app/API/base.dart';
import 'package:ads_app/Bloc/Store/store_cubit.dart';
import 'package:ads_app/Bloc/Store/store_state.dart';
import 'package:ads_app/Pages/Store/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ads_app/Bloc/Auth/auth_cubit.dart';
import 'package:ads_app/Pages/Store/admin_product_page.dart';
import 'cart_page.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  void initState() {
    super.initState();
    context.read<StoreCubit>().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildCategoriesSection()),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: BlocBuilder<StoreCubit, StoreState>(
              builder: (context, state) {
                if (state is StoreLoading) {
                  return _buildSkeletonSliverGrid();
                } else if (state is StoreLoaded) {
                  if (state.products.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Column(
                            children: [
                              Icon(FontAwesomeIcons.boxOpen, size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text("لا توجد منتجات حالياً", style: GoogleFonts.cairo(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return _buildProductsSliverGrid(state.products);
                } else if (state is StoreError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text(state.message, style: GoogleFonts.cairo(color: Colors.red))),
                  );
                }
                // Fallback
                final products = context.read<StoreCubit>().products;
                if (products.isEmpty) return _buildSkeletonSliverGrid();
                return _buildProductsSliverGrid(products);
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
        ],
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: context.read<AuthCubit>().isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: context.read<StoreCubit>()),
                        BlocProvider.value(value: context.read<AuthCubit>()),
                      ],
                      child: AdminProductPage(),
                    ),
                  ),
                );
              },
              backgroundColor: Color(0xFF2596FA),
              icon: Icon(Icons.add),
              label: Text("إضافة منتج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 170.0,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF2596FA),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2596FA), Color(0xFF364A62)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(FontAwesomeIcons.store, size: 150, color: Colors.white.withOpacity(0.1)),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "المتجر",
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                          ],
                        ),
                        child: TextField(
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: "ابحث عن منتج...",
                            hintStyle: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        BlocBuilder<StoreCubit, StoreState>(
          builder: (context, state) {
            final cartCount = context.read<StoreCubit>().cart.length;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(FontAwesomeIcons.cartShopping, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<StoreCubit>(),
                          child: CartPage(),
                        ),
                      ),
                    );
                  },
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '$cartCount',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final categories = ["الكل", "إلكترونيات", "ملابس", "أثاث", "أخرى"];
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0; // Dummy selection
          return Container(
            margin: EdgeInsets.only(left: 10),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF2596FA) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2)),
              ],
              border: isSelected ? null : Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              categories[index],
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonSliverGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
        childCount: 6,
      ),
    );
  }

  Widget _buildProductsSliverGrid(List<dynamic> products) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, // Adjusted for better card height to prevent overflow
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<StoreCubit>()),
                      BlocProvider.value(value: context.read<AuthCubit>()),
                    ],
                    child: ProductDetailsPage(product: product),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            image: DecorationImage(
                              image: NetworkImage(product['image'] != null ? "${BackendAPI.base}store/image/${product['image']}" : 'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Favorite Icon (Dummy)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Details Section
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${product['price']} SAR", 
                                style: GoogleFonts.cairo(
                                  color: Color(0xFF2596FA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          
                          // Add to Cart Button (Small)
                          SizedBox(
                            width: double.infinity,
                            height: 38, // Increased height
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<StoreCubit>().addToCart(product, 1);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("تمت الإضافة للسلة", style: GoogleFonts.cairo()),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2596FA),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(vertical: 0), // Removed vertical padding
                                elevation: 0,
                              ),
                              child: Text("إضافة للسلة", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
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
        childCount: products.length,
      ),
    );
  }
}
