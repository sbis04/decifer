const functions = require("firebase-functions");
const {Deepgram} = require("@deepgram/sdk");

exports.getTranscription = functions.https.onCall(async (data, context) => {
  try {
    const deepgram = new Deepgram(process.env.DEEPGRAM_API_KEY);
    const audioSource = {
      url: data.url,
    };

    const response = await deepgram.transcription.preRecorded(audioSource, {
      punctuate: true,
      utterances: true,
    });

    console.log(response.results.utterances.length);

    const confidenceList = [];
    for (let i =0; i < response.results.utterances.length; i++) {
      confidenceList.push(response.results.utterances[i].confidence);
    }

    const webvttTranscript = response.toWebVTT();

    const finalTranscript = {
      transcript: webvttTranscript,
      confidences: confidenceList,
    };

    const finalTranscriptJSON = JSON.stringify(finalTranscript);
    console.log(finalTranscriptJSON);

    return finalTranscriptJSON;
  } catch (error) {
    console.error(`Unable to transcribe. Error ${error}`);
    throw new functions.https.HttpsError("aborted", "Could not transcribe");
  }
});
