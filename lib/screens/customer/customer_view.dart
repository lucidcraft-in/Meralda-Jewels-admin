import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../constant/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen.dart';
import 'pay_amount.dart';
import 'purchase_amount.dart';
import '../../providers/user.dart';
import '../../providers/transaction.dart';
import 'update_transaction.dart';
import 'package:provider/provider.dart';

class CustomerViewScreen extends StatefulWidget {
  static const routeName = '/customer-view';
  CustomerViewScreen({Key? key, this.user, this.dbUser}) : super(key: key);
  Map? user;
  User? dbUser;

  @override
  _CustomerViewScreenState createState() => _CustomerViewScreenState();
}

class _CustomerViewScreenState extends State<CustomerViewScreen> {
  int selectedIndex = -1;
  bool isClick = false;
  TransactionProvider? db;

  List transactionList = [];
  List filteredTransactionList = [];
  List alllist = [];
  double balanceAmt = 0;
  double balancegram = 0;
  double averageGramRate = 0;
  var _isLoading = false;
  initialise() {
    db = TransactionProvider();
    db!.initiliase();
    // print(widget.user!['id']);
    db!.read(widget.user!['id']).then((value) {
      setState(() {
        _isLoading = true;
        if (value != null) {
          alllist = value;

          transactionList = alllist[0];
          balanceAmt = widget.user!["balance"];
          balancegram = alllist[2];
        }
      });
    });
  }

  getUpdateBalance() {
    Provider.of<User>(context, listen: false)
        .getUserBalance(widget.user!["custId"])
        .then((val) {
      setState(() {
        data = val;
      });
    });
    initialise();
  }

  List data = [];

