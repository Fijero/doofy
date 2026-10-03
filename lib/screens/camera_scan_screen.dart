import 'package:doofy/screens/manual_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? controller;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();

    controller = CameraController(cameras.first, ResolutionPreset.high);

    await controller!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Ingredient Label")),

      body: CameraPreview(controller!),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: captureImage,
      ),
    );
  }

  // Future<void> captureImage() async {
  //   final image = await controller!.takePicture();
  //   print(image.path);
  // }

  Future<void> captureImage() async {
    if (_busy) return;
    setState(() => _busy = true);

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final image = await controller!.takePicture();
      final result = await recognizer.processImage(
        InputImage.fromFilePath(image.path),
      );

      if (!mounted) return;

      if (result.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text found. Try again with better light.'),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManualInputScreen(initialText: result.text),
        ),
      );
    } catch (e) {
      debugPrint('Scan failed: $e');
    } finally {
      await recognizer.close();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }
}
