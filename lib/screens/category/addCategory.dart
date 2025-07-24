import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../constant/colors.dart';
import '../../providers/category.dart';

class AddCategory extends StatefulWidget {
  AddCategory({super.key, required this.category});
  List category;

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  String? ext;
  File? image;
  File? compressedImage;
  String? pickedImage;
  var fileName;
  bool isLoading = false;
  TextEditingController categoryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: useColor.homeIconColor,
        title: Text(
          'Create Category',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
          child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              imagePick(context);
            },
            child: Container(
              margin: EdgeInsets.all(15),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                    width: .6,
                    color: Colors.blueGrey,
                    style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fileName == null
                        ? "Upload Photo"
                        : "Image Added Successfully",
                    style: TextStyle(
                        color: fileName == null ? Colors.red : Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Icon(Icons.camera_enhance_outlined)
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(13)),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                child: TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    hintText: "Enter Category Name",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: useColor.homeIconColor),
            height: MediaQuery.of(context).size.height * .06,
            width: MediaQuery.of(context).size.width * .4,
            child: TextButton(
              onPressed: isLoading == false
                  ? categoryController.text != ""
                      ? () {
                          if (image != null) {
                            setState(() {
                              isLoading = true;
                            });
                            addCetegory(context);
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            final snackBar = SnackBar(
                                content: const Text('Upload Image...!'));

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      : () {
                          setState(() {
                            isLoading = false;
                          });

                          // snak(context);
                        }
                  : null,
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      )),
    );
  }

  imagePick(context) async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
      // allowedExtensions: ['png', 'jpg'],
    );

    if (pickedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return null;
    }

    setState(() {
      pickedImage = pickedFile.files.single.path;
      fileName = pickedFile.files.single.name;
      image = File(pickedImage!);
      ext = extension(image!.path);
    });

    final compressedFile = await FlutterNativeImage.compressImage(image!.path,
        quality: 100, percentage: 0);
    setState(() {
      compressedImage = File(compressedFile.path);
      ext = extension(compressedImage!.path);
    });
    final compressbytes = compressedImage!.readAsBytesSync().lengthInBytes;
  }

  // Future<void> snak(BuildContext context) async {
  //   final snackBar = SnackBar(content: const Text('Enter Category Name...!'));

  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  late String categoryName;
  Future addCetegory(context) async {
    try {
      setState(() {
        categoryName = categoryController.text;
      });
      bool categoryExists = widget.category.any(
          (cat) => cat["name"].toLowerCase() == categoryName.toLowerCase());
      if (categoryExists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Category already exists")));
        setState(() {
          isLoading = false;
        });
      } else {
        // Add the new category
        await Provider.of<Category>(context, listen: false)
            .addCategory(categoryName, fileName, image!)
            .then((value) {
          final snackBar = SnackBar(content: const Text('Category Added...!'));

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {});
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
