import 'dart:io';
import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import 'package:path/path.dart';
// import 'package:path/path.dart';

import '../../providers/product.dart';
import './product_list_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';
  AddProductScreen({this.category});
  String? category;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? name;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? path;
  var fileName;
  int? selectedBranch;
  // List branches = [
  //   {"id": 0, "name": "Thrissur Golden Alathur"},
  //   {"id": 1, "name": "Thrissur Golden Chittur"},
  //   {"id": 2, "name": "Thrissur Golden Pattambi "},
  //   {"id": 3, "name": "Thrissur Golden Vadakkencherri "},
  // ];
  List branches = [
    {"id": 0, "name": "Thrissur Golden Alathur"},
    {"id": 1, "name": "Thrissur Golden Chittur"},
    {"id": 2, "name": "Thrissur Golden Vadakkencherri "},
  ];
  var _isLoading = false;
  var _product = ProductModel(
    id: "",
    productName: "",
    productCode: "",
    description: "",
    photoName: "", category: "", gram: '',
    photo: "",
    branch: 0,
    // photo: "",
  );
  String? ext;
  var normalsize;
  var compressSize;
  File? image;
  File? compressedImage;
  String? pickedImage;
  imagePick(context) async {
    // final pickedFile = await FilePicker.platform.pickFiles(
    //   allowMultiple: false,
    //   type: FileType.custom,
    //   allowedExtensions: ['png', 'jpg'],
    // );
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image, // Only image types
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

    // final compressedFile = await FlutterNativeImage.compressImage(image!.path,
    //     quality: 100, percentage: 0);
    // setState(() {
    //   compressedImage = File(compressedFile.path);
    //   ext = extension(compressedImage!.path);
    // });
  }

  Future<void> snak(BuildContext context) async {
    final snackBar = SnackBar(
        content:
            const Text('Document format not supported or Add Product name...'));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Future<void> _saveForm(String categoryData1, BuildContext context) async {
  //   final isValid = _formKey.currentState!.validate();
  //   if (!isValid) {
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   if (ext == ".jpg" || ext == ".jpeg" || ext == ".png") {
  //     try {
  //       await Provider.of<Product>(context, listen: false)
  //           .uploadFile(image!, fileName, _product, categoryData1);

  //       final snackBar = SnackBar(content: const Text('Saved successfully!'));

  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);

  //       setState(() {
  //         _isLoading = false;

  //         Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => ProductListScreen(
  //                       categoryname: categoryData!,
  //                     )));
  //       });
  //     } catch (err) {
  //       await showDialog(
  //         context: context,
  //         builder: (ctx) => AlertDialog(
  //           title: Text('An error occurred!'),
  //           content: Text('Something went wrong. ${err}'),
  //           actions: <Widget>[
  //             OutlinedButton(
  //               child: Text('Okay'),
  //               onPressed: () {
  //                 Navigator.of(ctx).pop();
  //               },
  //             )
  //           ],
  //         ),
  //       );
  //     }
  //   } else {
  //     final snackBar = SnackBar(content: const Text('Doument not supported!'));

  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  Future<void> _saveForm(String categoryData1, BuildContext context) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    if (image == null || fileName == null || ext == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid image file.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png") {
      try {
        // Perform the file upload
        await Provider.of<Product>(context, listen: false)
            .uploadFile(image!, fileName!, _product, categoryData1);

        // if (mounted) {
        // Show success message
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Saved successfully!')),
        // );

        // Navigate to the next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(
              categoryname: categoryData!,
            ),
          ),
        );
      } catch (err) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('An error occurred!'),
              content: Text('Something went wrong: $err'),
              actions: <Widget>[
                OutlinedButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document not supported!')),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? categoryData;

  setCategory() {
    setState(() {
      categoryData = widget.category;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCategory();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shoulpop = await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductListScreen(categoryname: categoryData!)));
        return shoulpop;
      },
      child: Scaffold(
          backgroundColor: Colors.blueGrey.shade50,
          appBar: AppBar(
            backgroundColor: useColor.homeIconColor,
            title: Text('Create Product'),
            actions: [],
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new ProductListScreen(
                            categoryname: categoryData!,
                          ))),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: new SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
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
                                    color: fileName == null
                                        ? Colors.red
                                        : Colors.green,
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

                      //// textField Container
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * .55,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Text("Category Type : "),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    categoryData!,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    name = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Product name';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _product = ProductModel(
                                      productName: value!,
                                      productCode: _product.productCode,
                                      description: _product.description,
                                      gram: _product.gram,
                                      category: _product.category,
                                      id: _product.id,
                                      photo: _product.photo,
                                      photoName: _product.photoName,
                                      branch: _product.branch);
                                },
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Enter Product name',
                                ),
                              ),
                              TextFormField(
                                onSaved: (value) {
                                  _product = ProductModel(
                                      productName: _product.productName,
                                      productCode: value!,
                                      description: _product.description,
                                      gram: _product.gram,
                                      category: _product.category,
                                      id: _product.id,
                                      photo: _product.photo,
                                      photoName: _product.photoName,
                                      branch: _product.branch);
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Enter Product Code',
                                ),
                              ),
                              TextFormField(
                                onSaved: (value) {
                                  _product = ProductModel(
                                      productName: _product.productName,
                                      productCode: _product.productCode,
                                      description: _product.description,
                                      gram: value!,
                                      category: _product.category,
                                      id: _product.id,
                                      photo: _product.photo,
                                      photoName: _product.photoName,
                                      branch: _product.branch);
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Gram',
                                ),
                              ),
                              TextFormField(
                                onSaved: (value) {
                                  _product = ProductModel(
                                      productName: _product.productName,
                                      productCode: _product.productCode,
                                      description: value!,
                                      gram: _product.gram,
                                      category: _product.category,
                                      id: _product.id,
                                      photo: _product.photo,
                                      photoName: _product.photoName,
                                      branch: _product.branch);
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  labelText: 'Description',
                                ),
                              ),
                              // Container(
                              //   width: double.infinity,
                              //   height:
                              //       MediaQuery.of(context).size.height * .074,
                              //   decoration: BoxDecoration(
                              //       // color: Colors.white,
                              //       borderRadius: BorderRadius.circular(5),
                              //       border: Border.all()),
                              //   padding: EdgeInsets.only(
                              //       left: 10, right: 10, top: 7),
                              //   child: DropdownButton(
                              //       underline: SizedBox(),
                              //       style: TextStyle(
                              //           // fontWeight: FontWeight.w500,
                              //           fontSize: 14,
                              //           color: Colors.black),
                              //       isExpanded: true,
                              //       hint: Text(
                              //         "Select Branch",
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.w500,
                              //             fontSize: 15,
                              //             color: Color.fromARGB(115, 0, 0, 0)),
                              //       ),
                              //       value: selectedBranch,
                              //       items: branches.map((val) {
                              //         return DropdownMenuItem(
                              //             value: val["id"],
                              //             child: Padding(
                              //               padding: const EdgeInsets.all(8.0),
                              //               child: Text(val["name"]),
                              //             ));
                              //       }).toList(),
                              //       onChanged: (value) {
                              //         setState(() {
                              //           selectedBranch = value as int;
                              //         });
                              //         print(selectedBranch);
                              //         _product = ProductModel(
                              //           productName: _product.productName,
                              //           productCode: _product.productCode,
                              //           description: _product.description,
                              //           gram: _product.gram,
                              //           category: _product.category,
                              //           id: _product.id,
                              //           photo: _product.photo,
                              //           photoName: _product.photoName,
                              //           branch: selectedBranch!,
                              //         );
                              //       }),
                              // ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: useColor.homeIconColor),
                                  height:
                                      MediaQuery.of(context).size.height * .06,
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: TextButton(
                                    onPressed: isLoading == false
                                        ? name != null
                                            ? () {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                _saveForm(
                                                    categoryData!, context);
                                              }
                                            : () {
                                                snak(context);
                                              }
                                        : null,
                                    child: isLoading
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            'Submit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
