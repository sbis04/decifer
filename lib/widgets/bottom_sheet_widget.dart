import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../res/custom_colors.dart';
import '../utils/database_client.dart';
import '../utils/helper.dart';
import '../utils/storage_client.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    Key? key,
    required this.file,
  }) : super(key: key);

  final File file;

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late final DatabaseClient _databaseClient;
  late final StorageClient _storageClient;
  late final FirebaseFunctions _functions;
  late final File _file;
  late final String _fileName;

  String text = '';
  Widget icon = const CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(
      Colors.black54,
    ),
  );

  generateTranscript() async {
    setState(() {
      text = 'Uploading...';
    });

    final isPresent = await _databaseClient.isAlreadyPresent(
      audioName: _fileName,
    );

    if (isPresent) {
      setState(() {
        text = 'Already present, retrieving...';
      });

      final subtitles = await _databaseClient.retrieveSubtitles(
        audioName: _fileName,
      );

      setState(() {
        text = 'Retrieved successfully';
        icon = const Icon(
          Icons.check,
          color: Colors.black54,
          size: 36,
        );
      });

      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pop(subtitles);

      return;
    }

    final downloadUrl = await _storageClient.uploadRecording(
      fileName: _fileName,
      audioFile: File(_file.path),
    );
    log('URL: $downloadUrl');
    setState(() {
      text = 'Generating transcripts...';
    });

    final callable = _functions.httpsCallable('getTranscription');
    final resp = await callable.call(<String, dynamic>{
      'url': downloadUrl,
    });

    // debugPrint("result: ${resp.data}");

    final String data = resp.data;
    final subtitles = await Helper.getSubtitle(data);

    setState(() {
      text = 'Saving...';
      icon = const Icon(
        Icons.save,
        color: Colors.black54,
        size: 36,
      );
    });

    final docId = await _databaseClient.addTranscript(
      subtitles: subtitles,
      audioUrl: downloadUrl!,
      audioName: _fileName,
    );

    setState(() {
      text = 'Generated successfully';
      icon = const Icon(
        Icons.check,
        color: Colors.black54,
        size: 36,
      );
    });

    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pop(Tuple3(subtitles, docId, downloadUrl));
  }

  @override
  void initState() {
    _storageClient = StorageClient();
    _databaseClient = DatabaseClient();
    _file = widget.file;
    _fileName = _file.path.split('/').last.trim();
    _functions = FirebaseFunctions.instance;
    generateTranscript();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.red.shade600,
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Please do not close the app.',
                  style: TextStyle(
                    fontSize: 14,
                    // fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: CustomColors.green,
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.black,
                  ),
                ),
                icon,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
