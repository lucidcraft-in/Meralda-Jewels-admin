import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constant/colors.dart';
import '../screens/category/categoryList..dart';
import './auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './customer/customer_screen.dart';
import './gold_rate/gold_rate.dart';
import './slider/slider_view.dart';
import './staff/staff_list_screen.dart';
import './auth/password_change_screen.dart';
import './customer/customer_report_screen.dart';
import '../providers/collections.dart';
import '../providers/transaction.dart';
import './permission_message.dart';
import '../providers/goldrate.dart';
import 'customer/customerCloseRport.dart';
import 'customer/superAdminCustomer.dart';
import 'payment/getAllSubmitRec.dart';
import 'slider/sliderPage.dart';
import 'transactionReport.dart/reprtWise.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime timeBackPress = DateTime.now();
  DateTime selectedStratDate = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  var staff;
  int? staffType;
  Collection? dbCollection;
  double totalCollectionAmount = 0;
  double totalRecieveAmount = 0;
  int? branchId;
  bool? _checkValue;
  List collectionList = [];
  List transactionList = [];
  List alllist = [];
  double recieptAmount = 0;
  double purchaseAmt = 0;
  double reciptgram = 0;
  double purchasegram = 0;
  double gramBalance = 0;
  double amountBalance = 0;
  double recieptPending = 0;
  Goldrate? dbgold;
  TransactionProvider? db;
  initialise() {
    dbgold = Goldrate();

    dbgold!.initiliase();

    dbgold!.checkPermission().then((value) => {
          if (value == false)
            {
              Navigator.pushReplacementNamed(
                context,
                PermissionMessage.routeName,
              ),
            }
        });

    dbCollection = Collection();
    dbCollection!.initiliase();
    dbCollection!.todaycollection(selectedStratDate, branchId!).then((value) {
      setState(() {
        collectionList = value!;
        // totalBalance = userLst[0]['totalAmount'];

        // totalCommission(totalBalance);
        totalCollectionAmount = value[0]['totalCollectedAmt'];
        totalRecieveAmount = value[0]['totalPaidAmount'];
      });
    });

    // db = TransactionProvider();
    // db!.initiliase();

    // db!.getAllSales(branchId!).then((value) {
    //   setState(() {
    //     alllist = value!;

    //     recieptAmount = alllist[0];
    //     purchaseAmt = alllist[1];
    //     reciptgram = alllist[2];
    //     purchasegram = alllist[3];
    //     amountBalance = alllist[4];
    //     gramBalance = alllist[5];
    //     recieptPending = alllist[6];
    //   });
    //   // print(recieptAmount),
    //   // print(purchaseAmt),
    //   // print(amountBalance),
    //   // print(gramBalance),
    //   // print(recieptPending),
    // });
  }

  // late int staffType;
  String brName = "";
  Future loginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var Staff = jsonDecode(prefs.getString('staff')!);
    setState(() {
      staffType = Staff['type'];
    });
    setState(() {
      branchId = Staff['branch'];
    });
    // if (branchId == 0) {
    //   setState(() {
    //     brName = "Super Admin";
    //   });
    // } else if (branchId == 1) {
    //   setState(() {
    //     brName = "Alathur";
    //   });
    // } else if (branchId == 2) {
    //   setState(() {
    //     brName = "Chittur";
    //   });
    // } else if (branchId == 2) {
    //   setState(() {
    //     brName = "Vadakkancheri";
    //   });
    // }
    // print(staffType);
    // print(branchId);
    setState(() {
      initialise();
    });
  }

  @override
  void initState() {
    super.initState();
    loginData();
  }

  redirectLoginPage() {
    if (_checkValue == true) {
      Navigator.of(context).pushNamed(HomeScreen.routeName);
    } else {
      Navigator.of(context).pushNamed(LoginScreen.routeName);
    }
  }

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _checkValue = prefs.containsKey('staff');
    setState(() {
      staff = jsonDecode(prefs.getString('staff')!);
    });
    staffType = staff['type'];

    super.didChangeDependencies();
    // user = prefs.containsKey('user');
  }

  @override
  Widget build(BuildContext context) {
    logout() async {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // preferences.getKeys();
      // for (String key in preferences.getKeys()) {
      //   preferences.remove(key);
      // }

      setState(() {});

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => new LoginScreen()),
          (Route<dynamic> route) => false);
    }

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        body: staffType == 1
            ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .35,
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: SafeArea(
                          child: Container(
                            width: MediaQuery.of(context).size.width * .6,
                            height: MediaQuery.of(context).size.height * .25,
                            child: Image(
                              image: AssetImage(
                                "assets/images/icon1.png",
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200,
                    left: 180,
                    child: Container(
                      // color: Colors.white,
                      child: Text(
                        brName.toUpperCase(),
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 50, right: 10),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton(
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.of(context).pushNamed(
                                              PasswordChangeScreen.routeName);
                                        },
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.lock,
                                            size: 22,
                                          ),
                                          title: Text(
                                            "Reset Password",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                        )),
                                  ),
                                  PopupMenuItem(
                                    child: GestureDetector(
                                      onTap: () {
                                        logout();
                                      },
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.logout,
                                          size: 22,
                                        ),
                                        title: Text(
                                          "Logout",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ];
                              }))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * .69,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Card(
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(15.0),
                            //     ),
                            //     child: Container(
                            //       padding: EdgeInsets.all(5),
                            //       child: Column(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceAround,
                            //         children: [
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceAround,
                            //             children: [
                            //               Container(
                            //                 child: Text(
                            //                   "Total Collection",
                            //                   style: TextStyle(
                            //                     fontSize: 11,
                            //                     fontWeight: FontWeight.w500,
                            //                     color: Colors.grey.shade600,
                            //                   ),
                            //                 ),
                            //               ),
                            //               Container(
                            //                 child: Text(
                            //                   "Balance",
                            //                   style: TextStyle(
                            //                     fontSize: 11,
                            //                     fontWeight: FontWeight.w500,
                            //                     color: Colors.grey.shade600,
                            //                   ),
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceAround,
                            //             children: [
                            //               Container(
                            //                 child: Flexible(
                            //                   child: Text(
                            //                     overflow: TextOverflow.ellipsis,
                            //                     "₹ ${recieptAmount.toString()} / gm ${reciptgram.toStringAsFixed(4)}",
                            //                     style: TextStyle(
                            //                       fontSize: 12,
                            //                       fontWeight: FontWeight.w500,
                            //                       color: Colors.grey.shade700,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //               Container(
                            //                 child: Flexible(
                            //                   child: Text(
                            //                     overflow: TextOverflow.ellipsis,
                            //                     "₹ ${amountBalance.toString()}  / gm ${gramBalance.toStringAsFixed(4)}",
                            //                     style: TextStyle(
                            //                       fontSize: 12,
                            //                       fontWeight: FontWeight.w500,
                            //                       color: Colors.grey.shade700,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //           // ==============
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceAround,
                            //             children: [
                            //               Container(
                            //                 child: Text(
                            //                   "Total Purchase",
                            //                   style: TextStyle(
                            //                     fontSize: 11,
                            //                     fontWeight: FontWeight.w500,
                            //                     color: Colors.grey.shade600,
                            //                   ),
                            //                 ),
                            //               ),
                            //               Container(
                            //                 child: Text(
                            //                   "Staff Reciept Pending",
                            //                   style: TextStyle(
                            //                     fontSize: 11,
                            //                     fontWeight: FontWeight.w500,
                            //                     color: Colors.grey.shade600,
                            //                   ),
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceAround,
                            //             children: [
                            //               Container(
                            //                 child: Flexible(
                            //                   child: Text(
                            //                     overflow: TextOverflow.ellipsis,
                            //                     "₹ ${purchaseAmt.toString()} / gm ${purchasegram.toStringAsFixed(4)}",
                            //                     style: TextStyle(
                            //                       fontSize: 12,
                            //                       fontWeight: FontWeight.w500,
                            //                       color: Colors.grey.shade700,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //               Container(
                            //                 child: Flexible(
                            //                   child: Text(
                            //                     overflow: TextOverflow.ellipsis,
                            //                     "₹ ${recieptPending.toString()}",
                            //                     style: TextStyle(
                            //                       fontSize: 12,
                            //                       fontWeight: FontWeight.w500,
                            //                       color: Colors.grey.shade700,
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //       height: 110,
                            //       width: double.infinity,
                            //     )),
                            Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        child: Text(
                                          "Today collection report",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            child: Text(
                                              "Total Collection",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "Total Recive",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            child: Text(
                                              totalCollectionAmount.toString(),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              totalRecieveAmount.toString(),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  height: 100,
                                  width: double.infinity,
                                )),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SubmittedRec()));
                              },
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Payment Screenshot",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: useColor.homeIconColor,
                                          ),
                                        )
                                      ],
                                    ),
                                    height: 80,
                                    width: double.infinity,
                                  )),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: Center(
                                  child: GridView.extent(
                                primary: false,
                                padding: const EdgeInsets.all(16),
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                maxCrossAxisExtent: 200.0,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .11,
                                            child: IconButton(
                                              icon: FaIcon(
                                                FontAwesomeIcons.user,
                                                size: 32,
                                                color: useColor.homeIconColor,
                                              ),
                                              onPressed: () async {
                                                // final CollectionReference
                                                //     usersCollection =
                                                //     FirebaseFirestore.instance
                                                //         .collection('user');

                                                // // Fetch all user documents
                                                // QuerySnapshot usersSnapshot =
                                                //     await usersCollection.get();

                                                // for (QueryDocumentSnapshot userDoc
                                                //     in usersSnapshot.docs) {
                                                //   Map<String, dynamic>
                                                //       userData = userDoc.data()
                                                //           as Map<String,
                                                //               dynamic>;

                                                //   // Check if 'tax' and 'amc' fields exist, if not, update them
                                                //   if (!userData
                                                //           .containsKey('tax') ||
                                                //       !userData
                                                //           .containsKey('amc')) {
                                                //     await usersCollection
                                                //         .doc(userDoc.id)
                                                //         .update({
                                                //       if (!userData
                                                //           .containsKey('tax'))
                                                //         'tax':
                                                //             0, // Default value for tax
                                                //       if (!userData
                                                //           .containsKey('amc'))
                                                //         'amc':
                                                //             0, // Default value for amc
                                                //     });
                                                //   }
                                                // }

                                                // print(
                                                //     'Tax and AMC fields updated where necessary.');

                                                Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CustomerScreen()))
                                                    .then((val) {
                                                  initialise();
                                                });
                                              },
                                            )),
                                        Text(
                                          "Customer",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .11,
                                            child: IconButton(
                                              icon: FaIcon(
                                                FontAwesomeIcons.moneyCheck,
                                                size: 32,
                                                color: useColor.homeIconColor,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    GoldRateScreen.routeName);
                                              },
                                            )),
                                        Text(
                                          "Gold Rate",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .11,
                                            child: IconButton(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.sliders,
                                                  size: 32,
                                                  color: useColor.homeIconColor,
                                                ),
                                                onPressed: () {
                                                  // Navigator.of(context)
                                                  //     .pushNamed(
                                                  //         ViewSlidersScreen
                                                  //             .routeName);

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Sliderpage()));
                                                })),
                                        Text(
                                          "Slider",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .11,
                                            child: IconButton(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.userGroup,
                                                  size: 32,
                                                  color: useColor.homeIconColor,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(StaffListScreen
                                                          .routeName)
                                                      .then((val) {
                                                    initialise();
                                                  });
                                                })),
                                        Text(
                                          "Staff",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .11,
                                            child: IconButton(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.boxOpen,
                                                  size: 32,
                                                  color: useColor.homeIconColor,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CategoryScreen()));
                                                })),
                                        Text(
                                          "Product",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .11,
                                            child: IconButton(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.noteSticky,
                                                  size: 32,
                                                  color: useColor.homeIconColor,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ReportWiseScreen()));
                                                  // CustomerReportScreen()));
                                                })),
                                        Text(
                                          "Report",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  // Container(
                                  //   padding: const EdgeInsets.all(8),
                                  //   child: Column(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.center,
                                  //     children: [
                                  //       Container(
                                  //           width: double.infinity,
                                  //           height: MediaQuery.of(context)
                                  //                   .size
                                  //                   .height *
                                  //               .11,
                                  //           child: IconButton(
                                  //               icon: FaIcon(
                                  //                 FontAwesomeIcons.cloudUpload,
                                  //                 size: 32,
                                  //                 color: Theme.of(context)
                                  //                     .primaryColor,
                                  //               ),
                                  //               onPressed: () {
                                  //                 Navigator.push(
                                  //                     context,
                                  //                     MaterialPageRoute(
                                  //                         builder: (context) =>
                                  //                             ExcelUploadScreen()));
                                  //               })),
                                  //       Text(
                                  //         "Upload Excel",
                                  //         style: TextStyle(
                                  //             fontWeight: FontWeight.w500,
                                  //             color: Colors.grey.shade600),
                                  //       )
                                  //     ],
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.white,
                                  //     borderRadius: BorderRadius.circular(15),
                                  //   ),
                                  // ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .11,
                                            child: IconButton(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.briefcase,
                                                  size: 32,
                                                  color: useColor.homeIconColor,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CloseReport()));
                                                  // CustomerReportScreen()));
                                                })),
                                        Text(
                                          "Close Report",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  // Container(
                                  //   padding: const EdgeInsets.all(8),
                                  //   child: Column(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.center,
                                  //     children: [
                                  //       Container(
                                  //           width: double.infinity,
                                  //           height: MediaQuery.of(context)
                                  //                   .size
                                  //                   .height *
                                  //               .11,
                                  //           child: IconButton(
                                  //               icon: FaIcon(
                                  //                 FontAwesomeIcons.fileUpload,
                                  //                 size: 32,
                                  //                 color: Theme.of(context)
                                  //                     .primaryColor,
                                  //               ),
                                  //               onPressed: () {
                                  //                 Navigator.push(
                                  //                     context,
                                  //                     MaterialPageRoute(
                                  //                         builder: (context) =>
                                  //                             ExcelUploadCustomer()));
                                  //                 // CustomerReportScreen()));
                                  //               })),
                                  //       Text(
                                  //         "Upload Customer",
                                  //         style: TextStyle(
                                  //             fontWeight: FontWeight.w500,
                                  //             color: Colors.grey.shade600),
                                  //       )
                                  //     ],
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.white,
                                  //     borderRadius: BorderRadius.circular(15),
                                  //   ),
                                  // ),
                                ],
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .35,
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: SafeArea(
                          child: Container(
                            width: MediaQuery.of(context).size.width * .6,
                            height: MediaQuery.of(context).size.height * .25,
                            child: Image(
                              image: AssetImage(
                                "assets/images/icon1.png",
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 50, right: 10),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton(
                              icon: Icon(
                                Icons.settings,
                                color: useColor.homeIconColor,
                              ),
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.of(context).pushNamed(
                                              PasswordChangeScreen.routeName);
                                        },
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.lock,
                                            size: 22,
                                          ),
                                          title: Text(
                                            "Reset Password",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                        )),
                                  ),
                                  PopupMenuItem(
                                    child: GestureDetector(
                                      onTap: () {
                                        logout();
                                      },
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.logout,
                                          size: 22,
                                        ),
                                        title: Text(
                                          "Logout",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ];
                              }))),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .7,
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .11,
                                              child: IconButton(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.user,
                                                  size: 32,
                                                  color: Color(0xFF073531),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerScreen())).then(
                                                      (val) {
                                                    initialise();
                                                  });
                                                },
                                              )),
                                          Text(
                                            "Customer",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 200,
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .11,
                                              child: IconButton(
                                                  icon: FaIcon(
                                                    FontAwesomeIcons.noteSticky,
                                                    size: 32,
                                                    color: Color(0xFF073531),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CustomerReportScreen()));
                                                  })),
                                          Text(
                                            "Customer Report",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600),
                                          )
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ],
                                ),
                              ))))
                ],
              ),
      ),
    );
  }
}
