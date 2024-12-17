import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seed_detector/models/model.dart';
import 'package:seed_detector/screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ModelController mdl = Get.put(ModelController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Seed detection",
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: "/home",
          page: () => const HomeScreen(),
        ),
      ],
      initialRoute: "/home",
    );
  }
}
