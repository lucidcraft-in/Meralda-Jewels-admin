import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../constant/colors.dart';
import '../../providers/staff.dart';
import './customer_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user.dart';
import 'package:intl/intl.dart';

class CreateCustomerScreen extends StatefulWidget {
  static const routeName = '/create-customer';
  const CreateCustomerScreen({Key? key}) : super(key: key);

  @override
  _CreateCustomerScreenState createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  var staffDetails;
  int selectedBranch = 0;
  User? db;
  List userList = [];
  TextEditingController custIdCntrl = TextEditingController();

  List branches = [
    {"id": 0, "name": "Thrissur Golden Alathur"},
    {"id": 1, "name": "Thrissur Golden Chittur"},
    {"id": 2, "name": "Thrissur Golden Pattambi "},
    {"id": 3, "name": "Thrissur Golden Vadakkencherri "},
  ];
  DateTime? selectedDate;
  DateTime now = DateTime.now();
  String custid = "";
  List counter = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Provider.of<SchemeSrevice>(context, listen: false).fetchSchemes();

    setData();
  }

  setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      staffDetails = jsonDecode(prefs.getString('staff')!);
    });
    // print("++++++++++++++++++++++++++");
    // print(staffDetails);
    _selectStaff = staffDetails["id"];
    _selectStaffName = staffDetails["staffName"];

    _user = UserModel(
      id: _user.id,
      name: _user.name,
      custId: _user.custId,
      phoneNo: _user.phoneNo,
      address: _user.address,
      place: _user.place,
      mailId: _user.mailId,
      staffId: staffDetails['id'],
      schemeType: selectedValue,
      balance: _user.balance,
      token: _user.token,
      totalGram: _user.totalGram,
      branch: staffDetails['branch'],
      dateofBirth: _user.dateofBirth,
      nominee: _user.nominee,
      nomineePhone: _user.nomineePhone,
      nomineeRelation: _user.nomineeRelation,
      adharCard: _user.adharCard,
      panCard: _user.panCard,
      pinCode: _user.pinCode,
      staffName: staffDetails['staffName'],
      amc: _user.amc,
      tax: _user.tax,
    );

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('cust_Id_Config').get();

    for (var doc in querySnapshot.docs.toList()) {
      Map a = {
        "id": doc.id,
        "altr_config": doc["altr_config"],
        "altr_config2": doc["altr_config2"],
        "altr_config3": doc["altr_config3"]
      };
      counter.add(a);
    }

    getStaff();
  }

  getStaff() async {
    // Provider.of<User>(context, listen: false).read(0).then((value) {
    //   print("==================");
    //   print(value);
    //   setState(() {
    //     staffList = value;
    //     _selectStaff = staffList[0]["id"];
    //   });
    // });
    Provider.of<Staff>(context, listen: false).read().then((value) {
      // print("==================");
      // print(value);
      setState(() {
        staffList = value!;
      });
    });
  }

  _selectDate() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1800),
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

  final _formKey = GlobalKey<FormState>();
  String selectedValue = 'Monthly';
  var _isLoading = false;
  var _user = UserModel(
    id: '',
    name: '',
    custId: '',
    phoneNo: '',
    address: '',
    place: '',
    mailId: '',
    staffId: '',
    schemeType: '',
    balance: 0,
    token: '',
    totalGram: 0,
    branch: 0,
    dateofBirth: DateTime.now(),
    nominee: "",
    nomineePhone: "",
    nomineeRelation: "",
    adharCard: "",
    panCard: "",
    pinCode: "",
    staffName: '',
    tax: 0,
    amc: 0,
  );

  Future<void> _saveForm() async {
    if (isClick) return; // Prevent multiple calls

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => isClick = false);

      // Show snackbar if form is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields correctly!'),
          backgroundColor: useColor.homeIconColor, // Red color for error
        ),
      );

      return;
    }

    if (selectSchemeType != null && selectOdType != null) {
      setState(() {
        isClick = true;
        _isLoading = true;
      });

      try {
        _user = UserModel(
          name: _user.name,
          custId: custIdCntrl.text,
          phoneNo: _user.phoneNo,
          address: _user.address,
          place: _user.place,
          mailId: _user.mailId,
          staffId: _user.staffId,
          schemeType: _user.schemeType,
          balance: _user.balance,
          id: _user.id,
          token: _user.token,
          totalGram: _user.totalGram,
          branch: _user.branch,
          dateofBirth: selectedDate ?? DateTime(now.year, now.month, now.day),
          nominee: _user.nominee,
          nomineePhone: _user.nomineePhone,
          nomineeRelation: _user.nomineeRelation,
          adharCard: _user.adharCard,
          panCard: _user.panCard,
          pinCode: _user.panCard,
          staffName: _user.staffName,
          amc: _user.amc,
          tax: _user.tax,
        );

        _formKey.currentState!.save();

        CollectionReference collectionReference =
            FirebaseFirestore.instance.collection("cust_Id_Config");

        bool? isCreated = await Provider.of<User>(context, listen: false)
            .create(_user, custIdCntrl.text, selectSchemeType!, _selectStaff,
                _selectStaffName, selectOdType!);

        if (!isCreated!) {
          // Update Firestore Counter
          String counterKey = selectSchemeType == "Ponkoot"
              ? "altr_config"
              : selectSchemeType == "Swarna Samridhi"
                  ? "altr_config3"
                  : "altr_config2";
          await collectionReference
              .doc(counter[0]["id"])
              .update({counterKey: FieldValue.increment(1)});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved successfully!')),
          );

          Navigator.pushReplacementNamed(context, CustomerScreen.routeName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Customer ID already exists!')),
          );
        }
      } catch (err) {
        print(err);
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong. $err'),
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
      } finally {
        setState(() {
          _isLoading = false;
          isClick = false;
        });
      }
    } else {
      setState(() => isClick = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select User Type and Scheme...')),
      );
    }
  }

  String _selectStaff = "";
  String _selectStaffName = "";
  List staffList = [];
  String? selectSchemeType;
  final List<String> schemeTypeList = [
    "Ponkoot",
    "Swarna Nidhi",
    "Swarna Samridhi"
  ];

  String? selectOdType;
  final List<String> orderAdvList = ["Gold", "Cash"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: Text('Create Customer'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: staffDetails != null
              ? Container(
                  child: new SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if (staffDetails["type"] == 1)
                            SizedBox(
                              height: 12,
                            ),
                          if (staffDetails["type"] == 1)
                            DropdownButtonFormField<String>(
                              value: _selectStaff,
                              hint: Text('Select Staff'),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectStaff = newValue!;
                                  _selectStaffName = staffList.firstWhere(
                                    (staff) => staff["id"] == newValue,
                                    orElse: () => {
                                      "staffName": ""
                                    }, // Provide a default value in case no match is found
                                  )["staffName"];
                                });
                                // print('Selected Staff ID: $_selectStaff');
                                // print('Selected Staff Name: $_selectStaffName');
                              },
                              items: staffList
                                  .map<DropdownMenuItem<String>>((staff) {
                                return DropdownMenuItem<String>(
                                  value: staff["id"],
                                  child: Text(staff["staffName"]),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: 'Select Staff',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          SizedBox(
                            height: 12,
                          ),
                          DropdownButtonFormField<String>(
                            value: selectSchemeType,
                            hint: Text('Select Scheme Type'),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectSchemeType = newValue;
                              });

                              createCustId(selectSchemeType == "Ponkoot"
                                  ? "PON"
                                  : selectSchemeType == "Swarna Samridhi"
                                      ? "SS"
                                      : "SN");
                            },
                            items: schemeTypeList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Scheme Type',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Cutomer name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _user = UserModel(
                                name: value!,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Enter Cutomer name',
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            controller: custIdCntrl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Cutomer id';
                              }
                              return null;
                            },
                            // onChanged: (value) => setState(() {
                            //   custid = value;
                            // }),
                            // onSaved: (value) {
                            // _user = UserModel(
                            //     name: _user.name,
                            //     custId: value!,
                            //     phoneNo: _user.phoneNo,
                            //     address: _user.address,
                            //     place: _user.place,
                            //     staffId: _user.staffId,
                            //     schemeType: _user.schemeType,
                            //     balance: _user.balance,
                            //     id: _user.id,
                            //     token: _user.token,
                            //     totalGram: _user.totalGram,
                            //     branch: _user.branch,
                            //     dateofBirth: _user.dateofBirth,
                            //     nominee: _user.nominee,
                            //     nomineePhone: _user.nomineePhone,
                            //     nomineeRelation: _user.nomineeRelation,
                            //     adharCard: _user.adharCard,
                            //     panCard: _user.panCard,
                            //     pinCode: _user.pinCode,
                            //     staffName: _user.staffName);
                            // },
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
                              labelText: 'Enter Customer Id',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField<String>(
                            value: selectOdType,
                            hint: Text('Select Order Advance'),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectOdType = newValue;
                              });
                            },
                            items: orderAdvList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Order Advance Type',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Phone ';
                              } else if (value.length != 10) {
                                return 'Please enter valid Phone number ';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: value!,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Phone number',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            maxLines: 4,
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: value!,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Address',
                            ),
                          ),
                          if (selectSchemeType == "Swarna Samridhi")
                            SizedBox(
                              height: 10,
                            ),
                          if (selectSchemeType == "Swarna Samridhi")
                            TextFormField(
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                _user = UserModel(
                                    name: _user.name,
                                    custId: custid,
                                    phoneNo: _user.phoneNo,
                                    address: _user.address,
                                    place: _user.place,
                                    mailId: _user.mailId,
                                    staffId: _user.staffId,
                                    schemeType: _user.schemeType,
                                    balance: _user.balance,
                                    id: _user.id,
                                    token: _user.token,
                                    totalGram: _user.totalGram,
                                    branch: _user.branch,
                                    dateofBirth: _user.dateofBirth,
                                    nominee: _user.nominee,
                                    nomineePhone: _user.nomineePhone,
                                    nomineeRelation: _user.nomineeRelation,
                                    adharCard: _user.adharCard,
                                    panCard: _user.panCard,
                                    pinCode: _user.pinCode,
                                    staffName: _user.staffName,
                                    amc: _user.amc,
                                    tax: double.tryParse(value ?? '0') ?? 0);
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
                                labelText: 'Tax %',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Tax';
                                }
                                return null;
                              },
                            ),
                          if (selectSchemeType == "Swarna Samridhi")
                            SizedBox(
                              height: 10,
                            ),
                          if (selectSchemeType == "Swarna Samridhi")
                            TextFormField(
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                _user = UserModel(
                                    name: _user.name,
                                    custId: custid,
                                    phoneNo: _user.phoneNo,
                                    address: _user.address,
                                    place: _user.place,
                                    mailId: _user.mailId,
                                    staffId: _user.staffId,
                                    schemeType: _user.schemeType,
                                    balance: _user.balance,
                                    id: _user.id,
                                    token: _user.token,
                                    totalGram: _user.totalGram,
                                    branch: _user.branch,
                                    dateofBirth: _user.dateofBirth,
                                    nominee: _user.nominee,
                                    nomineePhone: _user.nomineePhone,
                                    nomineeRelation: _user.nomineeRelation,
                                    adharCard: _user.adharCard,
                                    panCard: _user.panCard,
                                    pinCode: _user.pinCode,
                                    staffName: _user.staffName,
                                    amc: double.tryParse(value ?? '0') ?? 0,
                                    tax: _user.tax);
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
                                labelText: 'V/A %',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter V/A';
                                }
                                return null;
                              },
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: value,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Mail Id',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: value!,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Place',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "select date of birth",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              _selectDate();
                            },
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .074,
                              decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black)),
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 19,
                                  ),
                                  Text(selectedDate == null
                                      ? DateFormat(' MMM dd yyyy').format(now)
                                      : DateFormat(' MMM dd yyyy')
                                          .format(selectedDate!)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: value!,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Nominee',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: value!,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Nominee phone',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: value,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Nominee Relation',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: value!,
                                panCard: _user.panCard,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Adhar Card',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: value,
                                pinCode: _user.pinCode,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Pan Card',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              _user = UserModel(
                                name: _user.name,
                                custId: custid,
                                phoneNo: _user.phoneNo,
                                address: _user.address,
                                place: _user.place,
                                mailId: _user.mailId,
                                staffId: _user.staffId,
                                schemeType: _user.schemeType,
                                balance: _user.balance,
                                id: _user.id,
                                token: _user.token,
                                totalGram: _user.totalGram,
                                branch: _user.branch,
                                dateofBirth: _user.dateofBirth,
                                nominee: _user.nominee,
                                nomineePhone: _user.nomineePhone,
                                nomineeRelation: _user.nomineeRelation,
                                adharCard: _user.adharCard,
                                panCard: _user.panCard,
                                pinCode: value,
                                staffName: _user.staffName,
                                amc: _user.amc,
                                tax: _user.tax,
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
                              labelText: 'Pin Code',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            height: MediaQuery.of(context).size.height * .06,
                            decoration: BoxDecoration(
                                color: useColor.homeIconColor,
                                borderRadius: BorderRadius.circular(20)),
                            child:
                                //  TextButton(
                                //   onPressed: isClick ? null : handleSubmit,
                                //   child: isClick
                                //       ? CircularProgressIndicator(
                                //           color: Colors.white,
                                //         )
                                //       : Text(
                                //           "Submit",
                                //           style: TextStyle(color: Colors.white),
                                //         ),
                                // )

                                TextButton(
                              onPressed: isClick
                                  ? null
                                  : _saveForm, // Disable if already clicked
                              child: isClick
                                  ? Text('Saving...',
                                      style: TextStyle(color: Colors.white))
                                  : Text('Save',
                                      style: TextStyle(color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
        ));
  }

  bool isClick = false;

  void handleSubmit() {
    if (isClick) return; // Prevent multiple submissions
    setState(() => isClick = true);

    // Simulate API call or form processing
    Future.delayed(Duration(seconds: 2), () {
      setState(() => isClick = false);
      // Proceed with form submission
    });
  }

  createCustId(String scheme) {
    print(scheme);
    db = User();
    db!.initiliase();
    db!.readbyBranchId(staffDetails['branch']).then((value) {
      setState(() {
        userList = value!;
      });

      if (userList.length > 0) {
        if (scheme == "PON") {
          // print("-------- ex pon -------");
          setState(() {
            custid = "PON_${counter[0]["altr_config"]}";
            custIdCntrl.text = custid;
          });
        } else if (scheme == "SN") {
          // print("-------- ex sn -------");
          setState(() {
            custid = "SN_${counter[0]["altr_config2"]}";
            custIdCntrl.text = custid;
          });
        } else {
          setState(() {
            custid = "SS_${counter[0]["altr_config3"]}";
            custIdCntrl.text = custid;
          });
        }
      } else {
        if (scheme == "PON") {
          setState(() {
            custid = "PON_1";
            custIdCntrl.text = custid;
          });
        } else if (scheme == "SN") {
          setState(() {
            custid = "SN_1";
            custIdCntrl.text = custid;
          });
        } else {
          setState(() {
            custid = "SS_1";
            custIdCntrl.text = custid;
          });
        }
      }
    });
  }
}
