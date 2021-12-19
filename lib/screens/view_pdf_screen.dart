import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ViewPdfScreen extends StatelessWidget {
  pw.Document pdf;

  ViewPdfScreen(this.pdf);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF viewport'),
      ),
      body: PdfPreview(
        build: (format) => pdf.save(),
      ),
    );
  }
}
