import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constant/colors.dart';
import '../providers/cmpService.dart';

class CmpPayment extends StatefulWidget {
  const CmpPayment({super.key});

  @override
  State<CmpPayment> createState() => _CmpPaymentState();
}

class _CmpPaymentState extends State<CmpPayment> {
  TextEditingController upiCntrl = TextEditingController();
  TextEditingController acNoCntrl = TextEditingController();
  TextEditingController ifscCntrl = TextEditingController();
  bool isLoad = false;
  String? ext;
  var normalsize;
  var compressSize;
  File? image;
  File? compressedImage;
  String? pickedImage;
  String fileName = "";
  bool isAddMode = true; // Track if we're adding new or updating existing data

  @override
  void initState() {
    super.initState();
    getUpiDtails();
  }

  @override
  void dispose() {
    upiCntrl.dispose();
    acNoCntrl.dispose();
    ifscCntrl.dispose();
    super.dispose();
  }

  String docid = "";
  String backImage = "";
  String oldName = "";

  getUpiDtails() async {
    // Fetch data from the backend
    final companyService = Provider.of<CompanyService>(context, listen: false);
    var qrDetails = await companyService.readQr();

    if (qrDetails != null && qrDetails.isNotEmpty) {
      print("-----");
      print(qrDetails[0]);
      setState(() {
        isAddMode = false; // We're in update mode
        backImage = qrDetails[0]["qrcode"] ?? "";
        upiCntrl.text = qrDetails[0]["upiId"] ?? "";
        acNoCntrl.text = qrDetails[0]["acNo"] ?? "";
        ifscCntrl.text = qrDetails[0]["ifsc"] ?? "";
        fileName = qrDetails[0]["qrname"] ?? "";
        oldName = qrDetails[0]["qrname"] ?? "";
        docid = qrDetails[0]["id"] ?? "";
      });
    } else {
      setState(() {
        isAddMode = true; // We're in add mode
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text(
          isAddMode ? 'Add Payment Details' : 'Update Payment Details',
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromARGB(255, 244, 231, 214),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * .4,
                      width: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: fileName != ""
                          ? backImage != ""
                              ? Image.network(backImage)
                              : image != null
                                  ? Image.file(image!)
                                  : Center(child: Text("No Qr Found"))
                          : Center(child: Text("No Qr Found"))),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * .4,
                    height: MediaQuery.of(context).size.width * .1,
                    child: ElevatedButton(
                      onPressed: () {
                        imagePick(context);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              useColor.homeIconColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "Upload QR Code",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (fileName != "") SizedBox(height: 5),
                  if (fileName != "")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fileName,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            setState(() {
                              image = null;
                              fileName = "";
                              backImage = "";
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                  SizedBox(height: 40),
                  Container(
                    height: MediaQuery.of(context).size.height * .08,
                    width: MediaQuery.of(context).size.width * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: upiCntrl,
                          decoration: InputDecoration(
                              hintText: "Enter UPI ID",
                              labelText: "Enter UPI ID")),
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    height: MediaQuery.of(context).size.height * .08,
                    width: MediaQuery.of(context).size.width * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: acNoCntrl,
                        decoration: InputDecoration(
                            hintText: "Enter Account No",
                            labelText: "Enter Account No"),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: MediaQuery.of(context).size.height * .08,
                    width: MediaQuery.of(context).size.width * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: ifscCntrl,
                          decoration: InputDecoration(
                              hintText: "Enter IFSC", labelText: "Enter IFSC")),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.width * .1,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate required fields based on mode
                        bool hasRequiredFields = isAddMode
                            ? (image != null || backImage.isNotEmpty) &&
                                upiCntrl.text.isNotEmpty
                            : true; // For update mode, we'll allow partial updates

                        if (hasRequiredFields) {
                          setState(() {
                            isLoad = true;
                          });
                          if (isLoad) {
                            submit();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Upload Qrcode and UPI ID...!')));
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              useColor.homeIconColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          isLoad == false
                              ? Text(
                                  isAddMode
                                      ? "Add Payment Details"
                                      : "Update Payment Details",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to pick image
  imagePick(context) async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
      // allowedExtensions: ['png', 'jpg'],
    );

    if (pickedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return null;
    }

    setState(() {
      pickedImage = pickedFile.files.single.path;
      fileName = pickedFile.files.single.name;
      image = File(pickedImage!);
      backImage = ""; // Clear backImage when new image is selected
    });
  }

  // Method to submit the payment details
  submit() async {
    // Create a map of the current values to send for update/create
    final data = {
      'docid': docid,
      'image': image,
      'fileName': fileName,
      'upiId': upiCntrl.text,
      'oldName': oldName,
      'ac_no': acNoCntrl.text,
      'ifsc': ifscCntrl.text,
      'backImage': backImage,
    };

    final companyService = Provider.of<CompanyService>(context, listen: false);

    try {
      int result;
      if (isAddMode) {
        // Create new payment details
        result = await companyService.createQrcode(
            "", // No docid for new entries
            image!,
            fileName,
            upiCntrl.text,
            "", // No oldName for new entries
            acNoCntrl.text,
            ifscCntrl.text);
      } else {
        // Update existing payment details
        // We need to modify the CompanyService.createQrcode method to handle partial updates
        result = await companyService.createQrcode(
            docid,
            image ?? File(""), // Handle case when image hasn't changed
            fileName,
            upiCntrl.text,
            oldName,
            acNoCntrl.text,
            ifscCntrl.text);
      }

      setState(() {
        isLoad = false;
      });

      if (result == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Payment Details Successfully ${isAddMode ? 'Added' : 'Updated'}...')));
        if (isAddMode) {
          // After successful add, switch to update mode and refresh data
          setState(() {
            isAddMode = false;
          });
          getUpiDtails();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something went wrong!')));
      }
    } catch (e) {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
