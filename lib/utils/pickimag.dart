import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

class PlagiaModel {
  final ImagePicker _picker = ImagePicker();

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    // Process the image
    await _processImage(image);
  }

  Future<void> _processImage(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    print("Recognized text: $text");

    // Process blocks of recognized text
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final String text = block.text;
      // final List<String> languages = block.recognizedLanguages;

      // Display the recognized text
      print("Block text: $text");

      // Display the bounding box
      print("Bounding Box: ${rect.toString()}");

      // Check if cornerPoints is available and print them
      final List<Offset> cornerPoints = block.cornerPoints
          .map((point) => Offset(point.x as double, point.y as double))
          .toList();
      print("Corner Points: $cornerPoints");
    }

    textRecognizer.close();
  }
}
