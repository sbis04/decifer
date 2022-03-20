import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
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
  late List<TextSpan> _subtitleTextSpan;
  late final PlatformFile _audioFile;
  late final AudioPlayer _audioPlayer;

  Duration? _totalDuration;
  Duration? _currentDuration;
  double _fraction = 0.0;

  PlayerState _playerState = PlayerState.COMPLETED;

  startAudioPlayback() async {
    final something = await _audioPlayer.play(
      _audioFile.path!,
      isLocal: true,
      stayAwake: true,
    );

    log('Status code: $something');
  }

  @override
  void initState() {
    _subtitles = widget.subtitles;
    _audioFile = widget.audioFile;
    _audioPlayer = AudioPlayer();
    _audioPlayer.onAudioPositionChanged.listen((Duration d) {
      log('Current duration: $d');
      _currentDuration = d;

      _subtitleTextSpan = generateTextSpans(_subtitles, currentDuration: d);

      if (_totalDuration != null) {
        _fraction = d.inSeconds / _totalDuration!.inSeconds;
      }
      setState(() {});
    });
    _audioPlayer.onDurationChanged.listen((Duration d) {
      log('Max duration: $d');
      setState(() {
        _totalDuration = d;
      });
    });
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      log('Current player state: $s');

      setState(() {
        _playerState = s;
      });
    });

    _subtitleTextSpan = generateTextSpans(_subtitles);

    super.initState();
  }

  generateTextSpans(
    List<Subtitle> subtitles, {
    Duration? currentDuration,
  }) {
    return List.generate(subtitles.length, (index) {
      final startDuration = subtitles[index].start;
      final endDuration = subtitles[index].end;

      bool shouldHighlight = false;

      if (currentDuration != null) {
        if (currentDuration.compareTo(startDuration) >= 0 &&
            currentDuration.compareTo(endDuration) <= 0) {
          shouldHighlight = true;
        }
      }

      log('HIGHLIGHT: $shouldHighlight');

      if (index == 0) {
        return TextSpan(
          text: subtitles[index].data.substring(2),
          style: shouldHighlight
              ? const TextStyle(
                  color: CustomColors.black,
                )
              : null,
        );
      } else {
        return TextSpan(
          text: subtitles[index].data.substring(1),
          style: shouldHighlight
              ? const TextStyle(
                  color: CustomColors.black,
                )
              : null,
        );
      }
    }).toList();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
                      style: TextStyle(
                        fontSize: 18,
                        color: _playerState == PlayerState.PLAYING
                            ? CustomColors.black.withOpacity(0.2)
                            : CustomColors.black,
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
                          isPaused: _playerState == PlayerState.PLAYING
                              ? false
                              : true,
                          widthFactor: _fraction,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _playerState == PlayerState.COMPLETED ||
                              _playerState == PlayerState.STOPPED
                          ? InkWell(
                              onTap: () async {
                                await startAudioPlayback();
                              },
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
                          : _playerState == PlayerState.PAUSED
                              ? InkWell(
                                  onTap: () async {
                                    await _audioPlayer.resume();
                                  },
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
                              : InkWell(
                                  onTap: () async {
                                    await _audioPlayer.pause();
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.pause_outlined,
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
