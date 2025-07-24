import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path/path.dart';
// import 'package:path/path.dart';

import '../../providers/product.dart';
import './product_list_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen(
      {super.key, this.product, this.db, this.categoryname});
  static const routeName = '/edit-product';
  final Map? product;
  final Product? db;
  final String? categoryname;
  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  String? name;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? path;
  var fileName;
  int selectedBranch = 0;
  String? categoryData;
  List branches = [
    {"id": 0, "name": "Thrissur Golden Alathur"},
    {"id": 1, "name": "Thrissur Golden Chittur"},
    {"id": 2, "name": "Thrissur Golden Pattambi "},
    {"id": 3, "name": "Thrissur Golden Vadakkencherri "},
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
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
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
        quality: 100, percentage: 30);
    setState(() {
      compressedImage = File(compressedFile.path);
      ext = extension(compressedImage!.path);
    });
    final compressbytes = compressedImage!.readAsBytesSync().lengthInBytes;
  }

  Future<void> snak(BuildContext context) async {
    final snackBar = SnackBar(
        content:
            const Text('Document format not supported or Add Product name...'));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _saveForm(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (fileName != null) {
        if (ext == ".jpg" || ext == ".jpeg" || ext == ".png") {
          await Provider.of<Product>(context, listen: false)
              .updateProductWithImage(compressedImage!, fileName, _product,
                  widget.product!['id'], widget.product!['photoName']);

          final snackBar = SnackBar(content: const Text('Saved successfully!'));

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          setState(() {
            _isLoading = false;

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductListScreen(
                          categoryname: categoryData!,
                        )));
          });
        } else {
          final snackBar =
              SnackBar(content: const Text('Doument not supported!'));

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        await Provider.of<Product>(context, listen: false).updateProduct(
            _product, widget.product!['id'], widget.product!['photoName']);

        final snackBar = SnackBar(content: const Text('Updated successfully!'));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        setState(() {
          _isLoading = false;

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductListScreen(
                        categoryname: categoryData!,
                      )));
        });
      }
    } catch (err) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong. ${err}'),
          actions: <Widget>[
            OutlinedButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
  }

  setCategory() {
    setState(() {
      categoryData = widget.categoryname;
    });
  }

  @override
  void initState() {
    setState(() {
      name = widget.product!['productName'];
    });
    _product = ProductModel(
      id: widget.product!['id'],
      productName: widget.product!['productName'],
      productCode: widget.product!['productCode'],
      description: widget.product!['description'],
      photoName: widget.product!['photoName'],
      category: widget.product!['category'],
      gram: widget.product!['gram'],
      photo: widget.product!['photo'],
      branch: widget.product!['branch'],
      // photo: "",
    );
    // TODO: implement initState
    super.initState();
    setCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          title: Text('Edit Product'),
          actions: [],
          backgroundColor: Theme.of(context).primaryColor,
          // leading: new IconButton(
          //   icon: new Icon(Icons.arrow_back),
          //   onPressed: () => Navigator.pushReplacement(
          //       context,
          //       new MaterialPageRoute(
          //           builder: (context) => new ProductListScreen(
          //                 categoryname: categoryData!,
          //               ))),
          // ),
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
                            fileName == null
                                ? Container(
                                    height: 100,
                                    child: Image(
                                      image: NetworkImage(
                                          widget.product!['photo']),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Container(
                                    // File(pickedImage!)
                                    height: 100,
                                    child: Image(
                                      image: FileImage(File(pickedImage!)),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
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
                            // Row(
                            //   children: [
                            //     Text("Category Type : "),
                            //     SizedBox(
                            //       width: 10,
                            //     ),
                            //     Text(
                            //       categoryData!,
                            //       style: TextStyle(
                            //           fontSize: 15,
                            //           fontWeight: FontWeight.w600),
                            //     ),
                            //   ],
                            // ),
                            TextFormField(
                              initialValue: widget.product!['productName'],
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
                              initialValue: widget.product!['productCode'],
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
                              initialValue: widget.product!['gram'],
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
                              initialValue: widget.product!['description'],
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

                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(context).primaryColor),
                                height:
                                    MediaQuery.of(context).size.height * .06,
                                width: MediaQuery.of(context).size.width * .4,
                                child: OutlinedButton(
                                  onPressed: isLoading == false
                                      ? name != null
                                          ? () {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              _saveForm(context);
                                            }
                                          : () {
                                              print(name);
                                              // snak(context);
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
        ));
  }
}
