import 'dart:io';
import 'package:ads_app/API/base.dart';
import 'package:ads_app/Bloc/Store/store_cubit.dart';
import 'package:ads_app/Bloc/Store/store_state.dart';
import 'package:ads_app/Widgets/login_textbox.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AdminProductPage extends StatefulWidget {
  final dynamic product;
  const AdminProductPage({super.key, this.product});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  late final LoginTextbox name;
  late final LoginTextbox desc;
  late final LoginTextbox price;
  late final LoginTextbox stock;
  
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    name = LoginTextbox(
      padding: 10, 
      icon: FontAwesomeIcons.tag, 
      hint: "اسم المنتج (إجباري)", 
      initialValue: widget.product != null ? widget.product['name'] : null
    );
    desc = LoginTextbox(
      padding: 10, 
      icon: FontAwesomeIcons.fileLines, 
      hint: "وصف المنتج (اختياري)", 
      initialValue: widget.product != null ? widget.product['description'] : null
    );
    price = LoginTextbox(
      padding: 10, 
      icon: FontAwesomeIcons.moneyBill1, 
      hint: "السعر (ريال سعودي)", 
      initialValue: widget.product != null ? widget.product['price'].toString() : null
    );
    stock = LoginTextbox(
      padding: 10, 
      icon: FontAwesomeIcons.boxesStacked, 
      hint: "الكمية المتاحة (إجباري)", 
      initialValue: widget.product != null ? widget.product['stock'].toString() : null
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEdit ? "تعديل المنتج" : "إضافة منتج جديد",
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<StoreCubit, StoreState>(
        listener: (context, state) {
          if (state is StoreLoaded) { 
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEdit ? "تم تعديل المنتج بنجاح" : "تم إضافة المنتج بنجاح", style: GoogleFonts.cairo()), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
            if (isEdit) Navigator.pop(context); 
          } else if (state is StoreError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: GoogleFonts.cairo()), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              name,
              SizedBox(height: 15),
              desc,
              SizedBox(height: 15),
              price,
              SizedBox(height: 15),
              
              
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb 
                              ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                              : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                        )
                      : (isEdit && widget.product['image'] != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network("${BackendAPI.base}store/image/${widget.product['image']}", fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.image, size: 40, color: Colors.grey),
                                SizedBox(height: 10),
                                Text("اضغط لرفع صورة", style: GoogleFonts.cairo(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
              
              SizedBox(height: 15),
              stock,
              SizedBox(height: 40),
              BlocBuilder<StoreCubit, StoreState>(
                builder: (context, state) {
                  if (state is StoreLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (name.data.isEmpty || price.data.isEmpty || stock.data.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("يرجى ملء البيانات الإجبارية", style: GoogleFonts.cairo()), backgroundColor: Colors.orange),
                          );
                          return;
                        }

                        if (!isEdit && _selectedImage == null) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("يرجى اختيار صورة للمنتج", style: GoogleFonts.cairo()), backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        
                        if (isEdit) {
                          context.read<StoreCubit>().editProduct(
                            widget.product['id'],
                            name.data,
                            desc.data,
                            double.tryParse(price.data) ?? 0,
                            _selectedImage, 
                            int.tryParse(stock.data) ?? 0,
                          );
                        } else {
                          context.read<StoreCubit>().addProduct(
                            name.data,
                            desc.data,
                            double.tryParse(price.data) ?? 0,
                            _selectedImage,
                            int.tryParse(stock.data) ?? 0,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2596FA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        isEdit ? "حفظ التعديلات" : "إضافة المنتج",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
