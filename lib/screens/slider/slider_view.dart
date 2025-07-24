import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart' as firbase_storage;
import 'package:file_picker/file_picker.dart';
import '../../constant/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/storage_service.dart';

class ViewSlidersScreen extends StatefulWidget {
  static const routeName = '/view-slider';
  const ViewSlidersScreen({Key? key}) : super(key: key);

  @override
  _ViewSlidersScreenState createState() => _ViewSlidersScreenState();
}

class _ViewSlidersScreenState extends State<ViewSlidersScreen> {
  bool appbarSelect = false;
  bool isLoading = false;
  String? imageId;
  String? imageNmae;
  String? imageType;
  List slideList = [];
  Stream? slides;
  Storage? db;
  List userList = [];

  _queryDb(String type) {
    Provider.of<Storage>(context, listen: false).getSlide(type).then((value) {
      setState(() {
        slideList = value != null ? value : [];
      });
    });
    // FirebaseFirestore.instance
    //     .collection('Banner')
    //     .where("imageType", isEqualTo: type)
    //     .snapshots()
    //     .map(
    //       (list) => list.docs.map((doc) => doc.data()),
    //     );
  }

  bool _addSelect = false;

  @override
  void initState() {
    _queryDb("Banner");
    super.initState();
    initialise();
  }

  initialise() {
    db = Storage();
    db!.initiliase();
    db!.read().then((value) {
      setState(() {
        userList = value != null ? value : [];
        isLoad = true;
      });
    });
  }

  Widget appBarTitle = new Text(
    "Sliders",
    style: new TextStyle(color: Colors.white),
  );
  Icon actionIcon = new Icon(
    Icons.delete,
    color: Colors.white,
  );
  final Storage storage = Storage();
  selectedBar(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: useColor.homeIconColor,
        actions: [
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  appbarSelect = false;
                });
              }),
          IconButton(
              icon: actionIcon,
              onPressed: () {
                setState(() {
                  if (this.actionIcon.icon == Icons.delete) {
                    {
                      Widget cancelButton = OutlinedButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                      Widget continueButton = OutlinedButton(
                          child: Text("Continue"),
                          onPressed: () {
                            // print(imageId);
                            // print(imageNmae);
                            // print(imageType);
                            storage
                                .delete(imageId!, imageNmae!, imageType!)
                                .then((value) {
                              _queryDb("Banner");
                              Navigator.pop(context);
                              setState(() {
                                appbarSelect = false;
                              });
                            });
                          });
                      // set up the AlertDialog
                      AlertDialog alert = AlertDialog(
                        title: Text("AlertDialog"),
                        content:
                            Text("Would you like to continue deleting slide ?"),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                      );
                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    }
                  }
                });
              })
        ]);
  }

  buildBar(BuildContext context) {
    return AppBar(
      backgroundColor: useColor.homeIconColor,
      title: appBarTitle,
    );
  }

  String typeof = "bnr";
  List banrList = [];
  List tcList = [];
  bool isLoad = false;
  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: appbarSelect ? selectedBar(context) : buildBar(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: useColor.homeIconColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          if (_addSelect == false) {
            setState(() {
              _addSelect = true;
            });
          } else {
            setState(() {
              _addSelect = false;
            });
          }
        },
      ),
      body: _addSelect == false
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _queryDb("Banner");
                              });
                            },
                            child: Container(
                              height: 30,
                              width: 100,
                              child: Center(
                                  child: Text(
                                "Banner",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  border: Border.all()),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _queryDb("T % C");
                              });
                            },
                            child: Container(
                              height: 30,
                              width: 100,
                              child: Center(
                                  child: Text(
                                "T & C",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  border: Border.all()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    isLoad
                        ? slideList.isNotEmpty
                            ? Expanded(
                                child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 200,
                                            childAspectRatio: 2 / 2,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20),
                                    itemCount: slideList.length,
                                    itemBuilder: (BuildContext ctx, index) {
                                      return
                                          // slideList[index]["imageType"] == "Banner"
                                          //     ?
                                          GestureDetector(
                                              onTap: () {
                                                // print(slideList[index]);
                                              },
                                              onLongPress: () {
                                                setState(() {
                                                  appbarSelect = true;
                                                  imageId =
                                                      slideList[index]["id"];
                                                  imageType = slideList[index]
                                                      ["imageType"];
                                                  imageNmae =
                                                      'images/${slideList[index]["photoName"]}';
                                                });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Image.network(
                                                    slideList[index]['photo'],
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                              ));
                                      // : Container();
                                    }),
                              )
                            : Container(
                                height: 100,
                                child:
                                    Center(child: Text("No Image Found....")),
                              )
                        : Container(
                            height: 500,
                            child: Center(child: CircularProgressIndicator())),
                  ],
                ),
              ),
            )
          : Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: Color.fromARGB(255, 240, 236, 236),
                      ),
                      child: Center(
                        child: Text(
                          "Add image",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Add image for :   ",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownButton<String>(
                          hint: Text(selectedValue != null
                              ? selectedValue!
                              : "Select.."),
                          items:
                              <String>["T % C", "Banner"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            // print(value);
                            setState(() {
                              selectedValue = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Color.fromARGB(255, 240, 236, 236),
                          border: Border.all()),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            path != null ? "Image Added" : "Add Image",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    path != null ? Colors.green : Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Icon(Icons.add_a_photo_outlined),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              addImage();
                            },
                            child: Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Color.fromARGB(255, 240, 236, 236),
                                  border: Border.all()),
                              child: Center(
                                  child: Text(
                                "Select Image",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                    fontSize: 13),
                              )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          path != null ? Text(fileName) : Text(""),
                        ],
                      )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: useColor.homeIconColor,
                        ),
                        height: MediaQuery.of(context).size.height * .06,
                        width: MediaQuery.of(context).size.width * .4,
                        child: TextButton(
                          onPressed: isLoading == false
                              ? () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  if (selectedValue != null && path != null) {
                                    save();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Add Image Type or Select Image")));
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              : null,
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Submit',
                                      style: TextStyle(
                                          color: useColor.appbarTextWhite),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Submit',
                                  style: TextStyle(
                                      color: useColor.appbarTextWhite),
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
      // ),
    );
  }

  String? selectedValue;
  String fileName = "";
  var path;
  String fileType = "";
  addImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return null;
    }
    String fileExtension = result.files.single.extension ?? '';
    setState(() {
      path = result.files.single.path;
      fileName = result.files.single.name;
      fileType = fileExtension;
    });
  }

  save() {
    storage
        .uploadFile(path!, fileName, selectedValue!, fileType)
        .then((value) => print('done'))
        .then((value) {
      _queryDb("Banner");
      setState(() {
        _addSelect = false;
        isLoading = false;

        path = "";
        fileName = "";
      });
    });
  }
}
