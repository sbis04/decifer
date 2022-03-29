import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:printing/printing.dart';

import '../utils/helper.dart';

class SharePDFButton extends StatelessWidget {
  const SharePDFButton({
    Key? key,
    required String singleText,
    required TextEditingController titleController,
    required String audioUrl,
  })  : _singleText = singleText,
        _titleController = titleController,
        _audioUrl = audioUrl,
        super(key: key);

  final String _singleText;
  final TextEditingController _titleController;
  final String _audioUrl;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final pdfBytes = await Helper.getPdf(
          text: _singleText,
          title: _titleController.text,
          audioUrl: _audioUrl,
        );

        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: PdfPreview(
                    onPrinted: (_) => Navigator.of(context).pop(),
                    pdfFileName:
                        '${_titleController.text.toLowerCase().replaceAll(' ', '_')}.pdf',
                    scrollViewDecoration: const BoxDecoration(),
                    previewPageMargin: const EdgeInsets.only(),
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    allowPrinting: true,
                    build: (format) => pdfBytes,
                  ),
                ),
              ),
            );
          },
        );
      },
      icon: const FaIcon(
        FontAwesomeIcons.share,
        color: Colors.white,
      ),
    );
  }
}
