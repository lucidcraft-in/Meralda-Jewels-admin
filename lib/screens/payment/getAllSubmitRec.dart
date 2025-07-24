import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/paymentBill.dart';
import '../cmpPyment.dart';
import 'sendPaymentRecipt.dart';

class SubmittedRec extends StatefulWidget {
  SubmittedRec({super.key});

  @override
  State<SubmittedRec> createState() => _SubmittedRecState();
}

class _SubmittedRecState extends State<SubmittedRec> {
  bool isSelectRequest = true;
  bool isSelectApproved = false;
  bool isSelectDeclined = false; // New checkbox for Declined
  var branchId;
  var staffType;
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    // print("---------------");
    // print(Staff);
    setState(() {
      branchId = Staff['branch'];
      staffType = Staff['type'];
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
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text('Submitted Screenshot'),
          backgroundColor: useColor.homeIconColor
          // actions: [
          //   IconButton(
          //       onPressed: () {
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => ExcelUploadScreen()));
          //       },
          //       icon: Icon(
          //         Icons.add,
          //         color: Colors.white,
          //       ))
          // ],
          ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CmpPayment()));
              },
              // child: Ink(
              //   width: 200,
              //   height: 200,
              //   color: Colors.blue,
              // ),
              child: Ink(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 244, 231, 214),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Update Payment Details",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: isSelectRequest,
                onChanged: (value) {
                  setState(() {
                    isSelectRequest = value!;
                  });
                },
              ),
              Text("Request"),
              Checkbox(
                value: isSelectApproved,
                onChanged: (value) {
                  setState(() {
                    isSelectApproved = value!;
                  });
                },
              ),
              Text("Approved"),
              Checkbox(
                value: isSelectDeclined, // Decline checkbox
                onChanged: (value) {
                  setState(() {
                    isSelectDeclined = value!;
                  });
                },
              ),
              Text("Declined"), // Label for the Declined checkbox
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Provider.of<PaymentBillProvider>(context, listen: false)
                  .getAllData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data found'));
                } else {
                  var documents = snapshot.data!.docs;

                  // // Filter documents based on the selected checkboxes
                  // documents = documents.where((doc) {
                  //   var data = doc.data() as Map<String, dynamic>;
                  //   if (isSelectRequest && isSelectApproved) {
                  //     print(data['status']);
                  //     return data['status'] == 'Request' ||
                  //         data['status'] == 'approve';
                  //   } else if (isSelectRequest) {
                  //     return data['status'] == 'Request';
                  //   } else if (isSelectApproved) {
                  //     return data['status'] == 'approve';
                  //   }
                  //   return true; // If neither checkbox is selected, show all
                  // }).toList();
                  documents = documents.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    if (isSelectRequest &&
                        isSelectApproved &&
                        isSelectDeclined) {
                      return data['status'] == 'Request' ||
                          data['status'] == 'approve' ||
                          data['status'] == 'Decline';
                    } else if (isSelectRequest && isSelectApproved) {
                      return data['status'] == 'Request' ||
                          data['status'] == 'approve';
                    } else if (isSelectRequest && isSelectDeclined) {
                      return data['status'] == 'Request' ||
                          data['status'] == 'Decline';
                    } else if (isSelectApproved && isSelectDeclined) {
                      return data['status'] == 'approve' ||
                          data['status'] == 'Decline';
                    } else if (isSelectRequest) {
                      return data['status'] == 'Request';
                    } else if (isSelectApproved) {
                      return data['status'] == 'approve';
                    } else if (isSelectDeclined) {
                      return data['status'] == 'Decline';
                    }
                    return true; // If no checkbox is selected, show all
                  }).toList();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: documents.length > 0
                        ? ListView.separated(
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              var data = documents[index].data()
                                  as Map<String, dynamic>;
                              var document = documents[index];

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SendPaymentRec(
                                              documentId: document.id)));
                                },
                                tileColor: Color.fromARGB(255, 244, 231, 214),
                                title: Text(data['amount'].toString() ?? '0'),
                                subtitle:
                                    Text(data['note'] ?? 'No Description'),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: data['status'] ==
                                              "Request"
                                          ? Color.fromARGB(77, 244, 67, 54)
                                          : data['status'] == "approve"
                                              ? Color.fromARGB(66, 76, 175, 79)
                                              : Color.fromARGB(77, 255, 165,
                                                  0), // Orange for Declined
                                      child: CircleAvatar(
                                        radius: 5,
                                        backgroundColor: data['status'] ==
                                                "Request"
                                            ? Color.fromARGB(255, 199, 48, 37)
                                            : data['status'] == "approve"
                                                ? Colors.green
                                                : Colors
                                                    .orange, // Orange for Declined
                                      ),
                                    ),
                                    Text(data['status'] == "Request"
                                        ? "Pending"
                                        : data['status'] == "approve"
                                            ? "Approved"
                                            : "Declined"), // Display Declined
                                  ],
                                ),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            child: Center(child: Text("No Data Found....")),
                          ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
