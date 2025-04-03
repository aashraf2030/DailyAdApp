import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerButton extends StatefulWidget{
  ImagePickerButton(this.hint, this.icon, {super.key});

  final String hint;
  final IconData icon;
  bool imageIsSelected = false;
  XFile? out;
  ImagePicker picker = ImagePicker();

  @override
  ImagePickerButtonState createState() => ImagePickerButtonState();
}

class ImagePickerButtonState extends State<ImagePickerButton>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: chooseImage,
        style: OutlinedButton.styleFrom(
            backgroundColor: (widget.imageIsSelected ? Colors.red : Colors.green),
            iconColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: Size.fromHeight(60),
            iconSize: 25
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.icon),
            Text((widget.imageIsSelected ? "حذف الصورة" : widget.hint), style: GoogleFonts.cairo(color: Colors.white),)
          ],
        )
    );
  }

  void chooseImage() async
  {
    if (widget.imageIsSelected)
    {
      widget.out = null;
    }
    else
    {
      widget.out = await widget.picker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      widget.imageIsSelected = widget.out != null;
    });
  }
}