  int staffType = 0;
  Future loginData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var Staff = jsonDecode(prefs.getString('staff')!);
      setState(() {
        staffType = Staff['type'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    loginData();
    super.initState();
    getUpdateBalance();

    // userId = ModalRoute.of(context).settings.arguments;
  }

  Future<void> _delete() async {
    try {
      try {
        Provider.of<User>(context, listen: false)
            .delete(widget.user!['id'])
            .then((value) {
          initialise();
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => CustomerScreen()));
        });
      } catch (err) {
        // print(err);
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
        _isLoading = false;
      });
    } catch (err) {}
  }

  Set<int> selectedTransactions = {};
  bool isSelect = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          title: Text(widget.user!['name']),
          backgroundColor: useColor.homeIconColor,
          actions: [
            if (staffType == 1)
              IconButton(
                icon: Image(
                  image: AssetImage(
                      "assets/images/subscription-business-model_11869476.png"),
                  color: Colors.white,
                ),
                onPressed: () {
                  _showCloseCustomerDialog(context);
                },
              )
          ],
          // actions: [
          // staffType != 0
          //     ?
          // PopupMenuButton(
          //   icon: Icon(Icons.settings),
          //   itemBuilder: (BuildContext context) {
          //     return [
          //       PopupMenuItem(
          //         child: GestureDetector(
          //             onTap: () {
          //               Navigator.pushReplacement(
          //                   context,
          //                   MaterialPageRoute(
          //                       builder: (context) =>
          //                           UpdateCustomerScreen(
          //                               db: widget.dbUser,
          //                               user: widget.user)));
          //             },
          //             child: ListTile(
          //               leading: Icon(
          //                 Icons.edit,
          //                 color: Colors.blueGrey,
          //               ),
          //               title: Text("Edit"),
          //             )),
          //       ),
          //       PopupMenuItem(
          //         child: GestureDetector(
          //             onTap: () {
          //               // Navigator.push(
          //               //     context,
          //               //     MaterialPageRoute(
          //               //         builder: (context) =>
          //               //             UpdateCustomerScreen(
          //               //                 db: widget.dbUser,
          //               //                 user: widget.user)));
          //             },
          //             child: GestureDetector(
          //               onTap: () {
          //                 showDialog(
          //                     context: context,
          //                     builder: (context) {
          //                       return AlertDialog(
          //                         content: Container(
          //                           width: 300,
          //                           height: 100,
          //                           child: Column(
          //                             mainAxisAlignment:
          //                                 MainAxisAlignment.spaceAround,
          //                             crossAxisAlignment:
          //                                 CrossAxisAlignment.start,
          //                             children: [
          //                               Text(
          //                                   "Do You Want To Delete...!"),
          //                               Row(
          //                                 mainAxisAlignment:
          //                                     MainAxisAlignment.end,
          //                                 children: [
          //                                   GestureDetector(
          //                                       onTap: () {
          //                                         Navigator.pop(
          //                                             context);
          //                                       },
          //                                       child: Text("Cancel")),
          //                                   SizedBox(
          //                                     width: 20,
          //                                   ),
          //                                   GestureDetector(
          //                                       onTap: () {
          //                                         _delete();
          //                                       },
          //                                       child: Text("Ok"))
          //                                 ],
          //                               )
          //                             ],
          //                           ),
          //                         ),
          //                       );
          //                     });
          //               },
          //               child: ListTile(
          //                 leading: Icon(
          //                   Icons.delete_forever,
          //                   color: Colors.red,
          //                 ),
          //                 title: Text("Delete"),
          //               ),
          //             )),
          //       ),
          //     ];
          //   })
          // Container()
          // : Container()
          // ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        width: 1.0,
                        color: Colors.blueGrey.shade200,
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * .1,
                        child: Row(
                          children: [
                            if (widget.user!["schemeType"] != "Swarna Samridhi")
                              Expanded(
                                  child: Container(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Available balance is",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontFamily: 'latto'),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.rupee,
                                          size: 17,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          data.isNotEmpty
                                              ? data[0]["balance"].toString()
                                              : 0.0.toString(),
                                          // alllist.isNotEmpty
                                          //     ? " + ₹ ${balanceAmt.toString()}"
                                          //     : " + ₹ 00",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'latto',
                                              fontSize: 15),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            // if (widget.user!["schemeType"] == "Swarna Samridhi")
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Container(
                                width: 1,
                                height: 100,
                                color: Colors.black12,
                              ),
                            ),
                            if (widget.user!["schemeType"] == "Swarna Samridhi")
                              Expanded(
                                  child: Container(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Total Gram ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontFamily: 'latto'),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.coins,
                                          size: 17,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          data.isNotEmpty
                                              ? data[0]["total_gram"]
                                                  .toStringAsFixed(3)
                                              : 0.toString(),
                                          // alllist != null
                                          //     ? " ${balancegram.toStringAsFixed(3)}"
                                          //     : "0.00",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'latto',
                                              fontSize: 15),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ))
                          ],
                        ),
                      ),
                      staffType == 1
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .32,
                                  height:
                                      MediaQuery.of(context).size.width * .1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PayAmountScreen(
                                                      user: widget.user!,
                                                      dbUser: widget.dbUser!,
                                                      userid:
                                                          widget.user!['id'],
                                                      custName:
                                                          widget.user!['name'],
                                                      token:
                                                          widget.user!['token'],
                                                      balance: balanceAmt
                                                          .toDouble()))).then(
                                          (value) {
                                        if (value == true) {
                                          setState(() {
                                            getUpdateBalance();
                                          });
                                        }
                                      });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                side: BorderSide(
                                                    color: Colors.green)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green,
                                        ),
                                        Text(
                                          "Reciept",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .32,
                                  height:
                                      MediaQuery.of(context).size.width * .1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PurchaseAmountScreen(
                                                      user: widget.user!,
                                                      dbUser: widget.dbUser!,
                                                      userid:
                                                          widget.user!['id'],
                                                      token:
                                                          widget.user!['token'],
                                                      balance:
                                                          balanceAmt.toDouble(),
                                                      custName: widget.user![
                                                          'name']))).then(
                                          (value) {
                                        if (value == true) {
                                          setState(() {
                                            getUpdateBalance();
                                          });
                                        }
                                      });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                side: BorderSide(
                                                    color: Colors.red)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Icon(
                                          Icons.arrow_upward,
                                          color: Colors.red,
                                        ),
                                        Text(
                                          "Purchase",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * .32,
                              height: MediaQuery.of(context).size.width * .1,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PayAmountScreen(
                                              user: widget.user!,
                                              dbUser: widget.dbUser!,
                                              userid: widget.user!['id'],
                                              custName: widget.user!['name'],
                                              token: widget.user!['token'],
                                              balance: balanceAmt
                                                  .toDouble()))).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        getUpdateBalance();
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            side: BorderSide(
                                                color: Colors.green)))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      "Reciept",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              if (widget.user!["schemeType"] == "Ponkoot")
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: useColor.homeIconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Average Gram Rate: ${averageGramRate.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Expanded(
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Container(
              //       child: alllist.isNotEmpty
              //           ? ListView.builder(
              //               shrinkWrap: true,
              //               itemCount: transactionList.length,
              //               itemBuilder: (BuildContext context, int index) {
              //                 DateTime myDateTime =
              //                     (transactionList[index]['date']).toDate();
              //                 // print(myDateTime);
              //                 // String formattedDate = DateFormat('dd/MM/yyyy')
              //                 //     .format(transactionList[index]['date']);
              //                 bool isSelected =
              //                     selectedTransactions.contains(index);
              //                 return GestureDetector(
              //                   child: Container(
              //                     decoration: BoxDecoration(
              //                         borderRadius: BorderRadius.circular(15)),
              //                     child: Column(
              //                       children: [
              //                         Container(
              //                           color: Colors.grey.shade300,
              //                           child: Row(
              //                             mainAxisAlignment:
              //                                 MainAxisAlignment.spaceBetween,
              //                             children: [
              //                               Container(
              //                                 padding:
              //                                     EdgeInsets.only(left: 10),
              //                                 height: 35,
              //                                 color: Colors.grey.shade300,
              //                                 child: Align(
              //                                     alignment:
              //                                         Alignment.centerLeft,
              //                                     child: Text(
              //                                       DateFormat
              //                                               .yMMMd() // Format for date like "Sep 24, 2024"
              //                                           .add_jm() // Format for time like "5:08 PM"
              //                                           .format(myDateTime)
              //                                           .toString(),
              //                                       style: TextStyle(
              //                                           color: Colors.black87,
              //                                           fontSize: 12,
              //                                           fontWeight:
              //                                               FontWeight.w600),
              //                                     )),
              //                               ),
              //                               Padding(
              //                                 padding:
              //                                     const EdgeInsets.all(8.0),
              //                                 child: GestureDetector(
              //                                   onTap: () {
              //                                     setState(() {
              //                                       if (isSelected) {
              //                                         selectedTransactions
              //                                             .remove(index);
              //                                       } else {
              //                                         selectedTransactions
              //                                             .add(index);
              //                                       }
              //                                     });
              //                                     printSelectedTransactions();
              //                                   },
              //                                   child: Icon(
              //                                     isSelected
              //                                         ? Icons
              //                                             .check_box // Checked
              //                                         : Icons
              //                                             .check_box_outline_blank, // Unchecked
              //                                     color: isSelected
              //                                         ? Colors.green
              //                                         : null,
              //                                   ),
              //                                 ),
              //                               )
              //                             ],
              //                           ),
              //                         ),
              //                         Container(
              //                           color: Colors.white,
              //                           height: 70,
              //                           child: ListTile(
              //                             leading: Container(
              //                               padding: EdgeInsets.only(right: 10),
              //                               child: transactionList[index]
              //                                           ['transactionType'] ==
              //                                       0
              //                                   ? FaIcon(
              //                                       FontAwesomeIcons.plusCircle,
              //                                       size: 22,
              //                                       color: Colors.green[700],
              //                                     )
              //                                   : FaIcon(
              //                                       FontAwesomeIcons
              //                                           .minusCircle,
              //                                       size: 22,
              //                                       color: Colors.red[700],
              //                                     ),
              //                             ),
              //                             title: Row(
              //                               children: [
              //                                 Text(
              //                                     "${transactionList[index]['note']}"
              //                                         .toUpperCase()),
              //                                 Text(
              //                                   transactionList[index][
              //                                               'transactionMode'] ==
              //                                           "online"
              //                                       ? "${transactionList[index]['transactionMode']}"
              //                                       : "",
              //                                   style: TextStyle(
              //                                       fontSize: 12,
              //                                       fontFamily: "latto",
              //                                       fontWeight: FontWeight.bold,
              //                                       color: Color.fromARGB(
              //                                           221, 47, 144, 37)),
              //                                 ),
              //                               ],
              //                             ),
              //                             subtitle: Row(
              //                               children: [
              //                                 Text(
              //                                   "Invoice No : " +
              //                                       "${transactionList[index]['merchentTransactionId']}"
              //                                           .toUpperCase(),
              //                                   style: TextStyle(
              //                                       fontSize: 11,
              //                                       fontFamily: "latto",
              //                                       color: Colors.black87),
              //                                 ),
              //                               ],
              //                             ),
              //                             trailing: Column(
              //                               children: [
              //                                 Text(
              //                                   widget.user!["schemeType"] !=
              //                                           "Swarna Samridhi"
              //                                       ? "₹ ${transactionList[index]['amount'].toString()}"
              //                                       : "${transactionList[index]['gramWeight'].toString()} gram",
              //                                   style: TextStyle(
              //                                       fontSize: 14,
              //                                       fontFamily: "latto",
              //                                       fontWeight: FontWeight.bold,
              //                                       color: Colors.black87),
              //                                 ),
              //                                 if (widget.user!["schemeType"] ==
              //                                     "Ponkoot")
              //                                   SizedBox(height: 5),
              //                                 if (widget.user!["schemeType"] ==
              //                                     "Ponkoot")
              //                                   Text(
              //                                     transactionList[index]
              //                                             ['gramPriceInvestDay']
              //                                         .toString(),
              //                                   ),
              //                               ],
              //                             ),
              //                           ),
              //                         ),
              //                         // Text(DateTime.parse(formattedDate)
              //                         //     .toString()),
              //                         Container(
              //                           height: 1,
              //                           color: Colors.black12,
              //                         ),
              //                         Container(
              //                             height: 40,
              //                             width: double.infinity,
              //                             color: Colors.white,
              //                             child: Padding(
              //                               padding: const EdgeInsets.only(
              //                                   left: 20,
              //                                   right: 20,
              //                                   top: 8,
              //                                   bottom: 8),
              //                               child: Row(
              //                                 children: [
              //                                   Icon(
              //                                     Icons.list_alt,
              //                                     color: Colors.grey.shade600,
              //                                   ),
              //                                   SizedBox(
              //                                     width: 20,
              //                                   ),
              //                                   Text(
              //                                     "Transaction Details",
              //                                     style: TextStyle(
              //                                       fontFamily: 'latto',
              //                                       fontSize: 12,
              //                                       color: Colors.black87,
              //                                     ),
              //                                   ),
              //                                   Expanded(
              //                                     child: Align(
              //                                       alignment:
              //                                           Alignment.centerRight,
              //                                       child: GestureDetector(
              //                                         onTap: () {
              //                                           setState(() {
              //                                             selectedIndex = index;
              //                                             isClick = true;
              //                                           });
              //                                         },
              //                                         child: isClick == false
              //                                             ? Icon(Icons
              //                                                 .keyboard_arrow_down)
              //                                             : GestureDetector(
              //                                                 onTap: () {
              //                                                   setState(() {
              //                                                     selectedIndex =
              //                                                         -1;
              //                                                     isClick =
              //                                                         false;
              //                                                   });
              //                                                 },
              //                                                 child: Icon(Icons
              //                                                     .keyboard_arrow_up)),
              //                                       ),
              //                                     ),
              //                                   )
              //                                 ],
              //                               ),
              //                             )),
              //                         selectedIndex == index
              //                             ? Container(
              //                                 // height: 220,
              //                                 color: Colors.white,
              //                                 child: Padding(
              //                                   padding: const EdgeInsets.only(
              //                                       left: 10, right: 10),
              //                                   child: Column(
              //                                     mainAxisAlignment:
              //                                         MainAxisAlignment
              //                                             .spaceEvenly,
              //                                     children: [
              //                                       if (widget.user![
              //                                               "schemeType"] ==
              //                                           "Swarna Samridhi")
              //                                         Row(
              //                                           mainAxisAlignment:
              //                                               MainAxisAlignment
              //                                                   .spaceBetween,
              //                                           children: [
              //                                             Text(
              //                                               "Gram Price",
              //                                               style: TextStyle(
              //                                                 fontFamily:
              //                                                     'latto',
              //                                                 fontSize: 12,
              //                                                 color: Colors
              //                                                     .black87,
              //                                               ),
              //                                             ),
              //                                             Text(
              //                                               transactionList[
              //                                                           index][
              //                                                       'gramPriceInvestDay']
              //                                                   .toString(),
              //                                               style: TextStyle(
              //                                                 fontFamily:
              //                                                     'latto',
              //                                                 fontSize: 12,
              //                                                 color: Colors
              //                                                     .black87,
              //                                               ),
              //                                             )
              //                                           ],
              //                                         ),
              //                                       if (widget.user![
              //                                               "schemeType"] ==
              //                                           "Swarna Samridhi")
              //                                         Row(
              //                                           mainAxisAlignment:
              //                                               MainAxisAlignment
              //                                                   .spaceBetween,
              //                                           children: [
              //                                             Text(
              //                                               "Gram Weight",
              //                                               style: TextStyle(
              //                                                 fontFamily:
              //                                                     'latto',
              //                                                 fontSize: 12,
              //                                                 color: Colors
              //                                                     .black87,
              //                                               ),
              //                                             ),
              //                                             Text(
              //                                               transactionList[
              //                                                           index][
              //                                                       'gramWeight']
              //                                                   .toString(),
              //                                               style: TextStyle(
              //                                                 fontFamily:
              //                                                     'latto',
              //                                                 fontSize: 12,
              //                                                 color: Colors
              //                                                     .black87,
              //                                               ),
              //                                             )
              //                                           ],
              //                                         ),
              //                                       Container(
              //                                         height: 1,
              //                                         color: Colors.black12,
              //                                       ),
              //                                       Row(
              //                                         mainAxisAlignment:
              //                                             MainAxisAlignment
              //                                                 .spaceBetween,
              //                                         children: [
              //                                           Text(
              //                                             "Paid Amount",
              //                                             style: TextStyle(
              //                                               fontFamily: 'latto',
              //                                               fontSize: 12,
              //                                               color:
              //                                                   Colors.black87,
              //                                             ),
              //                                           ),
              //                                           Text(
              //                                             " ₹ ${transactionList[index]['amount'].toString()}",
              //                                             style: TextStyle(
              //                                                 fontSize: 14,
              //                                                 fontFamily:
              //                                                     "latto",
              //                                                 fontWeight:
              //                                                     FontWeight
              //                                                         .bold,
              //                                                 color: Colors
              //                                                     .black87),
              //                                           )
              //                                         ],
              //                                       ),
              //                                       // staffType == 1
              //                                       //     ?
              //                                       Row(
              //                                         children: [
              //                                           IconButton(
              //                                             onPressed: () {
              //                                               Navigator.push(
              //                                                   context,
              //                                                   MaterialPageRoute(
              //                                                       builder: (context) => UpdateTransaction(
              //                                                           user: widget
              //                                                               .user!,
              //                                                           dbUser: widget
              //                                                               .dbUser!,
              //                                                           db: db!,
              //                                                           transaction:
              //                                                               transactionList[
              //                                                                   index],
              //                                                           staffType:
              //                                                               staffType)));
              //                                             },
              //                                             icon: const Icon(
              //                                               Icons.edit,
              //                                               color:
              //                                                   Colors.blueGrey,
              //                                             ),
              //                                           ),
              //                                         ],
              //                                       )
              //                                       // : Container(),
              //                                     ],
              //                                   ),
              //                                 ),
              //                               )
              //                             : SizedBox(),
              //                         SizedBox(
              //                           height: 5,
              //                         )
              //                       ],
              //                     ),
              //                   ),
              //                 );
              //               })
              //           : Text("No Data Available...."),
              //     ),
              //   ),
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: alllist.isNotEmpty
                        ? Column(
                            children: [
                              // Check All button container at the top
                              Container(
                                color: Colors.grey.shade300,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "All Transactions",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          // If all transactions are selected, clear the selection
                                          // Otherwise, select all transactions
                                          if (selectedTransactions.length ==
                                              transactionList.length) {
                                            selectedTransactions.clear();
                                          } else {
                                            selectedTransactions.clear();
                                            for (int i = 0;
                                                i < transactionList.length;
                                                i++) {
                                              selectedTransactions.add(i);
                                            }
                                          }
                                        });
                                        printSelectedTransactions();
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            "Check All",
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            selectedTransactions.length ==
                                                    transactionList.length
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color:
                                                selectedTransactions.length ==
                                                        transactionList.length
                                                    ? Colors.green
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // List of transactions
                              Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: transactionList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      DateTime myDateTime =
                                          (transactionList[index]['date'])
                                              .toDate();

                                      bool isSelected =
                                          selectedTransactions.contains(index);
                                      return GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            children: [
                                              Container(
                                                color: Colors.grey.shade300,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      height: 35,
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            DateFormat
                                                                    .yMMMd() // Format for date like "Sep 24, 2024"
                                                                .add_jm() // Format for time like "5:08 PM"
                                                                .format(
                                                                    myDateTime)
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            if (isSelected) {
                                                              selectedTransactions
                                                                  .remove(
                                                                      index);
                                                            } else {
                                                              selectedTransactions
                                                                  .add(index);
                                                            }
                                                          });
                                                          printSelectedTransactions();
                                                        },
                                                        child: Icon(
                                                          isSelected
                                                              ? Icons
                                                                  .check_box // Checked
                                                              : Icons
                                                                  .check_box_outline_blank, // Unchecked
                                                          color: isSelected
                                                              ? Colors.green
                                                              : null,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),

                                              // Rest of the transaction item UI remains the same
                                              Container(
                                                color: Colors.white,
                                                height: 70,
                                                child: ListTile(
                                                  leading: Container(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: transactionList[
                                                                    index][
                                                                'transactionType'] ==
                                                            0
                                                        ? FaIcon(
                                                            FontAwesomeIcons
                                                                .plusCircle,
                                                            size: 22,
                                                            color: Colors
                                                                .green[700],
                                                          )
                                                        : FaIcon(
                                                            FontAwesomeIcons
                                                                .minusCircle,
                                                            size: 22,
                                                            color:
                                                                Colors.red[700],
                                                          ),
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Text(
                                                          "${transactionList[index]['note']}"
                                                              .toUpperCase()),
                                                      Text(
                                                        transactionList[index][
                                                                    'transactionMode'] ==
                                                                "online"
                                                            ? "${transactionList[index]['transactionMode']}"
                                                            : "",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontFamily: "latto",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    221,
                                                                    47,
                                                                    144,
                                                                    37)),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      Text(
                                                        "Invoice No : " +
                                                            "${transactionList[index]['merchentTransactionId']}"
                                                                .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            fontFamily: "latto",
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Column(
                                                    children: [
                                                      Text(
                                                        widget.user![
                                                                    "schemeType"] !=
                                                                "Swarna Samridhi"
                                                            ? "₹ ${transactionList[index]['amount'].toString()}"
                                                            : "${transactionList[index]['gramWeight'].toString()} gram",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily: "latto",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87),
                                                      ),
                                                      if (widget.user![
                                                              "schemeType"] ==
                                                          "Ponkoot")
                                                        SizedBox(height: 5),
                                                      if (widget.user![
                                                              "schemeType"] ==
                                                          "Ponkoot")
                                                        Text(
                                                          transactionList[index]
                                                                  [
                                                                  'gramPriceInvestDay']
                                                              .toString(),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                height: 1,
                                                color: Colors.black12,
                                              ),
                                              Container(
                                                  height: 40,
                                                  width: double.infinity,
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 20,
                                                            top: 8,
                                                            bottom: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.list_alt,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Text(
                                                          "Transaction Details",
                                                          style: TextStyle(
                                                            fontFamily: 'latto',
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  selectedIndex =
                                                                      index;
                                                                  isClick =
                                                                      true;
                                                                });
                                                              },
                                                              child: isClick ==
                                                                      false
                                                                  ? Icon(Icons
                                                                      .keyboard_arrow_down)
                                                                  : GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          selectedIndex =
                                                                              -1;
                                                                          isClick =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .keyboard_arrow_up)),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                              selectedIndex == index
                                                  ? Container(
                                                      // height: 220,
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            if (widget.user![
                                                                    "schemeType"] ==
                                                                "Swarna Samridhi")
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Gram Price",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'latto',
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    transactionList[index]
                                                                            [
                                                                            'gramPriceInvestDay']
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'latto',
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            if (widget.user![
                                                                    "schemeType"] ==
                                                                "Swarna Samridhi")
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Gram Weight",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'latto',
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    transactionList[index]
                                                                            [
                                                                            'gramWeight']
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'latto',
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            Container(
                                                              height: 1,
                                                              color: Colors
                                                                  .black12,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Paid Amount",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'latto',
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  " ₹ ${transactionList[index]['amount'].toString()}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          "latto",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black87),
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => UpdateTransaction(
                                                                                user: widget.user!,
                                                                                dbUser: widget.dbUser!,
                                                                                db: db!,
                                                                                transaction: transactionList[index],
                                                                                staffType: staffType)));
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              SizedBox(
                                                height: 5,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          )
                        : Text("No Data Available...."),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void printSelectedTransactions() {
    List selectedTransactionData = getSelectedTransactions();
    averageGramRate = calculateAverageGramRate(selectedTransactionData);
  }

  double calculateAverageGramRate(List selectedTransactions) {
    if (selectedTransactions.isEmpty) return 0.0;

    double totalGramPrice = selectedTransactions
        .map((transaction) => transaction['gramPriceInvestDay'] as double)
        .reduce((a, b) => a + b);

    return totalGramPrice / selectedTransactions.length;
  }

  List getSelectedTransactions() {
    return transactionList
        .asMap() // Convert to a map with index as the key
        .entries
        .where((entry) => selectedTransactions
            .contains(entry.key)) // Filter by selected indices
        .map((entry) => entry.value) // Extract transaction data
        .toList();
  }

  void _showCloseCustomerDialog(BuildContext context) {
    DateTime? selectedDate = DateTime.now(); // Initial selected date

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Close Customer'),
              content: Container(
                height: MediaQuery.of(context).size.height * .25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Are you sure you want to close this customer?'),
                    SizedBox(height: 10),
                    Text("Customer Name: ${widget.user!['name']}"),
                    Text("Customer Balance: ${data[0]["balance"]}"),
                    SizedBox(height: 10),
                    // Select Date button and display selected date
                    TextButton(
                      onPressed: () async {
                        // DateTime? pickedDate = await showDatePicker(
                        //   context: context,
                        //   initialDate: DateTime.now(),
                        //   firstDate: DateTime(2000),
                        //   lastDate: DateTime(2101),
                        // );
                        // if (pickedDate != null) {
                        //   setState(() {
                        //     selectedDate = pickedDate;
                        //   });
                        // }
                      },
                      child: Text(
                        selectedDate == null
                            ? 'Select Closing Date'
                            : 'Closing Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () {
                    Provider.of<User>(context, listen: false).upldateCloseUser(
                        widget.user!['id'],
                        data[0]["balance"],
                        data[0]["total_gram"],
                        selectedDate!); // Pass the selected date instead of DateTime.now()
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomeScreen()),
                        (Route<dynamic> route) => false);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
