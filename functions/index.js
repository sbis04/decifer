const functions = require("firebase-functions");
const {Deepgram} = require("@deepgram/sdk");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.getTranscription = functions.https.onCall(async (data, context) => {
  try {
    const deepgram = new Deepgram(process.env.DEEPGRAM_API_KEY);
    const audioSource = {
      url: data.url,
    };

    const response = await deepgram.transcription.preRecorded(audioSource, {
      punctuate: true,
      utterances: true,
      // other options are available
    });

    const webvttTranscript = response.toWebVTT();

    return webvttTranscript;
  } catch (error) {
    console.error(`Unable to transcribe. Error ${error}`);
    throw new functions.https.HttpsError("aborted", "Could not transcribe");
  }
});
