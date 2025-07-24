import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../constant/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/user.dart';

class CloseReport extends StatefulWidget {
  const CloseReport({super.key});

  @override
  State<CloseReport> createState() => _CloseReportState();
}

class _CloseReportState extends State<CloseReport> {
  getCloseUser() async {
    Provider.of<User>(context, listen: false)
        .getClosedUser(selectedDate)
        .then((val) {
      setState(() {
        userList = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCloseUser();
  }

  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: useColor.homeIconColor,
          title: const Text("Close Report"),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Select Month",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () {
                        showMonthPicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1, 5),
                          lastDate: DateTime(DateTime.now().year + 1, 14),
                          initialDate: selectedDate,
                          // locale: Locale("en"),
                        ).then((date) {
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                            Provider.of<User>(context, listen: false)
                                .getClosedUser(selectedDate)
                                .then((val) {
                              setState(() {
                                userList = val;
                              });
                            });
                          }
                          print(selectedDate);
                        });
                      },
                      icon: Icon(Icons.calendar_today),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                  "Selected Month : ${DateFormat('yyyy MMMM').format(selectedDate)}"),
              Divider(),
              userList.length > 0
                  ? ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: Color.fromARGB(37, 128, 23, 23),
                          title: Text(userList[index]["name"]),
                          subtitle: Text(
                              "Closing Balance : ${userList[index]["balaceAtClose"].toString()}"),
                          trailing: IconButton(
                              onPressed: () {
                                _showCloseCustomerDialog(
                                    context, userList[index]);
                              },
                              icon: Icon(FontAwesomeIcons.refresh)),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10);
                      },
                      itemCount: userList.length)
                  : Container(
                      height: 150,
                      child: Center(child: Text("No Data Found...")))
            ],
          ),
        ));
  }

  List userList = [];
  // void _showCloseCustomerDialog(BuildContext context, var cust) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Reactivating Customer'),
  //         content: Container(
  //           height: MediaQuery.of(context).size.height * .2,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text('Are you sure you want to reactivating this customer?'),
  //               SizedBox(height: 10),
  //               Text("Customer Name: ${cust['name']}"),
  //               Text("Customer Balance: ${cust['balaceAtClose']}"),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Reactivate'),
  //             onPressed: () {
  //               Provider.of<User>(context, listen: false).ReactivityCloseUser(
  //                   cust['id'],
  //                   cust['balaceAtClose'],
  //                   cust['closeTotal_gram'],
  //                   DateTime.now());
  //               // Perform delete action here
  //               Navigator.of(context).pop(); // Close the dialog after delete
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showCloseCustomerDialog(BuildContext context, var cust) {
    DateTime? selectedDate = DateTime.now(); // Holds the selected date

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Reactivating Customer'),
              content: Container(
                height: MediaQuery.of(context).size.height * .25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Are you sure you want to reactivate this customer?'),
                    SizedBox(height: 10),
                    Text("Customer Name: ${cust['name']}"),
                    Text("Customer Balance: ${cust['balaceAtClose']}"),
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
                            ? 'Select Reactivation Date'
                            : 'Reactivation Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
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
                  child: Text('Reactivate'),
                  onPressed: () {
                    if (selectedDate != null) {
                      Provider.of<User>(context, listen: false)
                          .ReactivityCloseUser(
                              cust['id'],
                              cust['balaceAtClose'],
                              cust['closeTotal_gram'],
                              DateTime.now());
                      // Handle the reactivation logic here

                      getCloseUser();
                      Navigator.of(context)
                          .pop(); // Close the dialog after reactivation
                    } else {
                      // Optionally show an alert that the date has not been selected
                    }
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
