import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user.dart';
import '../home_screen.dart';
import 'customer_view.dart';
import 'update_customer.dart';

class SuperAdminSceen extends StatefulWidget {
  const SuperAdminSceen({super.key});

  @override
  State<SuperAdminSceen> createState() => _SuperAdminSceenState();
}

class _SuperAdminSceenState extends State<SuperAdminSceen> {
  List userList = [];
  late bool _IsSearching;

  final TextEditingController _searchQuery = new TextEditingController();
  late int staffType;
  int? branchId;
  var filterList = [];
  bool isLoading = true;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
    });
    setState(() {
      branchId = Staff['branch'];
    });
    initialise(branchId!);
  }

  int selectIndex = 0;
  int indexbranch = 0;

  User? db;
  initialise(int branchId) {
    db = User();
    db!.initiliase();
    db!.read(branchId).then((value) {
      setState(() {
        filterList = value != null ? value : [];
        userList = filterList;
        isLoading = false;
      });
    });

    _IsSearching = false;
  }

  Widget appBarTitle = new Text(
    "Customers",
    style: new TextStyle(color: Colors.white),
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: appBarTitle,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
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
      body: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectIndex = 0;
                        indexbranch = 0;
                      });
                      initialise(0);
                    },
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromARGB(255, 255, 255, 255),
                          border: Border.all()),
                      height: 100.0,
                      child: Center(
                        child: Text(
                          'All',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectIndex != 0
                                  ? Color.fromARGB(255, 0, 0, 0)
                                  : Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectIndex = 1;
                        indexbranch = 1;
                      });
                      initialise(1);
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromARGB(255, 255, 255, 255),
                          border: Border.all()),
                      height: 100.0,
                      child: Center(
                        child: Text(
                          'Alathur',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectIndex != 1
                                  ? Color.fromARGB(255, 0, 0, 0)
                                  : Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectIndex = 2;
                        indexbranch = 2;
                      });
                      initialise(2);
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromARGB(255, 255, 255, 255),
                          border: Border.all()),
                      height: 100.0,
                      child: Center(
                        child: Text(
                          'Chittur',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectIndex != 2
                                  ? Color.fromARGB(255, 0, 0, 0)
                                  : Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectIndex = 3;
                          indexbranch = 3;
                        });
                        initialise(3);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromARGB(255, 255, 255, 255),
                            border: Border.all()),
                        height: 100.0,
                        child: Center(
                          child: Text(
                            'Vadakkencherry',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectIndex != 3
                                    ? Color.fromARGB(255, 0, 0, 0)
                                    : Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(),
                    child: userList != null
                        ? filterList.length != 0
                            ? ListView.builder(
                                itemCount: filterList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final item = filterList[index]["id"];
                                  return Column(
                                    children: [
                                      Slidable(
                                        key: ValueKey(filterList[index]['id']),
                                        startActionPane: ActionPane(
                                          extentRatio: 0.2,
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) {
                                                edit(filterList[index], index,
                                                    context);
                                              },
                                              backgroundColor:
                                                  const Color(0xff628E90),
                                              foregroundColor: Colors.white,
                                              icon: Icons.edit_outlined,
                                              label: "Edit",
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ],
                                        ),
                                        endActionPane: ActionPane(
                                          extentRatio: 0.2,
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text("Delete"),
                                                    content: Text(
                                                        "Do you want to delete customer ${filterList[index]['name']}?"),
                                                    actions: [
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Cancel"),
                                                      ),
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                          delete(
                                                            filterList[index]
                                                                ['id'],
                                                            index,
                                                            context,
                                                          );
                                                        },
                                                        child: const Text("Ok"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              backgroundColor:
                                                  const Color(0xffDD5353),
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete_outline,
                                              label: "Delete",
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ],
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomerViewScreen(
                                                  dbUser: db!,
                                                  user: filterList[index],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.13,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 0.3,
                                                color: Colors.blueGrey,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                  child: Icon(
                                                    Icons.account_box,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Container(
                                                  width: 1,
                                                  height: 50,
                                                  color:
                                                      Colors.blueGrey.shade100,
                                                ),
                                                const SizedBox(width: 20),
                                                SizedBox(
                                                  height: double.infinity,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        filterList[index]
                                                            ['name'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        filterList[index]
                                                            ['custId'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.blueGrey
                                                              .shade300,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        filterList[index]
                                                            ['phoneNo'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.blueGrey
                                                              .shade300,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        filterList[index]
                                                            ['staffName'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 11,
                                                          color: Colors.blueGrey
                                                              .shade300,
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
          ),
        ],
      ),
    );
  }

  var userDb = User();
  delete(String id, int index, BuildContext context) async {
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
        .showSnackBar(SnackBar(content: Text("$filterList dismissed")));
  }

  edit(Map user, int index, BuildContext context) async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateCustomerScreen(db: db!, user: user)));
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
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
}
