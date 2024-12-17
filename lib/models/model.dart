import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelController extends GetxController {
  // Reactive variable to store the picked image file
  Rx<File?> pickedImage = Rx<File?>(null);

  // ImagePicker instance
  final ImagePicker _picker = ImagePicker();

  // TFLite related variables
  Rx<String?> predictionResult = Rx<String?>(null);
  late Interpreter _interpreter;
  List<String> _labels = [];

  @override
  void onInit() {
    super.onInit();
    // Load the model and labels when the controller is initialized
    _loadModel();
    _loadLabels();
  }

  // Load TFLite model
  Future<void> _loadModel() async {
    try {
      // Make sure to place your .tflite file in assets/
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
    } catch (e) {
      print('Error loading model: $e');
      Get.snackbar('Error', 'Failed to load ML model');
    }
  }

  // Load labels from labels.txt
  Future<void> _loadLabels() async {
    try {
      // Make sure to place labels.txt in assets/
      final labelsText = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsText
          .trim()
          .split('\n')
          .map((label) => label.split(' ')[1])
          .toList();
    } catch (e) {
      print('Error loading labels: $e');
      Get.snackbar('Error', 'Failed to load labels');
    }
  }

  // Image preprocessing and classification
  Future<void> classifyImage() async {
    if (pickedImage.value == null) {
      Get.snackbar('Error', 'Please pick an image first');
      return;
    }

    try {
      // Read the image file
      img.Image? imageInput =
          img.decodeImage(pickedImage.value!.readAsBytesSync());

      // Resize image to match model's expected input size
      // Adjust these values based on your model's input size
      img.Image resizedImage =
          img.copyResize(imageInput!, width: 224, height: 224);

      // Normalize the image
      var inputImage = List.generate(
          1,
          (i) => List.generate(
              224,
              (j) => List.generate(
                  224,
                  (k) => [
                        resizedImage.getPixel(k, j).r / 255.0 - 0.5,
                        resizedImage.getPixel(k, j).g / 255.0 - 0.5,
                        resizedImage.getPixel(k, j).b / 255.0 - 0.5,
                      ])));

      // Output tensor
      var outputBuffer =
          List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      _interpreter.run(inputImage, outputBuffer);

      // Find the max probability
      double maxProb = -1;
      int maxIndex = -1;
      for (int i = 0; i < _labels.length; i++) {
        if (outputBuffer[0][i] > maxProb) {
          maxProb = outputBuffer[0][i];
          maxIndex = i;
        }
      }

      // Set the prediction result
      predictionResult.value = maxIndex != -1
          ? '${_labels[maxIndex]} (Confidence: ${(maxProb * 100).toStringAsFixed(2)}%)'
          : 'Unable to classify';
    } catch (e) {
      print('Classification error: $e');
      Get.snackbar('Error', 'Failed to classify image');
    }
  }

  // Function to pick an image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      // Pick image from camera or gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        // Optional parameters you can adjust
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85, // Compress image quality (0-100)
      );

      // Check if an image was picked
      if (pickedFile != null) {
        // Convert XFile to File and update the reactive variable
        pickedImage.value = File(pickedFile.path);
        classifyImage();
      } else {
        // Optional: Show a snackbar if no image was selected
        Get.snackbar(
          'Image Selection',
          'No image was selected',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Handle any errors during image picking
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Convenience method to show image selection bottom sheet
  void showImagePickerDialog() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () {
                Get.back(); // Close bottom sheet
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Get.back(); // Close bottom sheet
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // Optional: Method to clear the picked image
  void clearPickedImage() {
    pickedImage.value = null;
  }
}
