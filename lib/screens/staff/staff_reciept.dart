import 'dart:convert';
import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import '../../providers/staff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/collections.dart';
import '../../providers/transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StaffReciept extends StatefulWidget {
  const StaffReciept({super.key});

  @override
  State<StaffReciept> createState() => _StaffRecieptState();
}

class _StaffRecieptState extends State<StaffReciept> {
  final _formKey = GlobalKey<FormState>();
  String? selectedStaff;
  Staff? db;
  List staffs = [];
  var staffDb = Staff();
  var StaffData;
  int? branchId;
  DateTime? selectedDate;
  DateTime now = DateTime.now();
  String staffName = "";

  var _collection = CollectionModel(
    staffId: '',
    staffname: '',
    recievedAmount: 0,
    paidAmount: 0,
    balance: 0,
    date: DateTime.now(),
    type: 1,
    branch: 0,
  );
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var staff = jsonDecode(prefs.getString('staff')!);

    setState(() {
      branchId = staff['branch'];
    });
    db = Staff();
    db!.initiliase();
    await db!.read().then((value) => {
          setState(() {
            staffs = value!;
          }),
        });

    // setState(() {
    //   initialise();
    // });
  }

  getSingleStaff(String id) {
    var data;
    staffDb.initiliase();
    staffDb.getStaffById(id).then((value) {
      setState(() {
        data = value;
        staffName = data[0]["staffName"];
        // print(data);
      });
      getbalancefromclcn(data[0]["id"]);
    });
  }

  double balance = 0;
  getbalancefromclcn(String staffId) {
    Collection? dbCollection;
    dbCollection = Collection();
    dbCollection.initiliase();
    dbCollection.getStaffBalance(staffId).then((val) {
      print(val);
      if (val != null) {
        setState(() {
          balance = val;
        });
      } else {}
    });
  }

  @override
  void initState() {
    loginData();

    // TODO: implement initState
    super.initState();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        isClick = false;
      });
      return;
    }
    _formKey.currentState!.save();

    try {
      _collection = CollectionModel(
          staffId: _collection.staffId,
          staffname: staffName,
          recievedAmount: 0,
          paidAmount: _collection.paidAmount,
          balance: _collection.balance,
          date: selectedDate == null
              ? DateTime(now.year, now.month, now.day)
              : selectedDate!,
          type: 1,
          branch: branchId!
          // type 0 is recive amount
          );
      Provider.of<Collection>(context, listen: false)
          .create(_collection, "")
          .then((value) {
        final snackBar = SnackBar(content: const Text("Add Successfully...."));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (context) => StaffListScreen()));
        Navigator.pop(context);
        setState(() {
          isClick = false;
        });
      });
    } catch (err) {
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
      setState(() {
        isClick = false;
      });
    }
  }

  bool isClick = false;
  _selectDate() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then(
      (pickedDate) {
        if (pickedDate == null) {
          return;
        }
        setState(() {
          now = pickedDate;
          selectedDate = new DateTime(now.year, now.month, now.day);
        });
      },
    );
  }

  bool isLoad = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Collection Reciept"),
        backgroundColor: useColor.homeIconColor,
        // actions: [
        //   Padding(
        //       padding: EdgeInsets.only(right: 20.0, top: 8, bottom: 8),
        //       child: OutlinedButton(
        //           onPressed: () {
        //             Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                     builder: (context) => StaffCollectionReport()));
        //           },
        //           style:
        //               OutlinedButton.styleFrom(backgroundColor: Colors.black38),
        //           child: Text(
        //             "Report",
        //             style: TextStyle(color: Colors.white),
        //           ))),
        // ],
      ),
      body: staffs!.length > 0
          ? Padding(
              padding: EdgeInsets.all(2),
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: new SingleChildScrollView(
                    child: Form(
                        key: _formKey,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * .4,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .074,
                                        decoration: BoxDecoration(
                                            // color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all()),
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, top: 7),
                                        child: DropdownButton(
                                            underline: SizedBox(),
                                            style: TextStyle(
                                                // fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Colors.black),
                                            isExpanded: true,
                                            hint: Text(
                                              "Select Staff",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      115, 0, 0, 0)),
                                            ),
                                            value: selectedStaff,
                                            items: staffs!.map((val) {
                                              return DropdownMenuItem(
                                                  value: val["id"],
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        Text(val["staffName"]),
                                                  ));
                                            }).toList(),
                                            onChanged: (value) {
                                              // print(value);
                                              setState(() {
                                                selectedStaff = value as String;
                                                balance = 0;
                                              });
                                              getSingleStaff(selectedStaff!);
                                              _collection = CollectionModel(
                                                  staffId: selectedStaff!,
                                                  staffname: staffName,
                                                  recievedAmount: 0,
                                                  paidAmount:
                                                      _collection.paidAmount,
                                                  balance: _collection.balance,
                                                  date: _collection.date,
                                                  type: 0,
                                                  branch: branchId!
                                                  // type 0 is recive amount
                                                  );
                                            }),
                                      ),
                                      Text(
                                        "Balance : ${balance.toString()}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter Recive Amount';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _collection = CollectionModel(
                                              staffId: _collection.staffId,
                                              staffname: staffName,
                                              recievedAmount: 0,
                                              paidAmount: value != ""
                                                  ? double.parse(value!)
                                                  : double.parse(
                                                      0.0.toString()),
                                              balance: _collection.balance,
                                              date: _collection.date,
                                              type: 1,
                                              branch: branchId!
                                              // type 0 is recive amount
                                              );
                                        },
                                        decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                          ),
                                          labelText:
                                              'Enter Amount Recieve from Staff',
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          _selectDate();
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .074,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 226, 226, 226))),
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, top: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 19,
                                              ),
                                              Text(selectedDate == null
                                                  ? DateFormat(' MMM dd yyyy')
                                                      .format(now)
                                                  : DateFormat(' MMM dd yyyy')
                                                      .format(selectedDate!)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .06,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: useColor.homeIconColor),
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                isClick = true;
                                              });
                                              if (isClick == true) {
                                                _saveForm();
                                              }
                                            },
                                            child: isClick == false
                                                ? Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Text(
                                                    "Save.....",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          ),
                                        ),
                                      )
                                    ])))),
                  )),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
