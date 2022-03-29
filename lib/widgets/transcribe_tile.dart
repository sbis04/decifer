import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';

import '../res/custom_colors.dart';
import '../screens/transcription/transcription_page.dart';
import '../utils/database_client.dart';

class TranscribeTile extends StatelessWidget {
  const TranscribeTile({
    Key? key,
    required this.databaseClient,
    required this.subtitles,
    required this.audioUrl,
    required this.docId,
    required this.title,
    required this.transcriptString,
    required this.index,
    required this.isLongPressed,
    required this.onLongPressed,
    required this.confidences,
  }) : super(key: key);

  final DatabaseClient databaseClient;
  final List<Subtitle> subtitles;
  final String audioUrl;
  final String docId;
  final String title;
  final String transcriptString;
  final int index;
  final bool isLongPressed;
  final Function(bool) onLongPressed;
  final List<double> confidences;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: isLongPressed
              ? const EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                  bottom: 8.0,
                )
              : const EdgeInsets.only(),
          child: ElevatedButton(
            onLongPress: () => onLongPressed(!isLongPressed),
            onPressed: () {
              onLongPressed(false);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TranscriptionPage(
                    subtitles: subtitles,
                    audioUrl: audioUrl,
                    docId: docId,
                    title: title,
                    confidences: confidences,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.grey,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(
                width: 2.0,
                color: isLongPressed ? Colors.red.shade600 : CustomColors.black,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(),
                  title.isEmpty
                      ? const SizedBox()
                      : Text(
                          title,
                          style: const TextStyle(
                            color: CustomColors.black,
                            fontSize: 18,
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    transcriptString,
                    maxLines: title.isEmpty ? 4 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColors.black.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        isLongPressed
            ? InkWell(
                onTap: () async {
                  await databaseClient.deleteTranscribe(docId: docId);
                  onLongPressed(false);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
