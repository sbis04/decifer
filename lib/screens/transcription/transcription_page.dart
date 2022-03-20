import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtitle/subtitle.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({
    Key? key,
    required this.subtitles,
    required this.audioFile,
  }) : super(key: key);

  final List<Subtitle> subtitles;
  final PlatformFile audioFile;

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  // late final String _entireString;
  late final List<Subtitle> _subtitles;
  late final List<TextSpan> _subtitleTextSpan;

  @override
  void initState() {
    _subtitles = widget.subtitles;

    _subtitleTextSpan = List.generate(_subtitles.length, (index) {
      if (index == 0) {
        return TextSpan(text: _subtitles[index].data.substring(2));
      } else {
        return TextSpan(text: _subtitles[index].data.substring(1));
      }
    }).toList();

    super.initState();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        color: CustomColors.black,
                      ),
                      children: _subtitleTextSpan,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                width: double.maxFinite,
                // height: 80,
                decoration: BoxDecoration(
                  color: CustomColors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: WaveVisualizer(
                          columnHeight: 50,
                          columnWidth: 10,
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
