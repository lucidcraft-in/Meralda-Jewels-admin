import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .35,
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width * .6,
                  height: MediaQuery.of(context).size.height * .28,
                  child: Image(
                    image: AssetImage(
                      "assets/images/icon1-removebg-preview.png",
                    ),
                    fit: BoxFit.fill,
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
                      icon: Icon(Icons.settings),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            child: Container(
                              width: MediaQuery.of(context).size.width * .35,
                              height: MediaQuery.of(context).size.height * .03,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.lock),
                                  Text("Reset Password"),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: MediaQuery.of(context).size.width * .2,
                                height:
                                    MediaQuery.of(context).size.height * .03,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(Icons.logout),
                                    Text("Logout"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ];
                      }))),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                child: Text("sdhd"),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .7,
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 0)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .11,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.user,
                                    size: 40,
                                  ),
                                  onPressed: () {})),
                          Text(
                            "Customer",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .11,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.moneyCheck,
                                    size: 40,
                                  ),
                                  onPressed: () {})),
                          Text(
                            "Gold Rate",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 0)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .11,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.sliders,
                                    size: 40,
                                  ),
                                  onPressed: () {})),
                          Text(
                            "Slider",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 0)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .11,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.userGroup,
                                    size: 40,
                                  ),
                                  onPressed: () {})),
                          Text(
                            "Staff",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 0)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .11,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.boxOpen,
                                    size: 40,
                                  ),
                                  onPressed: () {})),
                          Text(
                            "Product",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 0)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .11,
                              child: IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.noteSticky,
                                    size: 40,
                                  ),
                                  onPressed: () {})),
                          Text(
                            "Customer Report",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 0)),
                        ],
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
