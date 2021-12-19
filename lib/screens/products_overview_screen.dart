import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../providers/project.dart';
import '../providers/product.dart';
import '../widgets/products_list.dart';
import 'project_settings_screen.dart';
import 'view_pdf_screen.dart';

class ProductsOverviewScreen extends StatelessWidget {
  Future<void> _saveAsPdfAndViewIt(BuildContext context) async {
    // first step - creating the sample pdf
    final pdf = pw.Document();
    final bgImage = (await rootBundle.load('assets/images/bg_image.jpg'))
        .buffer
        .asUint8List();
    final pages = await _generatePages(context);
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: const PdfPageFormat(1280, 720),
          buildBackground: (ctx) => pw.Image(
            pw.MemoryImage(bgImage),
            fit: pw.BoxFit.cover,
          ),
        ),
        build: (ctx) => pages,
      ),
    );
    // second step - saving the pdf in the storage
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    // last step - showing the pdf
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ViewPdfScreen(pdf),
      ),
    );
  }

  Future<List<pw.Widget>> _generatePages(BuildContext context) async {
    final List<pw.Widget> result = [];
    List<pw.Widget> details = [];
    final Project project = Provider.of<Project>(context, listen: false);
    final List<Product> products = project.products;
    final keys = project.properties;
    // calculating count of lines in description(+1 is for the first line which doesn't have \n in it)
    final int _linesCount = '\n'.allMatches(project.description).length + 1;
    // first for loop is for each page(product)
    for (int i = 0; i < products.length; i++) {
      result.add(pw.NewPage());
      final mainImage = await _provideMainImage(products[i]);
      final alterImages = await _provideAlterImages(products[i]);
      // generating each property text
      for (int j = 0; j < keys.length; j++) {
        details
            .add(_showText('${keys[j]}: ${products[i].properties[keys[j]]}'));
      }
      details.add(_showText('Price: ${products[i].price}'));
      // generating the page's stack
      result.add(
        pw.SizedBox(
          width: 1280,
          height: 720,
          child: pw.Stack(
            alignment: pw.Alignment.center,
            children: [
              // details box
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(50),
                  decoration: const pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.only(
                          bottomRight: pw.Radius.circular(50)),
                      boxShadow: [
                        pw.BoxShadow(
                          blurRadius: 20,
                          spreadRadius: 20,
                          color: PdfColor(0, 0, 0, 0.5),
                        ),
                      ],
                      gradient: pw.LinearGradient(
                        colors: [
                          PdfColor(0.8, 0, 0),
                          PdfColor(0.5, 0, 0),
                        ],
                      )),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: details,
                  ),
                ),
              ),
              // ------------
              // main image
              pw.Positioned(
                child: pw.ClipRRect(
                  horizontalRadius: 50,
                  verticalRadius: 50,
                  child: pw.Image(mainImage),
                ),
              ),
              // ------------
              // alter images
              pw.Positioned(
                right: 80,
                child: pw.ListView.builder(
                  itemCount: alterImages.length,
                  itemBuilder: (ctx, i) => pw.SizedBox(
                    width: 170,
                    height: 170,
                    child: pw.ClipRRect(
                      horizontalRadius: 50,
                      verticalRadius: 50,
                      child: pw.Image(alterImages[i], fit: pw.BoxFit.cover),
                    ),
                  ),
                ),
              ),
              // -------------
              // logo and description
              pw.Positioned(
                left: 100,
                // calculations to move logo based on details box height
                bottom: 120 -
                    (_linesCount * 20.0) +
                    ((5 - project.properties.length) * 40.0),
                child: pw.Column(children: [
                  pw.SizedBox(
                    width: 180,
                    child: project.logoImage.path != ''
                        ? pw.Image(pw.MemoryImage(
                            (await rootBundle.load(project.logoImage.path))
                                .buffer
                                .asUint8List()))
                        : null,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    project.description,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
      details = [];
    }
    return result;
  }

  pw.Widget _showText(String text) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(left: 0, top: 0), // for later usages maybe
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 30,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor(1, 1, 1),
        ),
      ),
    );
  }

  Future<pw.ImageProvider> _provideMainImage(Product product) async {
    return pw.MemoryImage((await rootBundle.load(product.mainImg.path == ''
            ? 'assets/images/empty.jpg'
            : product.mainImg.path))
        .buffer
        .asUint8List());
  }

  Future<List<pw.ImageProvider>> _provideAlterImages(Product product) async {
    List<pw.ImageProvider> result = [];
    for (File alterImage in product.alterImages) {
      result.add(pw.MemoryImage(
          (await rootBundle.load(alterImage.path)).buffer.asUint8List()));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final project = Provider.of<Project>(context);
    return WillPopScope(
      // this 'onWillPop' is meant to rebuild the projects list to update the thumbs
      onWillPop: () async {
        project.changeThumbs();
        // 'true' means we can go back and 'false' means do not go back
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(DateFormat.yMd().format(project.creationDate)),
          actions: [
            IconButton(
              onPressed: () => _saveAsPdfAndViewIt(context),
              icon: const Icon(Icons.picture_as_pdf),
            ),
            IconButton(
              onPressed: () {
                project.addEmptyProduct(project.properties);
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => ChangeNotifierProvider.value(
                          value: project,
                          child: const ProjectSettingsScreen(),
                        )));
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: ProductsList(project),
      ),
    );
  }
}
