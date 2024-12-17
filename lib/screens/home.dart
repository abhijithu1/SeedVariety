import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seed_detector/models/model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ModelController mdl = Get.find<ModelController>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Seedd"),
        ),
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Display
              Obx(() {
                return mdl.pickedImage.value != null
                    ? Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            mdl.pickedImage.value!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No Image Selected',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
              }),

              SizedBox(height: 20),

              // Prediction Result
              Obx(() {
                return mdl.predictionResult.value != null
                    ? Text(
                        mdl.predictionResult.value!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink();
              }),

              SizedBox(height: 20),

              // Upload Button
              IconButton(
                onPressed: () async {
                  mdl.showImagePickerDialog();
                },
                icon: const Icon(
                  Icons.upload,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
