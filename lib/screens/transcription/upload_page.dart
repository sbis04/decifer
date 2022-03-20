import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/screens/transcription/transcription_page.dart';
import 'package:deepgram_transcribe/utils/helper.dart';
import 'package:deepgram_transcribe/utils/storage_client.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:subtitle/subtitle.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isChoosing = false;

  Future<PlatformFile?> pickFile() async {
    setState(() {
      _isChoosing = true;
    });

    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'wma', 'aac', 'm4a', 'flac'],
    );

    // setState(() {
    //   _isChoosing = false;
    // });

    if (file != null) {
      log('${file.files.single.name}');
      return file.files.single;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: const IconThemeData(
          color: CustomColors.black,
        ),
        title: const Text(
          'decifer',
          style: TextStyle(
            color: CustomColors.black,
            fontSize: 26,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 56.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(),
            FaIcon(
              FontAwesomeIcons.fileAudio,
              size: 100,
              color: CustomColors.black.withOpacity(0.5),
            ),
            const SizedBox(height: 32),
            _isChoosing
                ? SizedBox(
                    height: 60,
                    width: double.maxFinite,
                    child: WaveVisualizer(
                      columnHeight: 50,
                      columnWidth: 10,
                    ),
                  )
                : SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: CustomColors.black,
                        onSurface: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      onPressed: () async {
                        final file = await pickFile();
                        if (file != null && file.path != null) {
                          final List<Subtitle> subtitles =
                              await showModalBottomSheet(
                            isDismissible: false,
                            context: context,
                            builder: (context) {
                              return BottomSheetWidget(
                                file: file,
                              );
                            },
                          );

                          log('Received transcripts!');

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => TranscriptionPage(
                                subtitles: subtitles,
                                audioFile: file,
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            _isChoosing = false;
                          });
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Upload File',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    Key? key,
    required this.file,
  }) : super(key: key);

  final PlatformFile file;

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late final StorageClient _storageClient;
  late final FirebaseFunctions _functions;
  late final PlatformFile _file;

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
    final downloadUrl = await _storageClient.uploadRecording(
      fileName: _file.name,
      audioFile: File(_file.path!),
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
      text = 'Generated successfully';
      icon = const Icon(
        Icons.check,
        color: Colors.black54,
        size: 36,
      );
    });

    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pop(subtitles);
  }

  @override
  void initState() {
    _storageClient = StorageClient();
    _file = widget.file;
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
