import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'photo_capture_controller.dart';
import '../../widgets/glassmorphism_card.dart';

class PhotoCaptureView extends GetView<PhotoCaptureController> {
  const PhotoCaptureView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Capture Photo'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000814), Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (!controller.isCameraInitialized.value && controller.capturedImagePath.value.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GlassmorphismCard(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 350,
                      width: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFFD700), width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: controller.capturedImagePath.value.isNotEmpty
                            ? Image.file(
                                File(controller.capturedImagePath.value),
                                fit: BoxFit.cover,
                              )
                            : CameraPreview(controller.cameraController!),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (controller.capturedImagePath.value.isEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (controller.availableCams.length > 1)
                            IconButton(
                              icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                              onPressed: controller.toggleCamera,
                            ),
                          if (controller.availableCams.length > 1)
                            const SizedBox(width: 20),
                          ElevatedButton.icon(
                            onPressed: controller.capturePhoto,
                            icon: const Icon(Icons.camera),
                            label: const Text('TAKE PHOTO'),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: controller.retakePhoto,
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('RETAKE', style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: controller.submitData,
                            icon: const Icon(Icons.check),
                            label: const Text('SUBMIT'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
  }
}
