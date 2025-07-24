import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constant/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/staff.dart';
import './staff_list_screen.dart';

class CreateStaffScreen extends StatefulWidget {
  static const routeName = '/create-staff';
  CreateStaffScreen({Key? key, required this.staffType}) : super(key: key);
  int staffType;

  @override
  _CreateStaffScreenState createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  TextEditingController staffIdCntrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? selectedBranch;
  List branches = [
    {"id": 1, "name": "Thrissur Golden Alathur"},
    {"id": 2, "name": "Thrissur Golden Chittur "},
    {"id": 3, "name": "Thrissur Golden Pattambi "},
  ];
  var _isLoading = false;
  var _staff = StaffModel(
    id: '',
    staffName: '',
    location: '',
    address: ';',
    phoneNo: '',
    password: '',
    type: 0,
    commission: 0,
    token: '',
    branch: 0,
  );

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        isClick = false;
      });
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Staff>(context, listen: false)
          .create(_staff, staffIdCntrl.text);

      final snackBar = SnackBar(content: const Text('Saved successfully!'));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      setState(() {
        _isLoading = false;
        isClick = false;
        Navigator.of(context).pop();
        // Navigator.pushReplacementNamed(context, StaffListScreen.routeName);
      });
    } catch (err) {
      print(err);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: Text('Create Staff'),
          actions: [],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
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
                    height: MediaQuery.of(context).size.height * .7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextFormField(
                          controller: staffIdCntrl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Staff ID';
                            }
                            return null;
                          },
                          // onSaved: (value) {
                          //   _staff = StaffModel(
                          //     staffName: value!,
                          //     location: _staff.location,
                          //     address: _staff.address,
                          //     phoneNo: _staff.phoneNo,
                          //     password: _staff.password,
                          //     commission: _staff.commission,
                          //     id: _staff.id,
                          //     token: _staff.token,
                          //     type: _staff.type,
                          //     branch: _staff.branch,
                          //   );
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
                            labelText: 'Enter Staff ID',
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Staff name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _staff = StaffModel(
                              staffName: value!,
                              location: _staff.location,
                              address: _staff.address,
                              phoneNo: _staff.phoneNo,
                              password: _staff.password,
                              commission: _staff.commission,
                              id: _staff.id,
                              token: _staff.token,
                              type: _staff.type,
                              branch: _staff.branch,
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
                            labelText: 'Enter Staff name',
                          ),
                        ),
                        TextFormField(
                          onSaved: (value) {
                            _staff = StaffModel(
                              staffName: _staff.staffName,
                              location: value!,
                              address: _staff.address,
                              phoneNo: _staff.phoneNo,
                              password: _staff.password,
                              commission: _staff.commission,
                              id: _staff.id,
                              token: _staff.token,
                              type: _staff.type,
                              branch: _staff.branch,
                            );
                          },
                          decoration: InputDecoration(
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
                            labelText: 'Enter location',
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Phone ';
                            } else if (value.length != 10) {
                              return 'Please enter  valid number ';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _staff = StaffModel(
                              staffName: _staff.staffName,
                              location: _staff.location,
                              address: _staff.address,
                              phoneNo: value!,
                              password: _staff.password,
                              commission: _staff.commission,
                              id: _staff.id,
                              token: _staff.token,
                              type: _staff.type,
                              branch: _staff.branch,
                            );
                          },
                          decoration: InputDecoration(
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
                        TextFormField(
                          maxLines: 4,
                          onSaved: (value) {
                            _staff = StaffModel(
                              staffName: _staff.staffName,
                              location: _staff.location,
                              address: value!,
                              phoneNo: _staff.phoneNo,
                              password: _staff.password,
                              commission: _staff.commission,
                              id: _staff.id,
                              token: _staff.token,
                              type: _staff.type,
                              branch: _staff.branch,
                            );
                          },
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey,
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
                        // TextFormField(
                        //   keyboardType: TextInputType.number,
                        //   onSaved: (value) {
                        //     _staff = StaffModel(
                        //       staffName: _staff.staffName,
                        //       location: _staff.location,
                        //       address: _staff.address,
                        //       phoneNo: _staff.phoneNo,
                        //       password: _staff.password,
                        //       commission: value != ""
                        //           ? double.parse(value!)
                        //           : double.parse(0.0.toString()),
                        //       id: _staff.id,
                        //       token: _staff.token,
                        //       type: _staff.type,
                        //       branch: _staff.branch,
                        //     );
                        //   },
                        //   decoration: InputDecoration(
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: Colors.red,
                        //         width: 1.0,
                        //       ),
                        //     ),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: Colors.black,
                        //         width: 1.0,
                        //       ),
                        //     ),
                        //     labelText: 'Enter Staff Commission',
                        //   ),
                        // ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password ';
                            } else if (value.length <= 5) {
                              return 'Password must be more than 5 charater ';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _staff = StaffModel(
                              staffName: _staff.staffName,
                              location: _staff.location,
                              address: _staff.address,
                              phoneNo: _staff.phoneNo,
                              password: value!,
                              commission: _staff.commission,
                              id: _staff.id,
                              token: _staff.token,
                              type: _staff.type,
                              branch: _staff.branch,
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
                            labelText: 'Password',
                          ),
                        ),
                        // Container(
                        //   width: double.infinity,
                        //   height: MediaQuery.of(context).size.height * .074,
                        //   decoration: BoxDecoration(
                        //       // color: Colors.white,
                        //       borderRadius: BorderRadius.circular(5),
                        //       border: Border.all()),
                        //   padding: EdgeInsets.only(left: 10, right: 10, top: 7),
                        //   child: DropdownButton(
                        //       underline: SizedBox(),
                        //       style: TextStyle(
                        //           // fontWeight: FontWeight.w500,
                        //           fontSize: 14,
                        //           color: Colors.black),
                        //       isExpanded: true,
                        //       hint: Text(
                        //         "Select Branch",
                        //         style: TextStyle(
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 15,
                        //             color: Color.fromARGB(115, 0, 0, 0)),
                        //       ),
                        //       value: selectedBranch,
                        //       items: branches.map((val) {
                        //         return DropdownMenuItem(
                        //             value: val["id"],
                        //             child: Padding(
                        //               padding: const EdgeInsets.all(8.0),
                        //               child: Text(val["name"]),
                        //             ));
                        //       }).toList(),
                        //       onChanged: (value) {
                        //         setState(() {
                        //           selectedBranch = value as int;
                        //         });
                        //         _staff = StaffModel(
                        //           staffName: _staff.staffName,
                        //           location: _staff.location,
                        //           address: _staff.address,
                        //           phoneNo: _staff.phoneNo,
                        //           password: _staff.password,
                        //           commission: _staff.commission,
                        //           id: _staff.id,
                        //           token: _staff.token,
                        //           type: _staff.type,
                        //           branch: selectedBranch!,
                        //         );
                        //       }),
                        // ),
                        Container(
                          width: MediaQuery.of(context).size.width * .3,
                          height: MediaQuery.of(context).size.height * .06,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: useColor.homeIconColor,
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                isClick = true;
                              });
                              if (isClick == true) {
                                _saveForm();
                              }
                            },
                            child: isClick != true
                                ? Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    'Save....',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  bool isClick = false;
}
