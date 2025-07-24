import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/colors.dart';
import '../../providers/staff.dart';
import '../../providers/transaction.dart';
import '../../providers/user.dart';
import 'package:intl/intl.dart';

class UpdateCustomerScreen extends StatefulWidget {
  static const routeName = '/update-customer';
  UpdateCustomerScreen({Key? key, this.user, this.db}) : super(key: key);

  Map? user;
  User? db;
  @override
  _UpdateCustomerScreenState createState() => _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedValue = 'Monthly';
  bool changeCustIdIS = false;
  DateTime? selectedDate;
  DateTime now = DateTime.now();
  TextEditingController taxCntrl = TextEditingController();
  TextEditingController amcCntrl = TextEditingController();

  var _isLoading = false;
  var _user = UserModel(
      id: '',
      name: '',
      custId: '',
      phoneNo: '',
      address: '',
      place: '',
      mailId: '',
      schemeType: '',
      balance: 0,
      staffId: '',
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
      staffName: "",
      tax: 0,
      amc: 0);

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

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getTransaction(widget.user!['id']);
  }

  double? oldBalance;

  @override
  void initState() {
    super.initState();
    taxCntrl.text = widget.user!['tax'].toString();
    amcCntrl.text = widget.user!['amc'].toString();
    oldBalance = widget.user!['balance'];
    balanceCnttrl.text = widget.user!['balance'].toString();
    selectedValue = widget.user!['schemeType'];
    _selectStaff = widget.user!['staffId'];
    _selectStaffName = widget.user!['staffName'];
    print("===========");
    print(widget.user);
    getStaff();

    setState(() {
      selectedDate = widget.user!['dateofBirth'].toDate();
    });
    // print(selectedDate);
    _user = UserModel(
      name: _user.name,
      custId: _user.custId,
      phoneNo: _user.phoneNo,
      address: _user.address,
      place: _user.place,
      mailId: _user.mailId,
      schemeType: selectedValue,
      balance: _user.balance,
      id: _user.id,
      staffId: _user.staffId,
      token: _user.token,
      totalGram: _user.totalGram,
      branch: _user.branch,
      dateofBirth: selectedDate == null
          ? DateTime(now.year, now.month, now.day)
          : selectedDate!,
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
  }

  Future<void> _delete() async {
    try {
      try {
        Provider.of<User>(context, listen: false).delete(widget.user!['id']);
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Succes!'),
            content: Text('Deleted Successfully'),
            actions: <Widget>[
              OutlinedButton(
                child: Text('Okay'),
                onPressed: () {
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => CustomerScreen()));
                  setState(() {});
                },
              )
            ],
          ),
        );
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
      }
      setState(() {
        _isLoading = false;
      });
    } catch (err) {}
  }

  Future<void> _saveForm() async {
    // if (isLoad) return;
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        isLoad = false;
      });
      return;
    }
    _user = UserModel(
      name: _user.name,
      custId: _user.custId,
      phoneNo: _user.phoneNo,
      address: _user.address,
      place: _user.place,
      mailId: _user.mailId,
      schemeType: _user.schemeType,
      balance: _user.balance,
      id: _user.id,
      staffId: _user.staffId,
      token: _user.token,
      totalGram: _user.totalGram,
      branch: _user.branch,
      dateofBirth: selectedDate == null
          ? DateTime(now.year, now.month, now.day)
          : selectedDate!,
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
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      var result = await Provider.of<User>(context, listen: false).update(
          widget.user!['id'],
          _user,
          changeCustIdIS,
          balanceCnttrl.text,
          taxCntrl.text,
          amcCntrl.text,
          _selectStaff!,
          _selectStaffName!);

      if (result == false) {
        final snackBar = SnackBar(content: const Text('Saved successfully!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          _isLoading = false;
          Navigator.of(context).pop();
        });
      } else {
        setState(() {
          isLoad = false;
        });
        final snackBar = SnackBar(
          content: const Text('Customer id is exist!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (err) {
      setState(() {
        isLoad = false;
      });
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
  }

  TextEditingController balanceCnttrl = TextEditingController();
  List transaction = [];
  getTransaction(String staffId) {
    Provider.of<TransactionProvider>(context).read(staffId).then((val) {
      if (val![0] != null) {
        setState(() {
          transaction = val[0];
        });
      }
    });
  }

  List staffList = [];

  String? _selectStaff;
  String? _selectStaffName;

  getStaff() async {
    Provider.of<Staff>(context, listen: false).read().then((value) {
      setState(() {
        staffList = value!;
        print(staffList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: useColor.homeIconColor,
            elevation: 0,
            title: Text(
              "Update Customer",
              style:
                  TextStyle(fontFamily: 'latto', fontWeight: FontWeight.bold),
            )),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: new SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
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
                        items: staffList.map<DropdownMenuItem<String>>((staff) {
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
                      TextFormField(
                        initialValue: widget.user!['name'],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Cutomer name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _user = UserModel(
                            name: value!,
                            custId: _user.custId,
                            phoneNo: _user.phoneNo,
                            address: _user.address,
                            place: _user.place,
                            mailId: _user.mailId,
                            schemeType: _user.schemeType,
                            balance: _user.balance,
                            id: _user.id,
                            staffId: _user.staffId,
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
                        height: 14,
                      ),
                      TextFormField(
                        controller: balanceCnttrl,
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
                          labelText: 'Customer Blance',
                        ),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Phone ';
                          }
                          return null;
                        },
                        initialValue: widget.user!['phoneNo'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
                            phoneNo: value!,
                            address: _user.address,
                            place: _user.place,
                            mailId: _user.mailId,
                            schemeType: _user.schemeType,
                            balance: _user.balance,
                            id: _user.id,
                            staffId: _user.staffId,
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
                        height: 14,
                      ),
                      TextFormField(
                        maxLines: 4,
                        initialValue: widget.user!['address'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
                            phoneNo: _user.phoneNo,
                            address: value!,
                            place: _user.place,
                            mailId: _user.mailId,
                            schemeType: _user.schemeType,
                            balance: _user.balance,
                            id: _user.id,
                            staffId: _user.staffId,
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
                      SizedBox(
                        height: 14,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        // initialValue: widget.user!['tax'].toString(),
                        controller: taxCntrl,
                        // onSaved: (value) {
                        //   _user = UserModel(
                        //       name: _user.name,
                        //       custId: _user.custId,
                        //       phoneNo: _user.phoneNo,
                        //       address: _user.address,
                        //       place: _user.place,
                        //       mailId: _user.mailId,
                        //       staffId: _user.staffId,
                        //       schemeType: _user.schemeType,
                        //       balance: _user.balance,
                        //       id: _user.id,
                        //       token: _user.token,
                        //       totalGram: _user.totalGram,
                        //       branch: _user.branch,
                        //       dateofBirth: _user.dateofBirth,
                        //       nominee: _user.nominee,
                        //       nomineePhone: _user.nomineePhone,
                        //       nomineeRelation: _user.nomineeRelation,
                        //       adharCard: _user.adharCard,
                        //       panCard: _user.panCard,
                        //       pinCode: value,
                        //       staffName: _user.staffName,
                        //       amc: _user.amc,
                        //       tax: double.parse(value!));
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
                          labelText: 'Tax',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        // initialValue: widget.user!['amc'].toString(),
                        controller: amcCntrl,
                        // onSaved: (value) {
                        //   _user = UserModel(
                        //       name: _user.name,
                        //       custId: _user.custId,
                        //       phoneNo: _user.phoneNo,
                        //       address: _user.address,
                        //       place: _user.place,
                        //       mailId: _user.mailId,
                        //       staffId: _user.staffId,
                        //       schemeType: _user.schemeType,
                        //       balance: _user.balance,
                        //       id: _user.id,
                        //       token: _user.token,
                        //       totalGram: _user.totalGram,
                        //       branch: _user.branch,
                        //       dateofBirth: _user.dateofBirth,
                        //       nominee: _user.nominee,
                        //       nomineePhone: _user.nomineePhone,
                        //       nomineeRelation: _user.nomineeRelation,
                        //       adharCard: _user.adharCard,
                        //       panCard: _user.panCard,
                        //       pinCode: _user.pinCode,
                        //       staffName: _user.staffName,
                        //       amc: double.parse(value!),
                        //       tax: _user.tax);
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
                          labelText: 'AMC',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        initialValue: widget.user!['mail'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
                            phoneNo: _user.phoneNo,
                            address: _user.address,
                            place: _user.place,
                            mailId: value,
                            schemeType: _user.schemeType,
                            balance: _user.balance,
                            id: _user.id,
                            staffId: _user.staffId,
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
                        height: 14,
                      ),
                      TextFormField(
                        initialValue: widget.user!['place'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
                            phoneNo: _user.phoneNo,
                            address: _user.address,
                            place: value!,
                            mailId: _user.mailId,
                            schemeType: _user.schemeType,
                            balance: _user.balance,
                            id: _user.id,
                            staffId: _user.staffId,
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
                        height: 14,
                      ),
                      Text(
                        " date of birth",
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
                          padding: EdgeInsets.only(left: 10, right: 10, top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        height: 14,
                      ),
                      TextFormField(
                        initialValue: widget.user!['nominee'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
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
                        height: 14,
                      ),
                      TextFormField(
                        initialValue: widget.user!['nomineePhone'],
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
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
                        height: 14,
                      ),
                      TextFormField(
                        initialValue: widget.user!['nomineeRelation'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
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
                        height: 14,
                      ),
                      TextFormField(
                        initialValue: widget.user!['adharCard'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
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
                        initialValue: widget.user!['panCard'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
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
                        initialValue: widget.user!['pinCode'],
                        onSaved: (value) {
                          _user = UserModel(
                            name: _user.name,
                            custId: _user.custId,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width * .3,
                              height: MediaQuery.of(context).size.height * .06,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: useColor.homeIconColor,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  if (isLoad)
                                    return; // Prevent multiple taps when already saving

                                  setState(() {
                                    isLoad = true;
                                  });

                                  if (oldBalance.toString() ==
                                      balanceCnttrl.text) {
                                    _saveForm();
                                  } else {
                                    if (transaction.isNotEmpty) {
                                      setState(() {
                                        isLoad = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Balance Can\'t Update')),
                                      );
                                    } else {
                                      print("--- transaction empty ------");
                                      _saveForm();
                                    }
                                  }
                                },
                                child: isLoad
                                    ? Text('Saving...',
                                        style: TextStyle(color: Colors.white))
                                    : Text('Save',
                                        style: TextStyle(color: Colors.white)),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  bool isLoad = false;
}
