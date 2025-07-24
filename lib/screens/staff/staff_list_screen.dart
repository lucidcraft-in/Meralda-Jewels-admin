import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constant/colors.dart';
import '../../screens/staff/staff_report_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/staff.dart';
import './create_staff_screen.dart';
import './update_staff_scree.dart';
import './staff_view_screen.dart';
import './staff_reciept.dart';
import 'paymentReport.dart';

class StaffListScreen extends StatefulWidget {
  static const routeName = '/staff-list-screen';

  @override
  _StaffListScreenState createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  Staff? db;
  List staffList = [];
  bool isLoading = true;
  int? branchId;
  initialise() {
    db = Staff();
    db!.initiliase();
    db!.read().then((value) => {
          setState(() {
            staffList = value!;
            // print(staffList);
            isLoading = false;
          }),
        });
  }

  bool ifType = false;
  @override
  void initState() {
    loginData();
    super.initState();
  }

  int? staffType;
  String? staffId;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    staffType = Staff['type'];
    staffId = Staff["id"];
    // print("============");
    // print(staffType);
    setState(() {
      branchId = Staff['branch'];
    });
    initialise();
  }

  Future<void> _delete(String id) async {
    try {
      try {
        Provider.of<Staff>(context, listen: false).delete(id).then((value) {
          final snackBar =
              SnackBar(content: const Text('Deleted Successfully !'));

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.of(context).pop();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => StaffListScreen()));
          setState(() {});
        });

        // await showDialog(
        //   context: context,
        //   builder: (ctx) => AlertDialog(
        //     title: Text('Succes!'),
        //     content: Text('Deleted Successfully'),
        //     actions: <Widget>[
        //       FlatButton(
        //         child: Text('Okay'),
        //         onPressed: () {
        //           Navigator.pushReplacement(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => StaffListScreen()));
        //           setState(() {});
        //         },
        //       )
        //     ],
        //   ),
        // );
      } catch (err) {
        print(err);
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
      setState(() {
        // _isLoading = false;s
      });
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text('Staffs'),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0, top: 8, bottom: 8),
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StaffReciept()));
                  },
                  style:
                      OutlinedButton.styleFrom(backgroundColor: Colors.black26),
                  child: Text(
                    "Payment Recive",
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: useColor.homeIconColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateStaffScreen(
                        staffType: 0,
                      ))).then(
            (value) {
              initialise();
            },
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
                child: staffList.isNotEmpty
                    ? staffList.length > 0
                        ? ListView.builder(
                            itemCount: staffList.length,
                            itemBuilder: (BuildContext context, int index) {
                              // print(staffList[index]['type']);
                              return Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 5,
                                          top: 5,
                                          bottom: 10),
                                      height: 100,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: .1,
                                              color: Colors.blueGrey,
                                              style: BorderStyle.solid),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                              backgroundColor: Colors.blueGrey,
                                              child: Icon(
                                                Icons.account_box,
                                                color: Colors.white,
                                              )),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            width: 1,
                                            height: 50,
                                            color: Colors.blueGrey.shade100,
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            height: double.infinity,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ' ${staffList[index]['staffName']}'
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  staffList[index]['phoneNo'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors
                                                          .blueGrey.shade300),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                                child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: PopupMenuButton(
                                                        icon: Icon(
                                                          FontAwesomeIcons
                                                              .ellipsisVertical,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                        itemBuilder:
                                                            (BuildContext
                                                                context) {
                                                          return [
                                                            PopupMenuItem(
                                                                child:
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => StaffViewScreen(db: db!, staff: staffList[index])));
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.notes,
                                                                              color: Colors.blue,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Flexible(
                                                                              child: Text(
                                                                                " ${staffList[index]['staffName']}" + "'S Customers",
                                                                                style: TextStyle(fontSize: 16),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ))),
                                                            PopupMenuItem(
                                                                child:
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => StaffReprotScreen(db: db!, staff: staffList[index], commission: staffList[index]["commission"])));
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.notes,
                                                                              color: Colors.blue,
                                                                            ),
                                                                            Text(" Staff Report "),
                                                                          ],
                                                                        ))),
                                                            PopupMenuItem(
                                                                child:
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => PaymentReport(
                                                                                        staffid: staffList[index]['id'],
                                                                                      )));
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.notes,
                                                                              color: Colors.blue,
                                                                            ),
                                                                            Text("Collection Report "),
                                                                          ],
                                                                        ))),
                                                            PopupMenuItem(
                                                                child:
                                                                    GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => UpdateStaffScreen(
                                                                            db:
                                                                                db!,
                                                                            staff:
                                                                                staffList[index])));
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                  ),
                                                                  Text("Edit")
                                                                ],
                                                              ),
                                                            )),
                                                            PopupMenuItem(
                                                                child: staffList[index]
                                                                            [
                                                                            'id'] !=
                                                                        staffId
                                                                    ? GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  content: Container(
                                                                                    width: 300,
                                                                                    height: 100,
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text("Do You Want To Delete...!"),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                                          children: [
                                                                                            GestureDetector(
                                                                                                onTap: () {
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                child: Text("Cancel")),
                                                                                            SizedBox(
                                                                                              width: 20,
                                                                                            ),
                                                                                            GestureDetector(
                                                                                                onTap: () {
                                                                                                  Navigator.pop(context);
                                                                                                  _delete(staffList[index]['id']);
                                                                                                },
                                                                                                child: Text("Ok"))
                                                                                          ],
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              });
                                                                        },

                                                                        ///
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red,
                                                                            ),
                                                                            Text("Delete")
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container()),
                                                          ];
                                                        }))),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 10,
                                  ),
                                ],
                              );
                            })
                        : Center(
                            child: Text(
                              "No data Available",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          )
                    : Center(
                        child: CircularProgressIndicator(),
                      ))
          ],
        ),
      ),
      // ),
    );
  }
}
