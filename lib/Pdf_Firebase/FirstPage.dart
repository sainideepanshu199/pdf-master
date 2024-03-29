// ignore_for_file: prefer_const_constructors

// import 'dart:ffi';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
// import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> pdfData = [];
  Future<String> uploadPdf(String fileName, File file) async {
    final reference =
        FirebaseStorage.instance.ref().child('pdfs/$fileName.pdf');
    final UploadTask = reference.putFile(file);
    await UploadTask.whenComplete(() {});
    final downloadLink = await reference.getDownloadURL();
    return downloadLink;
  }

  void pickFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;
      File file = File(pickedFile.files[0].path!);
      final downloadLink = await uploadPdf(fileName, file);
      await _firebaseFirestore.collection('pdfs').add({
        "name": fileName,
        "url": downloadLink,
      });
      print("Pdf uploaded Sucessfully");
    }
  }

  void getAllPdf() async {
    final results = await _firebaseFirestore.collection("pdfs").get();
    pdfData = results.docs.map((e) => e.data()).toList();
    setState(() {});
  }

  @override
  //screen ke start hote hi function call hojayega
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pdfs'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickFile();
          print("hello");
        },
        // ignore: sort_child_properties_last
        child: const Icon(
          Icons.upload_file,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
      body: GridView.builder(
          itemCount: pdfData.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          PdfViewerScreen(pdfUrl: pdfData[index]['url'])));
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/pdf.png',
                        height: 100,
                        width: 80,
                      ),
                      Text(
                        pdfData[index]['name'],
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PDFDocument? document;

  void initializePdf() async {
    document = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializePdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: document != null
            ? PDFViewer(
                document: document!,
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
