import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:deepgram_transcribe/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:subtitle/subtitle.dart';

import 'screens/authentication/login_page.dart';
import 'screens/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
      // home: const HomePage(),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginPage()
          : const DashboardPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String audioAsset = "assets/sample_audio.mp3";
  final functions = FirebaseFunctions.instance;
  String finalText = '';

  Future<dynamic> getAudioBytes() async {
    ByteData bytes = await rootBundle.load(audioAsset);
    return bytes;
  }

  Future<String> sendData() async {
    HttpsCallable callable = functions.httpsCallable('getTranscription');

    final resp = await callable();

    print("result: ${resp.data}");

    return resp.data;
  }

  Future<List<Subtitle>> getSubtitle(String vttData) async {
    var controller = SubtitleController(
      provider: SubtitleProvider.fromString(
        data: vttData,
        type: SubtitleType.vtt,
      ),
    );
    await controller.initial();
    final subtitles = controller.subtitles;

    printResult(subtitles);
    return subtitles;
  }

  void printResult(List<Subtitle> subtitles) {
    // subtitles.sort((s1, s2) => s1.compareTo(s2));
    for (var result in subtitles) {
      print(
        '(${result.index}) Start: ${result.start}, end: ${result.end} [${result.data}]',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(),
          ElevatedButton(
            onPressed: () async {
              final buffer = await getAudioBytes();
              final mime = lookupMimeType(audioAsset);

              log('BUFFER: ${buffer}');
              log('MIME: $mime');

              final data = await sendData();
              final subtitles = await getSubtitle(data);

              String parsedText = '';

              subtitles.forEach((element) {
                parsedText += element.data.substring(1);
              });
              print(parsedText);
              setState(() {
                finalText = parsedText;
              });
            },
            child: const Text('Get transcribe'),
          ),
          const SizedBox(height: 24),
          Text(finalText),
        ],
      ),
    );
  }
}
