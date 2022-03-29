import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Helper {
  static Future<List<Subtitle>> getSubtitle(String vttData) async {
    var controller = SubtitleController(
      provider: SubtitleProvider.fromString(
        data: vttData,
        type: SubtitleType.vtt,
      ),
    );
    await controller.initial();
    final subtitles = controller.subtitles;

    printResult(subtitles);
    return subtitles;
  }

  static void printResult(List<Subtitle> subtitles) {
    // subtitles.sort((s1, s2) => s1.compareTo(s2));
    for (var result in subtitles) {
      print(
        '(${result.index}) Start: ${result.start}, end: ${result.end} [${result.data}]',
      );
    }
  }

  static convertToPdf(
      {required String text,
      required String title,
      required String audioUrl}) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.poppinsRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
            ),
          ),
          child: pw.Text(
            'decifer',
            style: pw.Theme.of(context).defaultTextStyle.copyWith(
                  color: PdfColors.grey,
                  font: font,
                ),
          ),
        ),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                    color: PdfColors.grey,
                    font: font,
                  ),
            ),
          );
        },
        build: (pw.Context context) {
          List<String> paragraphedText = text.split('\n\n');

          return <pw.Widget>[
            pw.Header(
              level: 0,
              title: title,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    textScaleFactor: 2,
                    style: pw.TextStyle(
                      font: font,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                    child: pw.UrlLink(
                      child: pw.Text(
                        'Click here to get the audio file',
                        textScaleFactor: 1,
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          font: font,
                        ),
                      ),
                      destination: audioUrl,
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < paragraphedText.length; i++)
              pw.Paragraph(
                text: paragraphedText[i],
                style: pw.TextStyle(
                  font: font,
                  fontSize: 16,
                ),
              )
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${title.toLowerCase().replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<Uint8List> getPdf({
    required String text,
    required String title,
    required String audioUrl,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.poppinsRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
            ),
          ),
          child: pw.Text(
            'decifer',
            style: pw.Theme.of(context).defaultTextStyle.copyWith(
                  color: PdfColors.grey,
                  font: font,
                ),
          ),
        ),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                    color: PdfColors.grey,
                    font: font,
                  ),
            ),
          );
        },
        build: (pw.Context context) {
          List<String> paragraphedText = text.split('\n\n');

          return <pw.Widget>[
            pw.Header(
              level: 0,
              title: title,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    textScaleFactor: 2,
                    style: pw.TextStyle(
                      font: font,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                    child: pw.UrlLink(
                      child: pw.Text(
                        'Click here to get the audio file',
                        textScaleFactor: 1,
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          font: font,
                        ),
                      ),
                      destination: audioUrl,
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < paragraphedText.length; i++)
              pw.Paragraph(
                text: paragraphedText[i],
                style: pw.TextStyle(
                  font: font,
                  fontSize: 16,
                ),
              )
          ];
        },
      ),
    );

    return await pdf.save();
  }
}
