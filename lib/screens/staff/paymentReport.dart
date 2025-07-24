import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constant/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/transaction.dart';

class PaymentReport extends StatefulWidget {
  PaymentReport({super.key, this.staffid});
  String? staffid;

  @override
  State<PaymentReport> createState() => _PaymentReportState();
}

class _PaymentReportState extends State<PaymentReport> {
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? staff;
  List<dynamic> transaction = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? staffString = prefs.getString('staff');
      if (staffString != null) {
        staff = jsonDecode(staffString);
        await getTransList(selectedDate);
      } else {
        // Handle missing staff data
        // print("No staff data found");
      }
    } catch (e) {
      // Handle errors (e.g., parsing errors, etc.)
      // print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic>? transactions;
  Future<void> getTransList(DateTime date) async {
    try {
      transactions =
          await Provider.of<TransactionProvider>(context, listen: false)
              .readByStaff(date, widget.staffid!);
      setState(() {
        transaction = transactions!;
      });
      // if (widget.staffid == null) {
      //   print("---o");
      //   List<dynamic> transactions =
      //       await Provider.of<TransactionProvider>(context, listen: false)
      //           .readByStaff(date, staff?["id"] ?? "");
      //   setState(() {
      //     transaction = transactions;
      //   });
      // } else {
      //   transactions =
      //       await Provider.of<TransactionProvider>(context, listen: false)
      //           .readByStaff(date, widget.staffid!);
      //   setState(() {
      //     transaction = transactions!;
      //   });
      // }
    } catch (e) {
      // Handle errors (e.g., network errors)
      // print("Error fetching transactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
          title: Text("Collection Report"),
          backgroundColor: useColor.homeIconColor),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Select Day",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 10),
                        Text(
                          DateFormat('dd-MM-yyyy').format(
                              selectedDate), // Display the selected date here
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null &&
                                pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                                isLoading = true;
                              });

                              await getTransList(selectedDate);
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          icon: Icon(Icons.calendar_month),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Text(
                    "Total Collection : ${calculateTotalAmount().toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  transactions != null
                      ? Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: transaction.length,
                            itemBuilder: (context, index) {
                              final trans = transactions![index];
                              final timestamp =
                                  trans["timestamp"] as Timestamp?;
                              final dateTime = timestamp?.toDate();

                              return Card(
                                child: ListTile(
                                  tileColor: Colors.white,
                                  title: Text(trans["customerName"]),
                                  subtitle: Text(dateTime != null
                                      ?
                                      // DateFormat('EEE, M/d/y')
                                      //     .format(dateTime)
                                      DateFormat('hh:mm a').format(dateTime)
                                      : 'No Timestamp'),
                                  trailing: Text(trans["amount"].toString()),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          height: 100,
                          child: Center(
                              child:
                                  Text("No Payment Report for this Date...."))),
                ],
              ),
            ),
    );
  }

  double calculateTotalAmount() {
    // Assuming each transaction has an 'amount' field which is a double
    return transaction.fold(0, (sum, item) => sum + (item['amount'] ?? 0.0));
  }
}
