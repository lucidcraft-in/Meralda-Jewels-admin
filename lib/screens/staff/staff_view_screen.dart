import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import '../../providers/staff.dart';
import '../../providers/user.dart';
import './staff_report_screen.dart';

class StaffViewScreen extends StatefulWidget {
  StaffViewScreen({Key? key, required this.staff, required this.db})
      : super(key: key);
  Map staff;
  Staff db;

  @override
  _StaffViewScreenState createState() => _StaffViewScreenState();
}

class _StaffViewScreenState extends State<StaffViewScreen> {
  User? dbUser;
  List userList = [];
  double totalAmountNeeded = 0;
  initialise() {
    dbUser = User();
    dbUser!.initiliase();
    dbUser!.readBystaffId(widget.staff['id']).then((value) {
      setState(() {
        userList = value!;
        isLoad = true;
      });
    });
  }

  bool isLoad = false;

  @override
  void initState() {
    initialise();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
          title: Text(
            "${widget.staff['staffName']}".toUpperCase() + "'S Customer",
            style: TextStyle(fontSize: 15),
          ),
          actions: [],
          backgroundColor: useColor.homeIconColor),
      body: isLoad
          ? Column(
              children: <Widget>[
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .8,
                    child: userList != null
                        ? userList.length > 0
                            ? ListView.builder(
                                itemCount: userList[0].length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          width: double.infinity,
                                          height: 1,
                                          color: Colors.blueGrey.shade100,
                                        ),
                                        ListTile(
                                          tileColor: Colors.white,
                                          title: Text(
                                            ' ${userList[0][index]['name']}'
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                          subtitle: Text(
                                              userList[0][index]['custId']),
                                          leading: CircleAvatar(
                                              backgroundColor: Colors.blueGrey,
                                              child: Icon(
                                                Icons.account_box,
                                                color: Colors.white,
                                              )),
                                          onTap: () {},
                                        ),
                                      ],
                                    ),
                                  );
                                })
                            : Center(
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "No data Available",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    )),
                              )
                        : Center(
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "no users registerd",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )),
                          )),
                Flexible(
                  child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Total Customer",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${userList[0].length}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
