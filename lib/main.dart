// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() => runApp(const MyApp());

bool isStillExtractingImage = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: MyButton(),
        ),
      ),
    );
  }
}

class MyButton extends StatefulWidget {
  const MyButton({super.key});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  String extractedText = '';
  String firstNumberAsString = '';
  bool isTextExtracted = false;

  Future<void> _getImageAndExtractText() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    setState(() {
      isStillExtractingImage = true;
    });
    final image = File(pickedFile.path);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(image.path);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      extractedText = recognizedText.text;
      isTextExtracted = true;

      isStillExtractingImage = false;
      firstNumberAsString = _extractFirstNumber(recognizedText.blocks.first);
    });
  }

  String _extractFirstNumber(TextBlock textBlock) {
    String text = textBlock.text;
    RegExp regExp = RegExp(r'\d+');
    Iterable<RegExpMatch> matches = regExp.allMatches(text);
    String firstNumber = matches.first.group(0)!;
    return firstNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConditionalBuilder(
            condition: !isStillExtractingImage,
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  _getImageAndExtractText().then(
                    (value) => _showMyDialog(
                        firstNumber: firstNumberAsString, context: context),
                  );
                },
                child: const Text('Open Camera'),
              );
            },
            fallback: (context) => Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 20),
          Visibility(
            visible: isTextExtracted,
            child: Text('Extracted Text is :'),
          ),
          const SizedBox(height: 20),
          Text(extractedText),
        ],
      ),
    );
  }
}

Future _showMyDialog({
  required String firstNumber,
  context,
}) =>
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('The biggest Number is '),
          content: Text(firstNumber),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
