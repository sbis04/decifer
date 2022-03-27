import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:deepgram_transcribe/screens/authentication/login_page.dart';
import 'package:deepgram_transcribe/screens/transcription/record_page.dart';
import 'package:deepgram_transcribe/screens/transcription/upload_page.dart';
import 'package:deepgram_transcribe/utils/authentication_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtitle/subtitle.dart';

import '../utils/database_client.dart';
import '../widgets/transcribe_tile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? _user;
  late final AuthenticationClient _authClient;
  late final DatabaseClient _databaseClient;

  bool _isLongPressed = false;
  int? _longPressedIndex;

  @override
  void initState() {
    _user = FirebaseAuth.instance.currentUser;
    _authClient = AuthenticationClient();
    _databaseClient = DatabaseClient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log('onPressDismissed');
        setState(() {
          _isLongPressed = false;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 4,
          backgroundColor: Colors.white,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          title: const Text(
            'decifer',
            style: TextStyle(
              color: CustomColors.black,
              fontSize: 26,
            ),
          ),
          actions: [
            _user == null
                ? Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        foregroundColor: MaterialStateProperty.all(
                            CustomColors.black.withOpacity(0.7)),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextButton(
                      onPressed: () async {
                        await _authClient.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        foregroundColor: MaterialStateProperty.all(
                            Colors.red.withOpacity(0.8)),
                      ),
                      child: const Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
          ],
          bottom: PreferredSize(
            preferredSize: Size(double.maxFinite, 80),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RecordPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black26,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.mic,
                                  // size: 30,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Record',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UploadPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: CustomColors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white24,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.upload_rounded,
                                  // size: 30,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Upload',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(),
                const SizedBox(height: 24),
                const Text(
                  'Transcriptions',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CustomColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _databaseClient.retrieveTranscripts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final queryData = snapshot.data!;
                      final transcriptDocs = queryData.docs;

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transcriptDocs.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          final transcriptDoc = transcriptDocs.elementAt(index);
                          final transcriptData = transcriptDoc.data();
                          final docId = transcriptDoc.id;

                          final List<Map<String, dynamic>> rawSubtitles =
                              List<Map<String, dynamic>>.from(
                                  transcriptData['subtitles']);

                          final String audioUrl = transcriptData['url'];
                          final String title = transcriptData['title'];

                          List<Subtitle> subtitles = [];
                          String transcriptString = '';

                          rawSubtitles.asMap().forEach((subIndex, rawSubtitle) {
                            String dataString = rawSubtitle['data'];
                            final subtitle = Subtitle(
                              start:
                                  Duration(milliseconds: rawSubtitle['start']),
                              end: Duration(milliseconds: rawSubtitle['end']),
                              data: dataString,
                              index: rawSubtitle['index'],
                            );

                            if (subIndex == 0) {
                              transcriptString += dataString.substring(2);
                            } else {
                              transcriptString += dataString.substring(1);
                            }

                            subtitles.add(subtitle);
                          });

                          return TranscribeTile(
                            databaseClient: _databaseClient,
                            subtitles: subtitles,
                            audioUrl: audioUrl,
                            docId: docId,
                            title: title,
                            transcriptString: transcriptString,
                            index: index,
                            isLongPressed: _longPressedIndex == index
                                ? _isLongPressed
                                : false,
                            onLongPressed: (value) {
                              log('isLongPressed: $value');
                              setState(() {
                                _isLongPressed = value;
                                _longPressedIndex = index;
                              });
                            },
                          );
                        },
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
