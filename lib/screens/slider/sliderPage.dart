import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'aboutUs/addDetails.dart';
import 'banner/bannerScreen.dart';
import 'events/eventScreen.dart';
import 'jewelleryAdvertisment/addAdvertisement.dart';
import 'termsAndCondition/showTermsAndCond.dart';
import 'refundPolicy/showRefundPolicy.dart';
import 'aboutUs/showAboutUs.dart';
import 'brochure/showBrochure.dart';

class Sliderpage extends StatefulWidget {
  const Sliderpage({super.key});

  @override
  State<Sliderpage> createState() => _SliderpageState();
}

class _SliderpageState extends State<Sliderpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 229, 229, 229),
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text("Sliders"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /// First Row (Banner & T&C)
            Row(
              children: [
                Expanded(
                  child: _buildContainer(
                    icon: FontAwesomeIcons.noteSticky,
                    label: "Banner",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BannerScreen()));
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildContainer(
                    icon: FontAwesomeIcons.fileContract,
                    label: "T & C",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TermsAndCondition()));
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            /// Second Row (Refund Policy & About Us)
            Row(
              children: [
                Expanded(
                  child: _buildContainer(
                    icon: FontAwesomeIcons.moneyBillWave,
                    label: "Offers",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Showrefundpolicy()));
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildContainer(
                    icon: FontAwesomeIcons.infoCircle,
                    label: "About Us",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Adddetails()));
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            /// Third Row (Brochure)
            Row(
              children: [
                Expanded(
                  child: _buildContainer(
                    icon: FontAwesomeIcons.book,
                    label: "Brochure",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Showbrochure()));
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: _buildContainer(
                        icon: FontAwesomeIcons.gem,
                        label: "Jewellery Advertisement",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Addadvertisement()));
                        }))
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildContainer(
                    icon: Icons.event,
                    label: "Events",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventScreen()));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Container Widget
  Widget _buildContainer(
      {required IconData icon,
      required String label,
      required Function() onTap}) {
    return Container(
      height: 150,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: FaIcon(icon, size: 25, color: useColor.homeIconColor),
            onPressed: onTap,
          ),
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
