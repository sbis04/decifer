import 'package:subtitle/subtitle.dart';

class Helper {
  static Future<List<Subtitle>> getSubtitle(String vttData) async {
    var controller = SubtitleController(
      provider: SubtitleProvider.fromString(
        data: vttData,
        type: SubtitleType.vtt,
      ),
    );
    await controller.initial();
    final subtitles = controller.subtitles;

    // printResult(subtitles);
    return subtitles;
  }

  static void printResult(List<Subtitle> subtitles) {
    // subtitles.sort((s1, s2) => s1.compareTo(s2));
    for (var result in subtitles) {
      print(
        '(${result.index}) Start: ${result.start}, end: ${result.end} [${result.data}]',
      );
    }
  }
}
