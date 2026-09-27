import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? controller;

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

  Future<void> captureImage() async {
    final image = await controller!.takePicture();

    print(image.path);
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }
}
