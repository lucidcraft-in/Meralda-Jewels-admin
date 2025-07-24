import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../constant/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/collections.dart';
import '../../providers/staff.dart';
import '../../providers/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';

class StaffReprotScreen extends StatefulWidget {
  StaffReprotScreen(
      {Key? key, required this.staff, required this.db, this.commission})
      : super(key: key);
  var commission;
  Map staff;
  Staff db;

  // const StaffReprotScreen({ Key key }) : super(key: key);

  @override
  State<StaffReprotScreen> createState() => _StaffReprotScreenState();
}

class _StaffReprotScreenState extends State<StaffReprotScreen> {
  User? dbUser;
  List userLst = [];
  double totalBalance = 0;
  double pendingBalanceOfStaff = 0;
  double recivedFromStaff = 0;
  String selectedValue = 'This Month';
  DateTime selectedDate = DateTime.now();
  double commission = 0;
  int? branchId;
  initialise() {
    dbUser = User();
    dbUser!.initiliase();

    dbUser!
        .readBystaffIdAndDate(widget.staff['id'], selectedDate)
        .then((value) {
      if (value != null) {
        setState(() {
          userLst = value;
          totalBalance = userLst[0]['totalAmount'];

          // recivedFromStaff = userLst[0]['recivedFromStaff'];
          // pendingBalanceOfStaff = totalBalance - recivedFromStaff;
          // totalCommission(totalBalance);
        });
      }
      isLoad = false;
    });
    getCollcetionData();
  }

  getCollcetionData() {
    setState(() {
      recivedFromStaff = 0;
    });
    Provider.of<Collection>(context, listen: false)
        .getCollcetionReport(widget.staff['id'], selectedDate)
        .then((val) {
      setState(() {
        recivedAmtStaff = val;
      });
      for (int i = 0; i < recivedAmtStaff.length; i++) {
        setState(() {
          recivedFromStaff =
              recivedFromStaff + recivedAmtStaff[0]["paidAmount"];
          pendingBalanceOfStaff = totalBalance - recivedFromStaff;
        });
      }
    });
  }

  List recivedAmtStaff = [];

  totalCommission(double balance) {
    var temp = totalBalance * widget.commission;
    var perct = temp / 100;
    setState(() {
      commission = perct;
    });
  }

  int? staffType;
  bool isCollectionList = true;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    staffType = Staff['type'];
    setState(() {
      branchId = Staff['branch'];
    });
    initialise();
  }

  @override
  void initState() {
    loginData();
    super.initState();

    selectedDate = DateTime.now();
  }

  bool isLoad = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text("Report"),
        backgroundColor: useColor.homeIconColor,
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  Text(
                    "Select Month",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isLoad = true;
                      });
                      showMonthPicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 1, 5),
                        lastDate: DateTime(DateTime.now().year + 1, 9),
                        initialDate: selectedDate ?? DateTime.now(),
                        // locale: const Locale("en"), // Uncomment if you want to support other locales
                      ).then((date) {
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                            recivedFromStaff = 0;
                            pendingBalanceOfStaff = 0;
                            totalBalance = 0;
                            isLoad = false;
                            userLst = [];
                            recivedAmtStaff = [];
                          });

                          initialise(); // Load the data based on new date
                        }
                      });
                      // showMonthPicker(
                      //   context: context,
                      //   firstDate: DateTime(DateTime.now().year - 1, 5),
                      //   lastDate: DateTime(DateTime.now().year + 1, 9),
                      //   initialDate: selectedDate ?? DateTime.now(),
                      //   // locale: Locale("en"),
                      // ).then((date) {
                      //   if (date != null) {
                      //     setState(() {
                      //       selectedDate = date;
                      //       // print("selected Date===")
                      //       // print(selectedDate);
                      //       recivedFromStaff = 0;
                      //       pendingBalanceOfStaff = 0;
                      //       totalBalance = 0;
                      //       isLoad = false;
                      //       userLst = [];
                      //       recivedAmtStaff = [];
                      //     });

                      //     initialise();
                      //   }
                      // });
                    },
                    icon: Icon(Icons.calendar_today),
                  ),
                  Text(DateFormat('MMMM').format(selectedDate))
                ],
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCollectionList = false; // Show received amount list
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: !isCollectionList
                          ? Color.fromARGB(255, 11, 11, 11)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Color.fromARGB(255, 17, 17, 17)),
                    ),
                    child: Text(
                      'Received Amount',
                      style: TextStyle(
                        color: !isCollectionList
                            ? Colors.white
                            : Color.fromARGB(255, 18, 18, 18),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCollectionList = true; // Show collection list
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCollectionList
                          ? Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Color.fromARGB(255, 15, 15, 15)),
                    ),
                    child: Text(
                      'Collection Amount',
                      style: TextStyle(
                        color: isCollectionList
                            ? Colors.white
                            : Color.fromARGB(255, 25, 25, 25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  width: double.infinity,
                  child: isLoad == false
                      ? isCollectionList == false
                          ? userLst.length > 0
                              ? ListView.builder(
                                  itemCount: userLst.length,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: <Widget>[
                                        ListTile(
                                          tileColor: Colors.white,
                                          title: Row(
                                            children: [
                                              Text(
                                                "User Name : ",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700]),
                                              ),
                                              Text(
                                                ' ${userLst[index]['name']}'
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ],
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Text(
                                                "Collection Amount : ",
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              Text(
                                                userLst[index]
                                                        ['userMonthcollection']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                              child: Icon(Icons.account_box)),
                                          onTap: () {},
                                        ),
                                      ],
                                    );
                                  })
                              : Center(
                                  child: Text(
                                    "No data Available",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                )
                          : recivedAmtStaff.isNotEmpty
                              ? ListView.builder(
                                  itemCount: recivedAmtStaff.length,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: <Widget>[
                                        ListTile(
                                          tileColor: Colors.white,
                                          title: Row(
                                            children: [
                                              Text(
                                                DateFormat("dd-MM-yyyy")
                                                    .format(
                                                        recivedAmtStaff[index]
                                                                ['date']
                                                            .toDate())
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ],
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Text(
                                                "Recived Amount : ",
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              Text(
                                                recivedAmtStaff[index]
                                                        ['paidAmount']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                              child: Icon(Icons.account_box)),
                                          onTap: () {},
                                        ),
                                      ],
                                    );
                                  })
                              : Center(
                                  child: Text(
                                    "No data Available",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                )
                      : Center(
                          child: CircularProgressIndicator(),
                        )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
          height: 100,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Total Recived from Customer",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                    ),
                    Text(
                      totalBalance.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Total Collect from Staff",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                    ),
                    Text(
                      recivedFromStaff.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Staff Pending Balance",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                    ),
                    Text(
                      "${totalBalance - recivedFromStaff}",
                      // pendingBalanceOfStaff.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              // Expanded(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       Text(
              //         "Total Commission",
              //         style: TextStyle(
              //             fontWeight: FontWeight.w400, fontSize: 13),
              //       ),
              //       Text(
              //         userLst != null
              //             ? "${commission}"
              //             : 0.0.toString(),
              //         style: TextStyle(
              //             fontWeight: FontWeight.w500, fontSize: 16),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 5,
              ),
            ],
          )),
    );
  }
}
