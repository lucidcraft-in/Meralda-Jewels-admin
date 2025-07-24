import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/colors.dart';
import '../../providers/staff.dart';
import './staff_list_screen.dart';
import '../home_screen.dart';

class UpdateStaffScreen extends StatefulWidget {
  UpdateStaffScreen({Key? key, required this.staff, required this.db})
      : super(key: key);
  static const routeName = '/update-staff';

  Map staff;
  Staff db;
  @override
  _UpdateStaffScreenState createState() => _UpdateStaffScreenState();
}

class _UpdateStaffScreenState extends State<UpdateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _staff = StaffModel(
    id: '',
    staffName: '',
    location: '',
    address: '',
    phoneNo: '',
    password: '',
    commission: 0,
    token: '',
    type: 0,
    branch: 0,
  );

  // Future<void> _delete() async {
  //   try {
  //     try {
  //       Provider.of<Staff>(context, listen: false).delete(widget.staff['id']);
  //       await showDialog(
  //         context: context,
  //         builder: (ctx) => AlertDialog(
  //           title: Text('Succes!'),
  //           content: Text('Deleted Successfully'),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text('Okay'),
  //               onPressed: () {
  //                 Navigator.pushNamed(context, StaffListScreen.routeName);
  //                 setState(() {});
  //               },
  //             )
  //           ],
  //         ),
  //       );
  //     } catch (err) {

  //       print(err);
  //       await showDialog(
  //         context: context,
  //         builder: (ctx) => AlertDialog(
  //           title: Text('An error occurred!'),
  //           content: Text('Something went wrong. ${err}'),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text('Okay'),
  //               onPressed: () {
  //                 Navigator.of(ctx).pop();
  //               },
  //             )
  //           ],
  //         ),
  //       );
  //     }
  //     setState(() {
  //       _isLoading = false;
  //       Navigator.of(context).pop();
  //     });
  //   } catch (err) {}
  // }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      Provider.of<Staff>(context, listen: false)
          .update(widget.staff['id'], _staff)
          .then((value) {
        final snackBar = SnackBar(content: const Text('Updated Successfully!'));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => StaffListScreen()));
        setState(() {});
      });

      // await showDialog(
      //   context: context,
      //   builder: (ctx) => AlertDialog(
      //     title: Text('Succes!'),
      //     content: Text('Updated Successfully'),
      //     actions: <Widget>[
      //       FlatButton(
      //         child: Text('Okay'),
      //         onPressed: () {
      //           Navigator.pushReplacement(context,
      //               MaterialPageRoute(builder: (context) => StaffListScreen()));
      //           setState(() {});
      //         },
      //       )
      //     ],
      //   ),
      // );
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
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Update Staff",
            style: TextStyle(fontFamily: 'latto', fontWeight: FontWeight.bold),
          ),
          backgroundColor: useColor.homeIconColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
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
                          initialValue: widget.staff['staffName'],
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
                                branch: _staff.branch);
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
                          initialValue: widget.staff['phoneNo'],
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
                            labelText: 'Enter Phone Number',
                          ),
                        ),
                        TextFormField(
                          maxLines: 4,
                          initialValue: widget.staff['address'],
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
                        TextFormField(
                          initialValue: widget.staff['location'],
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
                        TextFormField(
                          initialValue: widget.staff['password'],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .3,
                              height: MediaQuery.of(context).size.height * .06,
                              decoration: BoxDecoration(
                                  color: useColor.homeIconColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextButton(
                                onPressed: () {
                                  _saveForm();
                                },
                                child: const Text(
                                  'Update',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
