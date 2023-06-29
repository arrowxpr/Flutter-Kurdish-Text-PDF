import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //Create an instance of ScreenshotController
  final screenshotController = ScreenshotController();

  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 400,
              width: 400,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: Screenshot(
                controller: screenshotController,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text('Hello World'),
                      Text('سڵاو لە جیهان'),
                      Text('تاقیکردنەوەی سکرینشۆت لەگەڵ پڵەگینی پرێنت'),
                      Spacer(),
                      Row(
                        children: [
                          Text('> See my other works on: \n'
                              'https://github.com/arrowxpr'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            if (!showLoading)
              ElevatedButton(
                  onPressed: () => startScreenshot(),
                  child: const Text('Generate PDF'))
            else
              const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }

  void startScreenshot() {
    setState(() => showLoading = true);
    // increase pixelRatio for better quality.
    screenshotController.capture(pixelRatio: 6).then((imageData) {
      if (kDebugMode) print('Captured');
      if (imageData == null) {
        if (kDebugMode) print('Something unexpected happened');
        return;
      }
      // generate pdf with the captured image.
      generatePDF(imageData!);
    }).catchError((onError) {
      if (kDebugMode) print(onError);
    });
  }

  void generatePDF(Uint8List imageData) {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a5,
        build: (_) => pw.Image(pw.MemoryImage(imageData)),
      ),
    );

    final pdfWidget = PdfPreview(
      dpi: 300,
      scrollViewDecoration: const BoxDecoration(),
      loadingWidget: const CircularProgressIndicator(),
      build: (PdfPageFormat format) => doc.save(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(appBar: AppBar(), body: pdfWidget)),
    );
    setState(() => showLoading = false);
  }
}
