import 'dart:developer';
import 'dart:io';

import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/screens/transcription/transcription_page.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:subtitle/subtitle.dart';
import 'package:tuple/tuple.dart';

import '../../widgets/bottom_sheet_widget.dart';

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
      type: FileType.audio,
      // allowedExtensions: ['mp3', 'wav', 'wma', 'aac', 'm4a', 'flac'],
    );

    // setState(() {
    //   _isChoosing = false;
    // });

    if (file != null) {
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
                      isPaused: false,
                      isBarVisible: false,
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
                        final pickedFile = await pickFile();

                        if (pickedFile != null && pickedFile.path != null) {
                          final file = File(pickedFile.path!);

                          final Tuple2<List<Subtitle>, String> result =
                              await showModalBottomSheet(
                            isDismissible: false,
                            context: context,
                            builder: (context) {
                              return BottomSheetWidget(
                                file: file,
                              );
                            },
                          );

                          final subtitles = result.item1;
                          final docId = result.item2;

                          log('Received transcripts!');

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => TranscriptionPage(
                                subtitles: subtitles,
                                audioFile: file,
                                docId: docId,
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
