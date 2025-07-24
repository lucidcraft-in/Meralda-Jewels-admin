import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../constant/colors.dart';
import './create_customer_screen.dart';
import '../../providers/user.dart';
import 'customer_view.dart';
import '../customer/update_customer.dart';
import '../home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CustomerScreen extends StatefulWidget {
  static const routeName = '/customer-screen';

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String? filePath;
  String? fileName;
  bool checkValue = false;
  bool _isLoad = false;
  var user;
  User? db;
  List userList = [];
  // List filterList = [];
  var filterList = [];
  int? branchId;
  Widget appBarTitle = new Text(
    "Customers",
    style: new TextStyle(color: Colors.white),
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  bool isLoading = true;
  late bool _IsSearching;

  checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    checkValue = prefs.containsKey('user');

    if (checkValue) {
      var data = prefs.getString("user");

      if (data != null) {
        setState(() {
          user = jsonDecode(data);
          print('User Data: $user');
        });
      }
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        filePath = result.files.single.path!;
        fileName = result.files.single.name;
      });

      print("Selected File: $filePath");

      try {
        final firebase_storage.FirebaseStorage storage =
            firebase_storage.FirebaseStorage.instance;

        firebase_storage.TaskSnapshot taskSnapshot =
            await storage.ref('profilePic/$fileName').putFile(File(filePath!));

        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print("Download URL: $downloadUrl");

        if (user != null && user['id'] != null) {
          FirebaseFirestore.instance
              .collection('user')
              .doc(user['id'])
              .update({'profileImage': downloadUrl});
        } else {
          print("User ID is null, cannot update Firestore.");
        }
      } catch (e) {
        print("Error uploading file: $e");
      }
    } else {
      print("No file selected");
    }
  }

  Future<bool> _loadProfileData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate a network call
    return true; // Simulate data load success
  }

  final TextEditingController _searchQuery = new TextEditingController();
  initialise() {
    db = User();
    db!.initiliase();
    // print("============");
    // print(staffType);
    // print(staffId);
    db!.readByStaff(staffType, staffId).then((value) {
      if (value != null) {
        setState(() {
          userList = filterList = value!;
          print(userList);
        });
      }
      setState(() {
        isLoading = false;
      });
    });
    _IsSearching = false;
  }

  late int staffType;
  String staffId = "";
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var staff = jsonDecode(prefs.getString('staff')!);
    print(staff);
    setState(() {
      staffType = staff['type'];
      staffId = staff['id'];
    });

    setState(() {
      branchId = staff['branch'];
    });

    initialise();
  }

  @override
  void initState() {
    loginData();
    super.initState();
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "Customers",
        style: new TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }

  Widget? buildBar(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: appBarTitle,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomeScreen()),
                    (Route<dynamic> route) => false);
              }),
          actions: <Widget>[
            new IconButton(
              icon: actionIcon,
              onPressed: () {
                setState(() {
                  if (this.actionIcon.icon == Icons.search) {
                    this.actionIcon = new Icon(
                      Icons.close,
                      color: Colors.white,
                    );
                    this.appBarTitle = new TextField(
                      controller: _searchQuery,
                      style: new TextStyle(
                        color: Colors.white,
                      ),
                      decoration: new InputDecoration(
                          prefixIcon:
                              new Icon(Icons.search, color: Colors.white),
                          hintText: "Search...",
                          hintStyle: new TextStyle(color: Colors.white)),
                      onChanged: (string) {
                        setState(() {
                          filterList = userList
                              .where((element) =>
                                  (element['custId']
                                      .toLowerCase()
                                      .contains(string.toLowerCase())) ||
                                  (element['name']
                                      .toLowerCase()
                                      .contains(string.toLowerCase())) ||
                                  (element['phoneNo']
                                      .toLowerCase()
                                      .contains(string.toLowerCase())))
                              .toList();
                        });
                      },
                    );
                    _handleSearchStart();
                  } else {
                    _handleSearchEnd();
                  }
                });
              },
            ),
          ]),
      // appBar: buildBar(context),
      floatingActionButton:
          // staffType != 0
          //     ?
          branchId != 0
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: useColor.homeIconColor,
                  foregroundColor: Colors.white,
                  onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateCustomerScreen()))
                  },
                )
              : Container(),
      // : Container(),
      body: SlidableAutoCloseBehavior(
        closeWhenOpened: true,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(),
              child: userList.isNotEmpty
                  ? filterList.length != 0
                      ? ListView.builder(
                          itemCount: filterList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = filterList[index]["id"];
                            return Column(
                              children: [
                                Slidable(
                                  key: ValueKey(item),
                                  endActionPane: ActionPane(
                                    extentRatio: .2,
                                    motion: StretchMotion(),
                                    children: [
                                      staffType == 1
                                          ? SlidableAction(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              backgroundColor:
                                                  Color(0xffDD5353),
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                              icon: Icons.delete_outline,
                                              label: "Delete",
                                              onPressed: (context) {
                                                var showDialog2 = showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text("Delete"),
                                                    // title: "${filterList[index]['name']}",
                                                    content: Text(
                                                        "Do you want Delete customer  ${filterList[index]['name']}"),
                                                    actions: <Widget>[
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          // delete(filterList[index]['id'],
                                                          //     index, context);
                                                        },
                                                        child: Text("Cancel"),
                                                      ),
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          if (filterList[index]
                                                                  ['balance'] ==
                                                              0) {
                                                            delete(
                                                                filterList[
                                                                        index]
                                                                    ['id'],
                                                                index,
                                                                context,
                                                                filterList[
                                                                        index]
                                                                    ["name"]);
                                                          } else {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Cant Delete First Clear All Balance...!")));
                                                          }
                                                        },
                                                        child: Text("Ok"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                showDialog2;
                                              },
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  startActionPane: ActionPane(
                                      extentRatio: .2,
                                      motion: StretchMotion(),
                                      children: [
                                        staffType == 1
                                            ? SlidableAction(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                backgroundColor:
                                                    Color(0xff628E90),
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                icon: Icons.edit_outlined,
                                                label: "Edit",
                                                onPressed: (context) {
                                                  edit(filterList[index], index,
                                                      context);
                                                }
                                                //     _onDissmissed(index, Action.delete)
                                                )
                                            : Container(),
                                      ]),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomerViewScreen(
                                                      dbUser: db!,
                                                      user:
                                                          filterList[index])));
                                      // Navigator.of(context).pushNamed(
                                      //     CustomerViewScreen.routeName,
                                      //     arguments: {
                                      //       userList: userList[index],
                                      //       db: db
                                      //     });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 10,
                                          bottom: 10),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .13,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: .3,
                                              color: Colors.blueGrey,
                                              style: BorderStyle.solid),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width:
                                                      50, // Adjust size as needed
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: filterList[index][
                                                                "profileImage"] !=
                                                            ""
                                                        ? Colors.white
                                                        : const Color.fromRGBO(
                                                            96, 125, 139, 1),
                                                    image: filterList[index][
                                                                "profileImage"] !=
                                                            ""
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                                filterList[
                                                                        index][
                                                                    "profileImage"]),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child: filterList[index][
                                                              "profileImage"] ==
                                                          ""
                                                      ? const Icon(
                                                          Icons.account_box,
                                                          color: Colors.white)
                                                      : null,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: 50,
                                                  color:
                                                      Colors.blueGrey.shade100,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Container(
                                                  height: double.infinity,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        ' ${filterList[index]['name']}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        filterList[index]
                                                            ['custId'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .blueGrey
                                                                .shade300),
                                                      ),
                                                      SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        filterList[index]
                                                            ['phoneNo'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .blueGrey
                                                                .shade300),
                                                      ),
                                                      SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        filterList[index]
                                                            ['staffName'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 11,
                                                            color: Colors
                                                                .blueGrey
                                                                .shade300),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            filterList[index]['schemeType'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: filterList[index]
                                                            ['schemeType'] ==
                                                        "Monthly"
                                                    ? Color.fromARGB(
                                                        255, 54, 140, 45)
                                                    : Color.fromARGB(
                                                        255, 162, 41, 32)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 10,
                                ),
                              ],
                            );
                          })
                      : Container(
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Text(
                              "Please add customer details..",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                  : Container(
                      padding: EdgeInsets.all(5),
                      child: Center(
                        child: Text(
                          "Please add customer details..",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
        ),
      ),
    );
  }

  // _onDissmissed(int index, Action action) {
  //   final user = filterList[index];
  //   switch (action) {
  //     case Action.delete:
  //       delete(user);
  //   }
  // }
  var userDb = User();
  delete(String id, int index, BuildContext context, String name) async {
    userDb.delete(id).then(
      (value) {
        setState(() {});
      },
    );

    setState(() {
      filterList.removeAt(index);
    });
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("${name} dismissed")));
    initialise();
  }

  edit(Map user, int index, BuildContext context) async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateCustomerScreen(db: db!, user: user)));
  }
}

enum Action { edit, delete }
