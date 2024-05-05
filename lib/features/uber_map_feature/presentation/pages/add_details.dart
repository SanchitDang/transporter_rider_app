import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transporter_rider_app/config/constants.dart';
import 'package:transporter_rider_app/features/uber_map_feature/presentation/getx/details_controller.dart';

import '../getx/trip_controller.dart';

class AddDetailsPage extends StatefulWidget {
  const AddDetailsPage({Key? key}) : super(key: key);

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  @override
  Widget build(BuildContext context) {
    DetailsController controller = Get.find();
    TripController tc = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Good Details"),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.goodsList.length,
                  itemBuilder: (context, index) {
                    final dimensionController = controller.goodsList[index]
                        ['dimension'] as TextEditingController?;
                    final weightController = controller.goodsList[index]
                        ['weight'] as TextEditingController?;
                    final imageFilePath =
                        controller.goodsList[index]['imageFilePath'].value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                          child: Row(
                            children: [
                              Text("Good: ${index + 1}", style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                              const Spacer(),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Adjust the value as needed
                                      ),
                                    )),
                                onPressed: () async {
                                  await controller.pickImage(index);
                                  setState(() {});
                                },
                                child: const Text('Add Image', style: TextStyle(
                                     fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Builder(
                            builder: (BuildContext context) {
                              final file = File(imageFilePath);
                              if (file.existsSync()) {
                                return Image.file(
                                  file,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const Text(
                                  'No image selected',
                                  style: TextStyle(
                                      color:
                                          Colors.red), // Adjust styling as needed
                                );
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: TextField(
                            onChanged: (val) {},
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Good Dimensions",
                            ),
                            controller: dimensionController,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: TextField(
                            onChanged: (val) {},
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Good Weight",
                            ),
                            controller: weightController,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(primaryColor),
                        elevation: MaterialStateProperty.all(0.0),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(10)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Adjust the value as needed
                          ),
                        )),
                    onPressed: () {

                        controller.addGood();
                        Get.snackbar("Awesome!", "Good Added.");

                    },
                    child: const Text('Add Good'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(primaryColor),
                        elevation: MaterialStateProperty.all(0.0),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(10)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Adjust the value as needed
                          ),
                        )),
                    onPressed: () {
                      controller.done();
                      setState(() {});
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
