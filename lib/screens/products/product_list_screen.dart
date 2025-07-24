import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../constant/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './add_product_screen.dart';
import './update_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  static const routeName = '/product-list';
  ProductListScreen({Key? key, this.categoryname, this.isSelect})
      : super(key: key);
  bool? isSelect;
  String? categoryname;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? deleteId;
  String? deleteName;
  String? categoryname;

  bool appbarSelect = false;
  Stream? products;
  Product? db;
  List userList = [];
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('product');

  Stream? _queryDb() {
    products = FirebaseFirestore.instance
        .collection('product')
        .where("category", isEqualTo: categoryname)
        .snapshots()
        .map(
          (list) => list.docs.map((doc) => doc.data()),
        );
  }

  setCategoryId() {
    setState(() {
      categoryname = widget.categoryname;
    });
  }

  @override
  _backpress() {
    setState(() {});
  }

  void initState() {
    setCategoryId();
    _queryDb();
    super.initState();
    initialise();
  }

  int? branchId;
  initialise() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);

    setState(() {
      branchId = Staff['branch'];
    });

    db = Product();
    db!.initiliase();
    db!.read(categoryname!, branchId!).then((value) => {
          setState(() {
            userList = value != null ? value : userList;
          }),
        });
  }

  Widget appBarTitle = new Text(
    "Products",
    style: new TextStyle(color: Colors.white),
  );

  Icon actionIcon = new Icon(
    Icons.delete,
    color: Colors.white,
  );

  buildBar(BuildContext context) {
    return AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: appBarTitle,
        backgroundColor: useColor.homeIconColor);
  }

  final Product product = Product();
  selectedBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red,
      leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            // setState(() {
            //   appbarSelect = false;
            // });
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ProductListScreen(
                    categoryname: categoryname!,
                  ),
                ));
          }),
      actions: [
        IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.delete) {
                  Widget cancelButton = OutlinedButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  );
                  Widget continueButton = OutlinedButton(
                      child: Text("Continue"),
                      onPressed: () {
                        product
                            .delete(
                              deleteId!,
                              deleteName!,
                            )
                            .then((value) => {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListScreen(
                                                categoryname: categoryname!,
                                              )))
                                });
                      });

                  // set up the AlertDialog
                  AlertDialog alert = AlertDialog(
                    title: Text("Delete"),
                    content:
                        Text("Would you like to continue delete Product ?"),
                    actions: [
                      cancelButton,
                      continueButton,
                    ],
                  );
                  // show the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                }
              });
            })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Product product = Product();
    return new Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar:
            // appbarSelect ? selectedBar(context) :
            buildBar(context),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: useColor.homeIconColor,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AddProductScreen(
                          category: categoryname!,
                        )));
          },
        ),
        body: userList.isNotEmpty
            ? SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        // final Map<String, dynamic> image = slideList[index];
                        //// shimmer for loading
                        final item = userList[index]['id'];
                        return Column(
                          children: [
                            Slidable(
                              key: ValueKey(userList[index]['id']),
                              startActionPane: ActionPane(
                                extentRatio: 0.2,
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      edit(userList[index], index, context);
                                    },
                                    backgroundColor: const Color(0xff628E90),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit_outlined,
                                    label: "Edit",
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                extentRatio: 0.3,
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Delete"),
                                          content: const Text(
                                              "Do you want to delete this product?"),
                                          actions: [
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                setState(() {
                                                  deleteId =
                                                      userList[index]['id'];
                                                  deleteName =
                                                      'products/${userList[index]['photoName']}';
                                                });
                                                _onDissmissed(context, index,
                                                    Action.delete);
                                                initialise();
                                              },
                                              child: const Text("Ok"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    backgroundColor: const Color(0xffDD5353),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_outline,
                                    label: "Delete",
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Product Image
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.14,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              userList[index]['photo'],
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Divider
                                        Container(
                                          width: 1,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12,
                                          color: Colors.blueGrey.shade100,
                                        ),
                                        const SizedBox(width: 10),
                                        // Product Details
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.14,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                userList[index]['productName'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                userList[index]['productCode'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                userList[index]['category'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                userList[index]['description'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                userList[index]['gram'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              )
            : Center(child: Text("No product in this category...")));
  }

  _onDissmissed(BuildContext context, int index, Action action) {
    final user = userList[index];
    setState(() {
      product
          .delete(
        deleteId!,
        deleteName!,
      )
          .then((value) {
        print("delete");
        initialise();
        setState(() {});
      });
    });
    setState(() {
      userList.removeAt(index);
    });

    // Shows the information on Snackbar

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$deleteName deleted")));
  }

  edit(Map product, int index, BuildContext context) async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateProductScreen(
                  db: db,
                  product: product,
                  categoryname: categoryname,
                )));
  }
}

enum Action { delete }
