import 'package:camera/camera.dart';
import 'package:get/get.dart';

class PhotoCaptureController extends GetxController {
  CameraController? cameraController;
  List<CameraDescription> availableCams = [];
  int currentCameraIndex = 0;
  final isCameraInitialized = false.obs;
  final capturedImagePath = ''.obs;

  late Map<String, dynamic> previousArgs;

  @override
  void onInit() {
    super.onInit();
    previousArgs = Get.arguments ?? {};
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      availableCams = await availableCameras();
      if (availableCams.isEmpty) {
        Get.snackbar('Error', 'No cameras available');
        return;
      }
      
      // Use front camera if available, else back
      currentCameraIndex = availableCams.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (currentCameraIndex == -1) currentCameraIndex = 0;
      
      await _setCamera(availableCams[currentCameraIndex]);
    } catch (e) {
      Get.snackbar('Camera Error', e.toString());
    }
  }

  Future<void> _setCamera(CameraDescription camera) async {
    isCameraInitialized.value = false;
    cameraController?.dispose();
    cameraController = CameraController(camera, ResolutionPreset.medium);
    await cameraController!.initialize();
    isCameraInitialized.value = true;
  }

  void toggleCamera() {
    if (availableCams.length < 2) return;
    currentCameraIndex = (currentCameraIndex + 1) % availableCams.length;
    _setCamera(availableCams[currentCameraIndex]);
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    
    try {
      final image = await cameraController!.takePicture();
      capturedImagePath.value = image.path;
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture photo: $e');
    }
  }

  void retakePhoto() {
    capturedImagePath.value = '';
  }

  void submitData() {
    if (capturedImagePath.value.isEmpty) {
      Get.snackbar('Required', 'Please capture a photo before submitting.');
      return;
    }

    previousArgs['photoPath'] = capturedImagePath.value;
    Get.offNamed('/submit-success', arguments: previousArgs);
  }
}
