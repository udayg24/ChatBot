import 'package:animate_do/animate_do.dart';
import 'package:chatbot/feature_box.dart';
import 'package:chatbot/openai_service.dart';
import 'package:chatbot/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = "";
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  void click() async {
    FocusScope.of(context).unfocus();
    final speech = await openAIService.isArtPromptAPI(controller.text);
    if (speech.contains('https')) {
      generatedImageUrl = speech;
      generatedContent = null;
      setState(() {});
    } else {
      generatedImageUrl = null;
      generatedContent = speech;
      setState(() {});
      systemSpeak(speech);
    }
    controller.clear();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text("Uday")),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    height: 125,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/virtualAssistant.png'))),
                  )
                ],
              ),
            ),
            // chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 40)
                        .copyWith(top: 30),
                    decoration: BoxDecoration(
                        border: Border.all(color: Pallete.borderColor),
                        borderRadius: BorderRadius.circular(20)
                            .copyWith(topLeft: Radius.zero)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        generatedContent == null
                            ? "Good Morning, what can I do for you?"
                            : generatedContent!,
                        style: TextStyle(
                            color: Pallete.mainFontColor,
                            fontSize: generatedContent == null ? 25 : 18,
                            fontFamily: 'Cera Pro'),
                      ),
                    )),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  child: Image.network(generatedImageUrl!),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text("Here are a few features",
                      style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: Pallete.mainFontColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            //features list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: "ChatGPT",
                      descriptionText:
                          "Smarter way of solving your doubts, use this for any task",
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: "Dall-E",
                      descriptionText:
                          "Create images by text, let your imagination run wild",
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: "Smart Voice Assistant",
                      descriptionText:
                          "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                    ),
                  ),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.message),
                        labelText: "Enter a prompt",
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 5, color: Colors.black)),
                        suffixIcon: IconButton(
                          onPressed: this.click,
                          icon: Icon(Icons.send),
                          splashColor: Colors.blue,
                          tooltip: "Submit",
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
