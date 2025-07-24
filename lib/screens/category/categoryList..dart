import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../constant/colors.dart';
import '../../providers/category.dart';
import '../../screens/products/product_list_screen.dart';
import 'addCategory.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key, this.refresh}) : super(key: key);
  final Function? refresh;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TextEditingController categoryController = TextEditingController();
  bool appbarSelect = false;
  late String deleteId;
  Icon actionIcon = new Icon(
    Icons.delete,
    color: Colors.white,
  );

  Widget appBarTitle = new Text(
    "Category",
    style: new TextStyle(color: Colors.white),
  );

  buildBar(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: appBarTitle,
      backgroundColor: useColor.homeIconColor,
    );
  }

  var categoryDb = Category();
  var categoryList = [];
  Future loadCategoary() async {
    categoryDb.initiliase();
    categoryDb.getCategory().then((value) {
      setState(() {
        categoryList = value;
      });
    });
  }

  // late String categoryName;
  // Future addCetegory(BuildContext) async {
  //   try {
  //     setState(() {
  //       categoryName = categoryController.text;
  //     });

  //     await Provider.of<Category>(context, listen: false)
  //         .addCategory(categoryName)
  //         .then((value) {
  //       final snackBar = SnackBar(content: const Text('Category Added...!'));

  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //       setState(() {});
  //       refresh(); // just refresh() if its statelesswidget
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  refresh() {
    setState(() {
      //all the reload processes

      Navigator.of(context).pop();
      loadCategoary();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategoary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar:
          //  appbarSelect ? selectedBar(context) :
          buildBar(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: useColor.homeIconColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddCategory(
                        category: categoryList,
                      ))).then((value) {
            refresh();
          });
          // showModalBottomSheet(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10.0),
          //     ),
          //     context: context,
          //     builder: (context) {
          //       return SingleChildScrollView(
          //         child: Container(
          //           height: 200,
          //           padding: EdgeInsets.all(10),
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //             children: [
          //               Text(
          //                 "Add Category",
          //                 style: TextStyle(
          //                     fontWeight: FontWeight.w500, fontSize: 18),
          //               ),
          //               Divider(),
          //               Padding(
          //                 padding: EdgeInsets.only(
          //                     left: 10, right: 10, top: 8, bottom: 8),
          //                 child: Container(
          //                   height: 50,
          //                   width: double.infinity,
          //                   decoration: BoxDecoration(
          //                       border: Border.all(),
          //                       borderRadius: BorderRadius.circular(13)),
          //                   child: Padding(
          //                     padding: EdgeInsets.only(
          //                         left: 10, right: 10, top: 8, bottom: 8),
          //                     child: TextField(
          //                       controller: categoryController,
          //                       decoration: InputDecoration(
          //                         border: InputBorder.none,
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //               Align(
          //                 alignment: Alignment.centerRight,
          //                 child: Container(
          //                   padding: EdgeInsets.only(right: 20),
          //                   width: 200,
          //                   height: 60,
          //                   child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.end,
          //                     children: [
          //                       GestureDetector(
          //                         onTap: () {
          //                           Navigator.pop(context);
          //                         },
          //                         child: Text(
          //                           "Cancel",
          //                           style: TextStyle(
          //                             fontWeight: FontWeight.w600,
          //                             fontSize: 16,
          //                           ),
          //                         ),
          //                       ),
          //                       SizedBox(
          //                         width: 20,
          //                       ),
          //                       GestureDetector(
          //                         onTap: () {
          //                           addCetegory(context);
          //                           setState(() {
          //                             categoryController.text = "";
          //                           });
          //                         },
          //                         child: Container(
          //                             height: 35,
          //                             width: 75,
          //                             decoration: BoxDecoration(
          //                                 color: Theme.of(context).primaryColor,
          //                                 border: Border.all(),
          //                                 borderRadius:
          //                                     BorderRadius.circular(13)),
          //                             child: Center(
          //                                 child: Text(
          //                               "Add",
          //                               style: TextStyle(
          //                                   fontWeight: FontWeight.w600,
          //                                   fontSize: 16,
          //                                   color: Colors.white),
          //                             ))),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               )
          //             ],
          //           ),
          //         ),
          //       );
          //     });
        },
      ),
      body: categoryList.length > 0
          ? SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: double.infinity,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) {
                            final item = categoryList[index]["id"];
                            return Column(
                              children: [
                                Slidable(
                                  key: ValueKey(item),
                                  endActionPane: ActionPane(
                                    extentRatio: 0.3,
                                    motion: StretchMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Delete"),
                                              content: Text(
                                                  "Do you want to delete the category ${categoryList[index]["name"]}?"),
                                              actions: <Widget>[
                                                OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                    _onDissmissed(
                                                        index, Action.delete);
                                                  },
                                                  child: const Text("Ok"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        backgroundColor:
                                            const Color(0xffDD5353),
                                        foregroundColor: Colors
                                            .white, // Ensure text/icon color visibility
                                        icon: Icons.delete_outline,
                                        label: "Delete",
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductListScreen(
                                            categoryname: categoryList[index]
                                                ["name"],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                categoryList[index]["name"],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const Text(
                                                "Tap to Show Product",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          }))),
            )
          : Center(child: Text("No Category Found....")),
    );
  }

  _onDissmissed(int index, Action action) {
    final user = categoryList[index];
    setState(() {
      categoryDb.delete(categoryList[index]['id']).then(
        (value) {
          setState(() {});
        },
      );
    });
    setState(() {
      categoryList.removeAt(index);
    });

    // Shows the information on Snackbar

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$categoryList dismissed")));
  }
}

enum Action { delete }
