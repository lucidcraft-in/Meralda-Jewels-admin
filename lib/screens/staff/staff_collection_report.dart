import '../../constant/colors.dart';
import '../../providers/collections.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class StaffCollectionReport extends StatefulWidget {
  StaffCollectionReport({
    Key? key,
  }) : super(key: key);

  @override
  State<StaffCollectionReport> createState() => _StaffCollectionReportState();
}

class _StaffCollectionReportState extends State<StaffCollectionReport> {
  Collection? dbCollection;
  List collectionList = [];
  double totalBalance = 0;
  String selectedValue = 'This Month';
  // DateTime selectedDate = DateTime.now();
  int? branchId;
  double commission = 0;
  DateTime today = DateTime.now();
  DateTime selectedFromDate = new DateTime.now();
  var selectedToDate = new DateTime.now();

  DateTime selectedStratDate =
      new DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime selectedEndDate =
      new DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  initialise() {
    dbCollection = Collection();
    dbCollection!.initiliase();
    dbCollection!
        .staffCollectionReport(selectedStratDate, selectedEndDate, branchId!)
        .then((value) => {
              setState(() {
                collectionList = value!;
                // totalBalance = userLst[0]['totalAmount'];

                // totalCommission(totalBalance);
              }),
            });
  }

  // totalCommission(double balance) {
  //   var temp = totalBalance * widget.commission;
  //   var perct = temp / 100;
  //   setState(() {
  //     commission = perct;
  //   });
  // }

  late int staffType;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
    });
    setState(() {
      branchId = Staff['branch'];
    });
    setState(() {
      initialise();
    });
  }

  @override
  void initState() {
    setState(() {
      selectedFromDate = DateTime(today.year, today.month + 0, 1);
    });
    super.initState();
    loginData();

    // selectedDate = DateTime.now();
  }

// from date
  _selectFromDate(BuildContext context) {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedFromDate = pickedDate;
      });
    });
  }

  // to date

  _selectToDate() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedToDate = pickedDate;
      });

      // filterData(selectedFromDate, selectedToDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text("Collection Report"),
        actions: [],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 9, right: 9, top: 9, bottom: 9),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .16,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .09,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _selectFromDate(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blueGrey.shade200),
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(10),
                                height: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "From Date",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(selectedFromDate),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade700,
                                              fontSize: 13),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 30,
                            child: Center(
                              child: Container(
                                height: double.infinity,
                                width: .9,
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _selectToDate();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blueGrey.shade200),
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * .3,
                                height: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "To Date",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(selectedToDate),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade700,
                                              fontSize: 13),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      width: double.infinity,
                      height: .6,
                      color: Colors.blueGrey.shade100,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15, bottom: 10, top: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          dbCollection = Collection();
                          dbCollection!.initiliase();
                          dbCollection!
                              .staffCollectionReport(
                                  selectedFromDate, selectedToDate, branchId!)
                              .then((value) => {
                                    setState(() {
                                      collectionList = value!;
                                      // totalBalance = userLst[0]['totalAmount'];

                                      // totalCommission(totalBalance);
                                    }),
                                  });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .2,
                          height: MediaQuery.of(context).size.height * .035,
                          decoration: BoxDecoration(
                              color: Color(0xFF073531),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: collectionList != null
                  ? collectionList.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: collectionList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  height: 100,
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey.shade400,
                                                child: Icon(
                                                  Icons.account_box,
                                                  color: Colors.white,
                                                )),
                                            Text(
                                              "${collectionList[index]["staffName"]}"
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
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
                                                  "Collected Amount : ",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  collectionList[index]
                                                          ["totalCollectedAmt"]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total Recieved from Staff : ",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  collectionList[index]
                                                          ["totalPaidAmount"]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: .6,
                                              color: Colors.blueGrey.shade100,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "pending Amount : ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  collectionList[index]
                                                          ["staffBalance"]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
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
                    ),
            ),
          ),
          // Flexible(
          //   child: Container(
          //       child: Center(
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceAround,
          //       children: [
          //         Text(
          //           "Convert to Excel",
          //           style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          //         ),
          //         Container(
          //           width: MediaQuery.of(context).size.width * .5,
          //           height: MediaQuery.of(context).size.height * .05,
          //           decoration: BoxDecoration(
          //               color: Color(0xff12244b),
          //               borderRadius: BorderRadius.circular(20)),
          //           child: OutlinedButton(
          //             onPressed: () {
          //               // getCsv();

          //               _generateCsvFile();
          //             },
          //             child: Text(
          //               "convert",
          //               style: TextStyle(
          //                 fontSize: 14,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //   )),
          // ),
        ],
      ),
    );
  }
}
