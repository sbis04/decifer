import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/utils/helper.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtitle/subtitle.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({
    Key? key,
    required this.subtitles,
    required this.docId,
    this.audioFile,
    this.audioUrl,
  }) : super(key: key);

  final List<Subtitle> subtitles;
  final File? audioFile;
  final String? audioUrl;
  final String docId;

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  // late final String _entireString;
  late final List<Subtitle> _subtitles;
  late List<TextSpan> _subtitleTextSpan;
  late final AudioPlayer _audioPlayer;

  late final File? _audioFile;
  late final String? _audioUrl;

  late final TextEditingController _titleController;
  late final FocusNode _titleFocusNode;

  Duration? _totalDuration;
  Duration? _currentDuration;
  double _fraction = 0.0;

  bool _isLoading = false;

  PlayerState _playerState = PlayerState.COMPLETED;

  startAudioPlayback() async {
    if (_audioFile == null) {
      setState(() {
        _isLoading = true;
      });
      await _audioPlayer.play(
        _audioUrl!,
        isLocal: false,
        stayAwake: true,
      );
    } else {
      await _audioPlayer.play(
        _audioFile!.path,
        isLocal: true,
        stayAwake: true,
      );
    }
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    _titleFocusNode = FocusNode();
    _subtitles = widget.subtitles;
    Helper.printResult(_subtitles);
    _audioFile = widget.audioFile;
    _audioUrl = widget.audioUrl;
    _audioPlayer = AudioPlayer();
    _audioPlayer.onAudioPositionChanged.listen((Duration d) {
      log('Current duration: $d');
      _currentDuration = d;

      if (_currentDuration == const Duration(seconds: 0)) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }

      _subtitleTextSpan = generateTextSpans(_subtitles, currentDuration: d);

      if (_totalDuration != null) {
        _fraction = d.inSeconds / _totalDuration!.inSeconds;
      }
      if (mounted) {
        setState(() {});
      }
    });
    _audioPlayer.onDurationChanged.listen((Duration d) {
      log('Max duration: $d');
      if (mounted) {
        setState(() {
          _totalDuration = d;
        });
      }
    });
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      log('Current player state: $s');

      if (mounted) {
        setState(() {
          _playerState = s;
        });
      }
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
    return GestureDetector(
      onTap: () {
        _titleFocusNode.unfocus();
      },
      child: Scaffold(
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
          actions: const [
            TitleSavingIndicator(),
          ],
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
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        fontSize: 20,
                        color: CustomColors.black.withOpacity(0.8),
                      ),
                      cursorColor: CustomColors.black,
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black,
                            width: 3,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: CustomColors.black.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: CustomColors.black.withOpacity(0.5),
                        ),
                        hintText: 'Title',
                      ),
                      // onChanged: (value) => widget.onChange(value),
                    ),
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
                        _isLoading
                            ? Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black54,
                                    ),
                                  ),
                                  // child: Icon(
                                  //   Icons.play_arrow_rounded,
                                  //   size: 40,
                                  //   color: Colors.white,
                                  // ),
                                ),
                              )
                            : _playerState == PlayerState.COMPLETED ||
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
      ),
    );
  }
}

class TitleSavingIndicator extends StatelessWidget {
  const TitleSavingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                CustomColors.black,
              ),
              strokeWidth: 2,
            ),
          ),
        ),
      ],
    );
  }
}
