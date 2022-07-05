import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/utils/database_client.dart';
import 'package:deepgram_transcribe/utils/helper.dart';
import 'package:deepgram_transcribe/widgets/wave_visualizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtitle/subtitle.dart';

import '../../widgets/share_pdf_button.dart';
import '../../widgets/title_saving_indicator.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({
    Key? key,
    required this.subtitles,
    required this.docId,
    required this.audioUrl,
    required this.confidences,
    this.audioFile,
    this.title,
  }) : super(key: key);

  final List<Subtitle> subtitles;
  final File? audioFile;
  final String audioUrl;
  final String docId;
  final String? title;
  final List<double> confidences;

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  late final DatabaseClient _databaseClient;
  // late final String _entireString;
  late final List<Subtitle> _subtitles;
  late List<TextSpan> _subtitleTextSpan;
  late final String _docId;
  late final AudioPlayer _audioPlayer;

  late final File? _audioFile;
  late final String _audioUrl;
  late final List<double> _confidences;

  late final TextEditingController _titleController;
  late final FocusNode _titleFocusNode;

  Duration? _totalDuration;
  String? _totalDurationString;
  Duration? _currentDuration;
  String? _currentDurationString;
  double _fraction = 0.0;

  bool _isLoading = false;
  bool _isTitleStoring = false;
  bool _isConfidenceMapVisible = false;
  String _singleText = '';

  PlayerState _playerState = PlayerState.COMPLETED;

  String _getDurationString(Duration d) {
    final paddedString = d.toString().split('.').first.padLeft(8, "0");
    final finalString = paddedString.split(':').first == '00'
        ? paddedString.substring(3)
        : paddedString;
    return finalString;
  }

  startAudioPlayback() async {
    if (_audioFile == null) {
      setState(() {
        _isLoading = true;
      });
      await _audioPlayer.play(
        _audioUrl,
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

  _storeTitle() async {
    if (mounted) {
      setState(() {
        _isTitleStoring = true;
      });
    }

    await _databaseClient.storeTitle(
      docId: _docId,
      title: _titleController.text,
    );

    if (mounted) {
      setState(() {
        _isTitleStoring = false;
      });
    }
  }

  @override
  void initState() {
    _databaseClient = DatabaseClient();
    _docId = widget.docId;
    _titleController = TextEditingController(text: widget.title);
    _titleFocusNode = FocusNode();
    _subtitles = widget.subtitles;
    Helper.printResult(_subtitles);
    _audioFile = widget.audioFile;
    _audioUrl = widget.audioUrl;
    _confidences = generateConfidenceMap(widget.confidences);
    if (kDebugMode) {
      print(_confidences);
    }
    _audioPlayer = AudioPlayer();
    _audioPlayer.onAudioPositionChanged.listen((Duration d) {
      log('Current duration: $d');
      _currentDuration = d;
      if (mounted) {
        setState(() {
          _currentDurationString = _getDurationString(d);
        });
      }

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
          _totalDurationString = _getDurationString(d);
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

    _subtitleTextSpan = generateTextSpans(_subtitles, isFirst: true);
    // _singleText +=
    //     _subtitleTextSpan.fold('', (prev, curr) => '$prev\n${curr.text!}');

    if (kDebugMode) {
      print(_singleText);
    }

    super.initState();
  }

  List<double> generateConfidenceMap(List<double> confidences) {
    final max =
        confidences.reduce((current, next) => current > next ? current : next);
    final min =
        confidences.reduce((current, next) => current < next ? current : next);

    const newMin = 0.2;
    const newMax = 1.0;

    return List.generate(confidences.length, (index) {
      final value =
          (newMax - newMin) / (max - min) * (confidences[index] - max) + newMax;
      // final value = (confidences[index] - min) / (max - min);
      return value;
    });
  }

  generateTextSpans(
    List<Subtitle> subtitles, {
    Duration? currentDuration,
    bool isFirst = false,
  }) {
    return List.generate(subtitles.length, (index) {
      final startDurationThis = subtitles[index].start;
      final endDurationThis = subtitles[index].end;

      bool shouldHighlight = false;
      bool isPara = false;

      if (currentDuration != null) {
        if (currentDuration.compareTo(startDurationThis) >= 0 &&
            currentDuration.compareTo(endDurationThis) <= 0) {
          shouldHighlight = true;
        }
      }

      if (index > 0) {
        final endDurationPrev = subtitles[index - 1].end;
        if ((startDurationThis.inMilliseconds -
                endDurationPrev.inMilliseconds) >
            900) {
          isPara = true;
        }
      }

      log('HIGHLIGHT: $shouldHighlight');

      if (index == 0) {
        final text = subtitles[index].data.substring(2);
        if (isFirst) _singleText += text;

        return TextSpan(
          text: text,
          style: shouldHighlight
              ? TextStyle(
                  color: _isConfidenceMapVisible
                      ? Colors.white
                      : CustomColors.black,
                  backgroundColor: _isConfidenceMapVisible
                      ? CustomColors.black.withOpacity(_confidences[index])
                      : Colors.transparent,
                )
              : TextStyle(
                  backgroundColor: _isConfidenceMapVisible
                      ? CustomColors.black.withOpacity(_confidences[index])
                      : Colors.transparent,
                ),
        );
      } else {
        final text = isPara
            ? '\n\n${subtitles[index].data.substring(2)}'
            : subtitles[index].data.substring(1);
        if (isFirst) _singleText += text;

        return TextSpan(
          text: text,
          style: shouldHighlight
              ? TextStyle(
                  color: _isConfidenceMapVisible
                      ? Colors.white
                      : CustomColors.black,
                  backgroundColor: _isConfidenceMapVisible
                      ? CustomColors.black.withOpacity(_confidences[index])
                      : Colors.transparent,
                )
              : TextStyle(
                  backgroundColor: _isConfidenceMapVisible
                      ? CustomColors.black.withOpacity(_confidences[index])
                      : Colors.transparent,
                ),
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
    return WillPopScope(
      onWillPop: () async {
        if (_titleFocusNode.hasFocus) {
          _titleFocusNode.unfocus();
          _storeTitle();
        }

        return true;
      },
      child: GestureDetector(
        onTap: () {
          if (_titleFocusNode.hasFocus) {
            _titleFocusNode.unfocus();
            _storeTitle();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: false,
            elevation: 4,
            backgroundColor: CustomColors.black,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            title: const Text(
              'decifer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
              ),
            ),
            actions: [
              _isTitleStoring ? const TitleSavingIndicator() : const SizedBox()
            ],
            bottom: PreferredSize(
              preferredSize: const Size(double.maxFinite, 60),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 3,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 2,
                            ),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          hintText: 'Title',
                        ),
                        onSubmitted: (_) {
                          log('Field submitted: ${_titleController.text}');
                          _storeTitle();
                        },
                        // onChanged: (value) => widget.onChange(value),
                      ),
                    ),
                    SharePDFButton(
                      singleText: _singleText,
                      titleController: _titleController,
                      audioUrl: _audioUrl,
                    )
                  ],
                ),
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
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: CustomColors.green,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: CustomColors.black,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Show confidence map',
                                style: TextStyle(
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _isConfidenceMapVisible,
                                onChanged: (value) {
                                  setState(() {
                                    _isConfidenceMapVisible =
                                        !_isConfidenceMapVisible;
                                    _subtitleTextSpan = generateTextSpans(
                                      _subtitles,
                                      isFirst: true,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: _playerState == PlayerState.PLAYING
                                ? CustomColors.black.withOpacity(0.2)
                                : _isConfidenceMapVisible
                                    ? Colors.white
                                    : CustomColors.black,
                          ),
                          children: _subtitleTextSpan,
                        ),
                      ),
                      SizedBox(
                        height: _totalDurationString == null ? 130 : 150,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CustomColors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: CustomColors.green,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Row(
                            children: [
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 14),
                                    children: [
                                      TextSpan(text: _currentDurationString),
                                      const TextSpan(text: ' / '),
                                      TextSpan(
                                        text: _totalDurationString,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: _totalDurationString == null ? 50 : 88,
                          width: double.maxFinite,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Container(
                    width: double.maxFinite,
                    height: 88,
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
      ),
    );
  }
}
