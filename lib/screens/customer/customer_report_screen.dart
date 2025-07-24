import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../../constant/colors.dart';
import '../../service/noti.dart';
import '../../providers/user.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'customer_view.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({Key? key}) : super(key: key);

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late User dbUser;
  List userLst = [];
  double totalBalance = 0;
  DateTime nows = new DateTime.now();
  DateTime today = DateTime.now();
  DateTime selectedFromDate = new DateTime.now();
  var selectedToDate = new DateTime.now();

  int? branchId;
  String selectedPeriod = "1 Month"; // Default selected period
  bool isCustomDate = false; // To track if custom date is selected

  List<String> filterPeriods = [
    "1 Month",
    "2 Months",
    "3 Months",
    "6 Months",
    "Custom"
  ];

  initialise(int staffType, DateTime stDate, DateTime endDate) {
    dbUser = User();
    dbUser.initiliase();
    dbUser
        .customerRportRead(Staff["id"], stDate, endDate, selectMt!, staffType)
        .then((value) {
      if (value != null) {
        setState(() {
          filterList = userLst = value!;
        });
      }
    });
  }

  @override
  void initState() {
    setState(() {
      // Default to 1 month
      selectedFromDate = DateTime(today.year, today.month - 1, today.day);
      selectedToDate =
          DateTime(today.year, today.month, today.day, 23, 59, 59, 999);
    });
    loginData();
    super.initState();
  }

  File? f;
  int _counter = 0;

  User db = User();
  late int staffType;
  var Staff;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
    });
    initialise(staffType, selectedFromDate, selectedToDate);
  }

  List peymentmthd = ["All", "Payment Proof", "Direct"];
  String? selectMt = "All";

  // Method to update date range based on selected period
  void updateDateRange(String period) {
    setState(() {
      selectedPeriod = period;
      isCustomDate = period == "Custom";
    });

    if (period == "Custom") {
      // For custom, keep current dates but show the date pickers
      return;
    }

    // Calculate dates for predefined periods
    DateTime now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    DateTime startDate;

    switch (period) {
      case "1 Month":
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case "2 Months":
        startDate = DateTime(now.year, now.month - 2, now.day);
        break;
      case "3 Months":
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case "6 Months":
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      default:
        startDate = DateTime(now.year, now.month - 1, now.day);
    }

    setState(() {
      selectedFromDate = startDate;
      selectedToDate = endDate;
    });
  }

  void _generateCsvFile() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    List<List<dynamic>> rows = [];

    List<dynamic> row = [];
    rows.add(["name", "Paid amount", "Purchase Amount", "Balance"]);
    for (int i = 0; i < userLst.length; i++) {
      List<dynamic> row = [];
      row.add(userLst[i]["name"]);
      row.add(userLst[i]["paidAmount"]);
      row.add(userLst[i]["purchase"]);
      row.add(userLst[i]["custBalance"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    String dir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD);

    String file = "$dir";

    f = File(file + "/customer-report.csv");

    f!.writeAsString(csv);

    setState(() {
      _counter++;
    });

    Noti.showBigTextNotification(
        title: "Download Complete",
        body: "customer-report.csv",
        fln: flutterLocalNotificationsPlugin,
        payload: f);
    openFile();
  }

  Future<void> openFile() async {
    var filePath;

    if (f != null) {
      filePath = f;
      final _result = await OpenFile.open("${filePath}");
    } else {
      // User canceled the picker
    }

    setState(() {});
  }

  var _openResult = 'Unknown';

  // Custom date picker for from date
  _selectFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedFromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedFromDate = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day, 00, 00, 00, 000);
      });
    }
  }

  // Custom date picker for to date
  _selectToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedToDate = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day, 23, 59, 59, 999);
      });
    }
  }

  List filterList = [];
  final TextEditingController _searchQuery = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text("Customer Report"),
        actions: [
          IconButton(
              onPressed: () {
                _generateCsvFile();
              },
              icon: Icon(Icons.download))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              // Filter Buttons Section
              Padding(
                padding: const EdgeInsets.all(9.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      // Period Filter Buttons
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Period:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: filterPeriods.map((period) {
                                bool isSelected = selectedPeriod == period;
                                return GestureDetector(
                                  onTap: () {
                                    updateDateRange(period);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? useColor.homeIconColor
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? useColor.homeIconColor
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      period,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Custom Date Selection (only show when Custom is selected)
                      if (isCustomDate) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            color: Colors.blueGrey.shade100,
                            thickness: 0.8,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                /// FROM DATE
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectFromDate(context),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined,
                                                size: 20,
                                                color: Colors.blueGrey),
                                            SizedBox(width: 8),
                                            Text(
                                              "From",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blueGrey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(selectedFromDate),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// DIVIDER
                                Container(
                                  width: 1,
                                  height: 40,
                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                  color: Colors.blueGrey.shade100,
                                ),

                                /// TO DATE
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectToDate(context),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined,
                                                size: 20,
                                                color: Colors.blueGrey),
                                            SizedBox(width: 8),
                                            Text(
                                              "To",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blueGrey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(selectedToDate),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],

                      // Date Range Display and Go Button
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selected Range:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  "${DateFormat.yMMMd().format(selectedFromDate)} - ${DateFormat.yMMMd().format(selectedToDate)}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  userLst = [];
                                  filterList = [];
                                });
                                dbUser = User();
                                dbUser.initiliase();
                                dbUser
                                    .customerRportRead(
                                        Staff["id"],
                                        selectedFromDate,
                                        selectedToDate,
                                        selectMt!,
                                        staffType)
                                    .then((value) => {
                                          setState(() {
                                            filterList = userLst = value!;
                                          })
                                        });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * .2,
                                height:
                                    MediaQuery.of(context).size.height * .035,
                                decoration: BoxDecoration(
                                    color: useColor.homeIconColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  "Go",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Payment Method Dropdown
              Container(
                height: 40,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment Method : ${selectMt}",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: 100,
                        child: DropdownButton(
                          underline: SizedBox(),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color.fromARGB(115, 0, 0, 0)),
                          isExpanded: true,
                          hint: Text(
                            "",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color.fromARGB(115, 0, 0, 0)),
                          ),
                          value: selectMt,
                          items: peymentmthd.map((item) {
                            return DropdownMenuItem(
                                value: item,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectMt = value as String?;
                            });
                            initialise(
                              staffType,
                              selectedFromDate,
                              selectedToDate,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchQuery,
                  style: new TextStyle(
                    color: Color.fromARGB(255, 38, 37, 37),
                  ),
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(Icons.search,
                          color: Color.fromARGB(255, 6, 6, 6)),
                      hintText: "Search...",
                      hintStyle:
                          new TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                  onChanged: (string) {
                    setState(() {
                      filterList = userLst
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
                ),
              ),

              // Data List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: filterList.isNotEmpty
                          ? filterList.length > 0
                              ? ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: filterList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomerViewScreen(
                                                        dbUser: db,
                                                        user: filterList[
                                                            index])));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            height: 100,
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 100,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      CircleAvatar(
                                                          radius: 15,
                                                          backgroundColor:
                                                              Colors.grey
                                                                  .shade400,
                                                          child: Icon(
                                                            Icons.account_box,
                                                            size: 18,
                                                            color: Colors.white,
                                                          )),
                                                      Text(
                                                        "${filterList[index]["name"]}"
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        "${filterList[index]["custId"]}"
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Paid Amount : ",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          Text(
                                                            filterList[index][
                                                                    "paidAmount"]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Purchase : ",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          Text(
                                                            filterList[index]
                                                                    ["purchase"]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black),
                                                          )
                                                        ],
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        height: .6,
                                                        color: Colors
                                                            .blueGrey.shade100,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Balance : ",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          Text(
                                                            filterList[index][
                                                                    "custBalance"]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 10,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                        ],
                                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
