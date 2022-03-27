import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/screens/transcription/transcription_page.dart';
import 'package:deepgram_transcribe/utils/database_client.dart';
import 'package:deepgram_transcribe/utils/helper.dart';
import 'package:deepgram_transcribe/utils/storage_client.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:record/record.dart';
import 'package:subtitle/subtitle.dart';
import 'package:tuple/tuple.dart';

import '../../widgets/bottom_sheet_widget.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late final Record _recorder;
  bool _isRecording = false;
  String? _filePath;

  _startRecording() async {
    bool hasPermission = await _recorder.hasPermission();

    if (hasPermission) {
      setState(() {
        _isRecording = true;
        _filePath = null;
      });

      await _recorder.start();
    }
  }

  _stopRecording() async {
    final path = await _recorder.stop();

    log('Recording complete, path: $path');

    if (path != null) {
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
    }
  }

  @override
  void initState() {
    _recorder = Record();
    super.initState();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
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
            _isRecording
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: SizedBox(
                      height: 60,
                      width: double.maxFinite,
                      child: WaveVisualizer(
                        columnHeight: 50,
                        columnWidth: 10,
                        isPaused: false,
                        isBarVisible: false,
                        color: Colors.red.shade600,
                      ),
                    ),
                  )
                : FaIcon(
                    FontAwesomeIcons.microphone,
                    size: 100,
                    color: Colors.red.shade600.withOpacity(0.5),
                  ),
            const SizedBox(height: 32),
            _isRecording
                ? SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.red.shade50,
                        onSurface: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                          side: BorderSide(
                            color: Colors.red.shade600,
                            width: 3,
                          ),
                        ),
                      ),
                      onPressed: _stopRecording,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 2.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.shade600,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: FaIcon(
                                  FontAwesomeIcons.stop,
                                  size: 24,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Stop Recording',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.red.shade600,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  )
                : _filePath != null
                    ? SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red.shade50,
                            onSurface: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                              side: BorderSide(
                                color: Colors.red.shade600,
                                width: 3,
                              ),
                            ),
                          ),
                          onPressed: _startRecording,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 2.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.shade600,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.microphone,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Record Again',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red.shade600,
                            onSurface: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                              side: BorderSide(
                                color: Colors.red.shade600,
                                width: 3,
                              ),
                            ),
                          ),
                          onPressed: _startRecording,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 2.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black26,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.microphone,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Start Recording',
                                  style: TextStyle(fontSize: 22),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
            _filePath != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: CustomColors.green,
                          onSurface: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final file = File(_filePath!);

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
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Generate Transcript',
                            style: TextStyle(
                              fontSize: 22,
                              color: CustomColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
