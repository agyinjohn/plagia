import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PickUploadReadPdf extends StatefulWidget {
  const PickUploadReadPdf({super.key});

  @override
  _PickUploadReadPdfState createState() => _PickUploadReadPdfState();
}

class _PickUploadReadPdfState extends State<PickUploadReadPdf> {
  String? filePath;
  String? pdfContent;

  Future<void> pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        filePath = result.files.single.path;
      });
      String? downloadURL = await uploadPdfToFirebase(filePath!);
      if (downloadURL != null) {
        String fileName = filePath!.split('/').last;
        await savePdfMetadata(downloadURL, fileName);
        pdfContent = await readPdf(filePath!);
        setState(() {});
      }
    } else {
      // User canceled the picker
    }
  }

  Future<String?> uploadPdfToFirebase(String filePath) async {
    try {
      File file = File(filePath);
      String fileName = file.path.split('/').last;

      Reference storageReference =
          FirebaseStorage.instance.ref().child('pdfs/$fileName');

      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading PDF: $e");
      return null;
    }
  }

  Future<void> savePdfMetadata(String downloadURL, String fileName) async {
    CollectionReference pdfs = FirebaseFirestore.instance.collection('pdfs');

    await pdfs.add({
      'url': downloadURL,
      'fileName': fileName,
      'uploadedAt': Timestamp.now(),
    });
  }

  Future<String> readPdf(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final pdfDocument = PdfDocument(inputBytes: bytes);
    final allText = PdfTextExtractor(pdfDocument).extractText();
    return allText ?? 'No text found in PDF';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick, Upload, and Read PDF'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickPdf,
              child: const Text('Pick PDF'),
            ),
            const SizedBox(height: 20),
            filePath != null ? Text('Picked file: $filePath') : Container(),
            const SizedBox(height: 20),
            pdfContent != null
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          pdfContent!,
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 18),
                        )),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
