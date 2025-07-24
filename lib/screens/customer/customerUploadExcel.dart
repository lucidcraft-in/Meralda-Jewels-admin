import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/user.dart';

class ExcelUploadCustomer extends StatefulWidget {
  @override
  _ExcelUploadCustomerState createState() => _ExcelUploadCustomerState();
}

class _ExcelUploadCustomerState extends State<ExcelUploadCustomer> {
  bool _isLoading = false;
  String _statusMessage = 'Upload Excel File to Firebase';
  String fileName = "";

  Future<void> _pickFile() async {
    setState(() {
      totalList = [];
      pendingList = [];
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      // setState(() {
      //   _isLoading = true;
      //   _statusMessage = 'Uploading Customer Data...';
      // });

      setState(() {
        fileData = result;
        fileName = result.files.single.name;
        isFileExist = true;
      });

      await uploadCustomerData(result);

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _statusMessage = 'No file selected.';
      });
    }
  }

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('user');
  // Function to pick and extract data from the Excel file
  Future<void> uploadCustomerData(var result) async {
    File file = File(result.files.single.path!);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]!.rows;

      // Assuming the first row is a header
      for (int i = 1; i < rows.length; i++) {
        var row = rows[i];

        // Ensure there are enough columns for customer details
        if (row.length < 4) continue;

        // Extract customer data from the Excel sheet
        String srNoString = row[0]?.value.toString() ?? '';
        int srNo = double.parse(srNoString).toInt();
        String customerId = row[1]?.value.toString() ?? ''; // Customer ID
        String name = row[2]?.value.toString() ?? ''; // Customer Name
        String address = row[3]?.value.toString() ?? ''; // Customer Address
        String phone = row[6]?.value.toString() ?? ''; // Customer Phone
        String balance = row[8]?.value.toString() ?? '';
        String agent_id = row[9]?.value.toString() ?? '';
        String agent_code = row[10]?.value.toString() ?? '';

        DateTime? formattedStartDate;
        if (row[11]?.value != null) {
          try {
            String? rawDateValue = row[11]?.value.toString();
            DateTime parsedDate = DateTime.parse(rawDateValue!);
            formattedStartDate = parsedDate;
          } catch (e) {}
        }

        String cust_type = row[12]?.value.toString() ?? '';
        if (customerId.endsWith('.0')) {
          setState(() {
            customerId = customerId.substring(0, customerId.length - 2);
          });
        }
        if (srNo == null ||
            customerId.isEmpty ||
            name.isEmpty ||
            address.isEmpty ||
            phone.isEmpty ||
            balance.isEmpty ||
            agent_id.isEmpty ||
            agent_code.isEmpty) {
          pendingList.add({
            'srNo': srNo,
            'customerId': customerId,
            'name': name,
            'address': address,
            'phone': phone,
            'balance': balance,
            'agentId': agent_id,
            'agentCode': agent_code,
            'startDate': formattedStartDate,
            'customerType': cust_type
          });
        } else {
          var data1 = Customer(
              srNo: srNo,
              customerId: customerId,
              name: name,
              address: address,
              phone: phone,
              balance: balance,
              agentId: agent_id,
              agentCode: agent_code,
              startDate: formattedStartDate,
              customerType: cust_type);

          QuerySnapshot userSnapshot = await usersCollection
              .where('custId', isEqualTo: customerId)
              .get();

          if (userSnapshot.docs.isEmpty) {
            // Provider.of<User>(context, listen: false)
            //     .createUserFromExcel(data1)
            //     .then((val) {
            //   print(val);
            // });
            totalList.add(data1.toMap());
          } else {
            pendingList.add(data1.toMap());
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
      _statusMessage = 'Customer Data Uploaded Successfully!';
    });
  }

  bool isError = false;

  List<Map<String, dynamic>> totalList = [];
  List<Map<String, dynamic>> pendingList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Excel Upload '),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomSheet: Container(
        height: 120,
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            fileName != ""
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                            color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              fileData = null;
                              fileName = "";
                              isFileExist = false;
                              totalList = [];
                              pendingList = [];
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ))
                    ],
                  )
                : Container(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text(
                "Select Excel File",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .5,
                height: MediaQuery.of(context).size.height * .05,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    isFileExist != true
                        ? _pickFile()
                        : uploadDataToFirestore(totalList);
                  },
                  child: isFileExist != true
                      ? Text(
                          "Pick File",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color.fromARGB(255, 106, 16, 16),
                          ),
                        )
                      : _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                              "Upload Selected file",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color.fromARGB(255, 106, 16, 16),
                              ),
                            ),
                ),
              )
            ]),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Pending List",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              pendingList.length > 0
                  ? ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 3),
                      shrinkWrap: true,
                      itemCount: pendingList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: Color.fromARGB(37, 128, 23, 23),
                          leading: Text(
                              pendingList[index]["srNo"].toStringAsFixed(0)),
                          title: Text(pendingList[index]["name"]),
                          subtitle: Text(pendingList[index]["custId"]),
                          // trailing:
                          //     Text(pendingList[index]["amount"].toString()),
                        );
                      })
                  : Container(
                      height: 100,
                      child: Center(child: Text("No Data Found...."))),
              SizedBox(height: 15),
              Text(
                "Total Customer List",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              totalList.length > 0
                  ? ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 3),
                      shrinkWrap: true,
                      itemCount: totalList.length,
                      itemBuilder: (context, index) {
                        // print(totalList[index]);
                        return ListTile(
                          tileColor: Color.fromARGB(37, 128, 23, 23),
                          leading:
                              Text(totalList[index]["srNo"].toStringAsFixed(0)),
                          title: Text(totalList[index]["name"]),
                          subtitle: Text(totalList[index]["custId"]),
                          // trailing: Text(totalList[index]["amount"].toString()),
                        );
                      })
                  : Container(
                      height: 100,
                      child: Center(child: Text("No Data Found...."))),
            ],
          ),
        ),
      ),
    );
  }

  bool isFileExist = false;
  var fileData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  var staffData;
  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      staffData = jsonDecode(prefs.getString('staff')!);
    });
  }

  Future<void> uploadDataToFirestore(List result) async {
    setState(() {
      _isLoading = true;
    });
    if (result.length > 0) {
      for (int i = 0; i < result.length; i++) {
        Customer customer = Customer.fromMap(result[i]);
        Provider.of<User>(context, listen: false)
            .createUserFromExcel(customer)
            .then((val) {
          print(val);
          setState(() {
            isFileExist = false;
            _isLoading = false;
            fileData = null;
            fileName = "";
            isFileExist = false;
            totalList = [];
            _statusMessage = 'Excel Data Uploaded Successfully!';
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(_statusMessage)));

          // setState(() {
          //   totalList = [];
          //   pendingList = [];
          // });
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Data Found")));
      setState(() {
        _isLoading = false;
      });
    }
  }
}
