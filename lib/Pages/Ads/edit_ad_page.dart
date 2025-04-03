
import 'package:ads_app/Bloc/Authority/authority_cubit.dart';
import 'package:ads_app/Bloc/Operational/operational_cubit.dart';
import 'package:ads_app/Models/ad_models.dart';
import 'package:ads_app/Models/category_model.dart';
import 'package:ads_app/Widgets/image_picker_button.dart';
import 'package:ads_app/Widgets/input_text_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAdPage extends StatefulWidget {

  EditAdPage({super.key, required this.ad})
  {
    name = InputTextForm("اسم الاعلان", FontAwesomeIcons.rectangleAd, initialVal: ad.name);
    keys = InputTextForm("كلمات مفتاحية", FontAwesomeIcons.key, initialVal: ad.keywords,);
    link = InputTextForm("رابط الاعلان", FontAwesomeIcons.link, initialVal: ad.path,);
    category = ad.category.id;
    picker.imageIsSelected = true;
  }

  final AdData ad;
  late InputTextForm name;
  late InputTextForm keys;
  late InputTextForm link;
  int category = -1;

  bool changeImage = false;

  ImagePickerButton picker = ImagePickerButton("اختار الصورة", FontAwesomeIcons.image);

  @override
  EditAdPageState createState () => EditAdPageState();
}

class EditAdPageState extends State<EditAdPage>{

  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("تعديل ${widget.name.initialVal}", overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
        textDirection: TextDirection.rtl,)),
        gradient: LinearGradient(colors: [Color.fromRGBO(37, 150, 250, 1),
          Color.fromRGBO(54, 74, 98, 0.85)], transform: GradientRotation(0.5)),
        actions: [
          IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_forward_outlined))
        ],
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          widget.name,
          Divider(),
          widget.link,
          Divider(),
          widget.picker,
          Divider(),
          DropdownButtonFormField(
            items: buildCategories(), onChanged: (x) {widget.category = x?? -1;},
            value: widget.category,
            hint: Text("اختار نوع الاعلان", style: GoogleFonts.cairo(),),
            isExpanded: true,
            alignment: AlignmentDirectional.centerEnd,
            style: GoogleFonts.cairo(color: Colors.blueAccent),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          Divider(),
          widget.keys,
          Divider(),
          buildSubmitButton(),
          buildRenewButton(),

        ],
      ),
    );
  }

  List<DropdownMenuItem> buildCategories()
  {
    List<DropdownMenuItem> res = [];

    for (var cat in categories)
    {
      if (cat.id == 0) {
        continue;
      }

      res.add(DropdownMenuItem(value: cat.id,
        child: Center(child: Text(cat.name, textAlign: TextAlign.center,)),),);
    }

    return res;

  }

  Widget buildSubmitButton ()
  {
    if (!isSending)
    {
      return OutlinedButton(onPressed: () { submit(context); },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.blueAccent[200],
          ),
          child: Text("تعديل الإعلان", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else
    {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 30, height: 30,
              child: CircularProgressIndicator(color:  Colors.blueAccent,)),
        ],
      );
    }

  }

  Widget buildRenewButton ()
  {
    if (!isSending)
    {
      return OutlinedButton(onPressed: () { renewMenu(context); },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.blueAccent[200],
          ),
          child: Text("تغيير الفئة", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),));
    }
    else
    {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 30, height: 30,
              child: CircularProgressIndicator(color:  Colors.blueAccent,)),
        ],
      );
    }
  }


  void submit (context) async
  {
    setState(() {
      isSending = true;
    });

    if (widget.name.out.isEmpty || !widget.picker.imageIsSelected || widget.link.out.isEmpty
        || widget.category == -1 || widget.keys.out.isEmpty)
    {
      showErrorMessage(context,"بيانات الاعلان غير مكتملة");
      setState(() {
        isSending = false;
      });
    }
    else if (!Uri.parse(widget.link.out).isAbsolute)
    {
      showErrorMessage(context,"رابط الإعلان غير صالح");
      setState(() {
        isSending = false;
      });
    }
    else
    {
      final cubit = BlocProvider.of<OperationalCubit>(context);

      final res = await cubit.editAd(widget.ad.id, widget.name.out, widget.picker.out?.path,
          widget.picker.out != null ? widget.picker.out!.name : "",
          widget.link.out, widget.category, widget.keys.out);

      if (res)
      {
        Navigator.pop(context);
      }
      else
      {
        showErrorMessage(context, "لم يتم تعديل الاعلان");
        setState(() {
          isSending = false;
        });
      }
    }
  }

  void showErrorMessage(context,String error)
  {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("خطأ", style: GoogleFonts.cairo(color: Colors.red),),
        content: Text(error, style: GoogleFonts.cairo(color: Colors.red),),
        actions: [
          OutlinedButton(onPressed: (){ Navigator.of(context).pop();},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.green[500],
            ),
            child: Text("محاولة مرة اخرى", style: GoogleFonts.cairo(color: Colors.white),),
          )
        ],
      );
    });
  }

  void renewMenu (context)
  {
    showDialog(context: context, builder: (_){

      int tier = 0;

      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        title: Center(child: Text("تغيير الفئة", style: GoogleFonts.cairo(),),),
        content: DropdownButtonFormField(items: [
          DropdownMenuItem(value: 0,child: Center(child: Text("Trial", textAlign: TextAlign.center,)),),
          DropdownMenuItem(value: 1,child: Center(child: Text("Starter", textAlign: TextAlign.center,)),),
          DropdownMenuItem(value: 2,child: Center(child: Text("Plus", textAlign: TextAlign.center,)),),
          DropdownMenuItem(value: 3,child: Center(child: Text("Pro", textAlign: TextAlign.center,)),),
          DropdownMenuItem(value: 4,child: Center(child: Text("Premium", textAlign: TextAlign.center,)),),
          DropdownMenuItem(value: 5,child: Center(child: Text("Enterprise", textAlign: TextAlign.center,)),),
        ], onChanged: (x) {tier = x?? -1;},
          value: tier,
          hint: Text("اختار فئة الاعلان", style: GoogleFonts.cairo(),),
          isExpanded: true,
          alignment: AlignmentDirectional.centerEnd,
          style: GoogleFonts.cairo(color: Colors.blueAccent),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(FontAwesomeIcons.arrowsUpToLine),
          ),
        ),

        actions: [
          OutlinedButton(onPressed: () {Navigator.pop(context); Navigator.pop(context);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.red), child: Text("إلغاء",
              style: GoogleFonts.cairo(color: Colors.white),),),

          OutlinedButton(onPressed: () {createRequest(context, tier);},
            style: OutlinedButton.styleFrom(backgroundColor: Colors.green), child: Text("حفظ",
                style: GoogleFonts.cairo(color: Colors.white)),)
        ],
      );

    });
  }

  void createRequest(context, int tier) async
  {

    List<String> tiers = ["Trial", "Starter", "Plus", "Pro", "Premium", "Enterprise"];

    if (tier < 0 || tier > 5) {
      setState(() {
        isSending = false;
      });
      return;
    }

    final cubit = BlocProvider.of<OperationalCubit>(context);

    await cubit.renewAd(widget.ad.id, tiers[tier]);

    Navigator.pop(context);

    submit(context);
  }
}
