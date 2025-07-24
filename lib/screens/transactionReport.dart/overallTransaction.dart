import 'dart:convert';

import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/transaction.dart';
import '../../providers/user.dart';
import 'transactionCard.dart';

class OverallTransactionScreen extends StatefulWidget {
  const OverallTransactionScreen({super.key});

  @override
  State<OverallTransactionScreen> createState() =>
      _OverallTransactionScreenState();
}

class _OverallTransactionScreenState extends State<OverallTransactionScreen> {
  // DateTime selectedFromDate = new DateTime.now();
  var selectedToDate = new DateTime.now();
  List peymentmthd = ["All", "Payment Proof", "Direct"];
  String? selectMt = "All";
  String custId = "";
  DateTime selectedFromDate =
      new DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime selectedEndDate =
      new DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  List branch = ["All", "Chittur", "Vadakkencherri", "Alathur"];
  String? branchId = "All";
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
  DateTime selectedDate = DateTime.now();

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
        selectedDate = pickedDate.add(Duration(days: 1));
      });

      // filterData(selectedFromDate, selectedToDate);
    });
  }

  late int staffType;
  int? branchCode;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
    });
    setState(() {
      branchCode = Staff['branch'];
    });
    setState(() {
      initialise();
    });
  }

  late User dbUser;
  List userLst = [];
  List transList = [];
  double balanceReci = 0;
  double balancePurch = 0;
  String branchName = "";
  initialise() {
    Provider.of<TransactionProvider>(context, listen: false)
        .balanceReport(selectedFromDate, selectedDate, branchId!, selectMt!)
        .then((value) {
      setState(() {
        transList = value[0];
        balanceReci = value[1];
        balancePurch = value[2];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 237, 234),
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text("Summery"),
        actions: [
          // GestureDetector(
          //   onTap: () {
          //     print("-----");
          //     Provider.of<Transaction>(context, listen: false)
          //         .getAllData()
          //         .then((value) {});
          //   },
          //   child: Container(
          //     width: 100,
          //     color: Colors.white,
          //     child: Center(
          //       child: Text(
          //         "text",
          //         style: TextStyle(color: Colors.black),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
      body: Column(
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
                            color: Colors.white,
                            border: Border.all(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(10),
                        height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "From Date",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      fontSize: 13),
                                ),
                                Text(
                                  DateFormat.yMMMd().format(selectedFromDate),
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
                            color: Colors.white,
                            border: Border.all(color: Colors.blueGrey.shade200),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * .3,
                        height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "To Date",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      fontSize: 13),
                                ),
                                Text(
                                  DateFormat.yMMMd().format(selectedToDate),
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
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expanded(
                  //   child: Container(
                  //     height: 40,
                  //     width: double.infinity,
                  //     color: Colors.white,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Branch : ",
                  //           style: TextStyle(
                  //               fontSize: 12, fontWeight: FontWeight.bold),
                  //         ),
                  //         Container(
                  //           width: 130,
                  //           child: DropdownButton(
                  //             underline: SizedBox(),
                  //             style: TextStyle(
                  //                 fontWeight: FontWeight.w600,
                  //                 fontSize: 12,
                  //                 color: Color.fromARGB(115, 0, 0, 0)),
                  //             isExpanded: true,
                  //             hint: Text(
                  //               "",
                  //               style: TextStyle(
                  //                   fontWeight: FontWeight.w600,
                  //                   fontSize: 12,
                  //                   color: Color.fromARGB(115, 0, 0, 0)),
                  //             ),
                  //             value: branchId,
                  //             items: branch.map((item) {
                  //               return DropdownMenuItem(
                  //                   value: item,
                  //                   child: Padding(
                  //                     padding: const EdgeInsets.all(8.0),
                  //                     child: Text(
                  //                       item,
                  //                       style: TextStyle(color: Colors.black),
                  //                     ),
                  //                   ));
                  //             }).toList(),
                  //             onChanged: (value) {
                  //               print(value);
                  //               setState(() {
                  //                 branchId = value as String?;
                  //               });
                  //               // initialise();
                  //             },
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Paymnt Methode : ",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 80,
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
                                // initialise();
                              },
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
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              initialise();
            },
            child: Container(
              width: MediaQuery.of(context).size.width * .2,
              height: MediaQuery.of(context).size.height * .035,
              decoration: BoxDecoration(
                  color: useColor.homeIconColor,
                  borderRadius: BorderRadius.circular(6)),
              child: Center(
                  child: Text(
                "Submit",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              )),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  height: 50,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Row(
                      //   children: [
                      //     Text(
                      //       "Branch Name  : ",
                      //       style: TextStyle(
                      //           fontSize: 12,
                      //           color: Color.fromARGB(255, 0, 0, 0)),
                      //     ),
                      //     Text(
                      //       branchId!,
                      //       style: TextStyle(
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w500,
                      //           color: Color.fromARGB(255, 0, 0, 0)),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   width: 50,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "Pyment Methode  : ",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                            Text(
                              selectMt!,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                Expanded(
                    child: Container(
                  height: 50,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(
                            "From Date  : ",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy').format(selectedFromDate),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "To Date  : ",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy').format(selectedToDate),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            // height: 70,
            color: Color.fromARGB(255, 255, 255, 255),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Balance Information ",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(162, 0, 0, 0)),
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Total Recived  : ",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 32, 110, 20)),
                            ),
                            Text(
                              balanceReci.toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 32, 110, 20)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Total Purchase  : ",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red),
                            ),
                            Text(
                              balancePurch.toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Balance Amount : ",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      Text(
                        " ${balanceReci - balancePurch}",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: transList.length > 0
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      return TransactionTile(transaction: transList[index]);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 5,
                      );
                    },
                    itemCount: transList.length)
                : Center(
                    child: Column(
                      children: [
                        Text("No Data Available..."),
                        Text("Choose Date....")
                      ],
                    ),
                  ),
          ))
        ],
      ),
    );
  }
}
