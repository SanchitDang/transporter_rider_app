import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transporter_rider_app/features/uber_home_page_feature/presentation/getx/uber_home_controller.dart';

import '../../../../config/constants.dart';

uberHomeTopShareLocationCardWidget(UberHomeController uberHomeController) {
  return Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(15))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Want Better",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white),
            ),
            const Text(
              "Transport-Service ?",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 10,
            ),
            // GestureDetector(
            //   onTap: () {
                // // get current location
                //  uberHomeController.getUserCurrentLocation();
              // },
              // child:
              Row(
                children: const [
                  Text(
                    "Book Service    ",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  FaIcon(
                    FontAwesomeIcons.longArrowAltRight,
                    color: Colors.white,
                  )
                ],
              ),
            // ),
          ],
        ),
        const FaIcon(
          FontAwesomeIcons.binoculars,
          color: Color.fromRGBO(214, 84, 48, 0.85),
          size: 75,
        ),
      ],
    ),
  );
}
