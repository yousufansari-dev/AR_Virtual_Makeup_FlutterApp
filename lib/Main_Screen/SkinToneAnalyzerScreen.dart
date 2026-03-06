import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class SkinToneAnalyzerScreen extends StatefulWidget {
  final String userId;

  const SkinToneAnalyzerScreen({super.key, required this.userId});

  @override
  State<SkinToneAnalyzerScreen> createState() => _SkinToneAnalyzerScreenState();
}

class _SkinToneAnalyzerScreenState extends State<SkinToneAnalyzerScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  Color _avgColor = Colors.grey;

  // Face region overlay
  Rect? _faceRegion;

  // Cloudinary config
  final String cloudName = "dqyfeznaf";
  final String uploadPreset = "Virtual_Makeup_App";

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      _showSnack('Camera permission is required!');
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showSnack('No cameras available!');
        return;
      }
    } catch (e) {
      _showSnack('Error fetching cameras: $e');
      return;
    }

    CameraDescription selected = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
      _startImageStream();
    } catch (e) {
      _showSnack('Camera initialization failed: $e');
    }
  }

  void _startImageStream() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((CameraImage image) {
      _analyzeFrame(image);
    });

    setState(() {});
  }

  void _analyzeFrame(CameraImage cameraImage) {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      int width = cameraImage.width;
      int height = cameraImage.height;

      // Central square region for skin analysis
      int regionSize = (min(width, height) * 0.3).toInt();
      int startX = (width / 2 - regionSize / 2).toInt();
      int startY = (height / 2 - regionSize / 2).toInt();

      final Uint8List yBytes = cameraImage.planes[0].bytes;
      final Uint8List uBytes = cameraImage.planes[1].bytes;
      final Uint8List vBytes = cameraImage.planes[2].bytes;

      int uvRowStride = cameraImage.planes[1].bytesPerRow;
      int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

      int totalR = 0, totalG = 0, totalB = 0;
      int count = 0;

      for (int y = 0; y < regionSize; y += 2) {
        for (int x = 0; x < regionSize; x += 2) {
          int px = startX + x;
          int py = startY + y;

          int yIndex = py * cameraImage.planes[0].bytesPerRow + px;
          int uvX = (px / 2).toInt();
          int uvY = (py / 2).toInt();
          int uIndex = uvY * uvRowStride + uvX * uvPixelStride;
          int vIndex =
              uvY * cameraImage.planes[2].bytesPerRow + uvX * uvPixelStride;

          int Y = yBytes[yIndex];
          int U = uBytes[uIndex];
          int V = vBytes[vIndex];

          double yf = Y.toDouble();
          double uf = U.toDouble() - 128.0;
          double vf = V.toDouble() - 128.0;

          int r = (yf + 1.402 * vf).round().clamp(0, 255);
          int g = (yf - 0.344136 * uf - 0.714136 * vf).round().clamp(0, 255);
          int b = (yf + 1.772 * uf).round().clamp(0, 255);

          totalR += r;
          totalG += g;
          totalB += b;
          count++;
        }
      }

      int avgR = (totalR / count).round();
      int avgG = (totalG / count).round();
      int avgB = (totalB / count).round();

      // Update overlay and color
      setState(() {
        _avgColor = Color.fromARGB(255, avgR, avgG, avgB);
        _faceRegion = Rect.fromLTWH(
          startX.toDouble(),
          startY.toDouble(),
          regionSize.toDouble(),
          regionSize.toDouble(),
        );
      });
    } catch (e) {
      // ignore
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        _isProcessing = false;
      });
    }
  }

  String getSkinToneRecommendation(Color color) {
    int r = color.red;
    int g = color.green;
    int b = color.blue;

    double brightness = (r * 0.299 + g * 0.587 + b * 0.114);

    if (brightness > 200) return 'Fair Skin: Try warm/nude shades';
    if (brightness > 150) return 'Medium Skin: Try peach/pink shades';
    if (brightness > 100) return 'Olive Skin: Try neutral shades';
    return 'Dark Skin: Try deep shades';
  }

  Future<void> _captureAndUpload() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile file = await _controller!.takePicture();
      final File saved = File(file.path);

      final bytes = await saved.readAsBytes();
      img.Image? original = img.decodeImage(bytes);
      if (original == null) return;

      img.Image resized = img.copyResize(original, width: 1024);
      final jpg = img.encodeJpg(resized, quality: 85);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(jpg);

      final url = await _uploadToCloudinary(tempFile);
      _showSnack(url != null ? 'Upload Success: $url' : 'Upload Failed');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      return jsonResp['secure_url'];
    }
    return null;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller != null && _controller!.value.isInitialized;

    return Scaffold(
      appBar: AppBar(title: const Text('Skin Tone Analyzer')),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: isReady
                ? Stack(
                    children: [
                      CameraPreview(_controller!),
                      if (_faceRegion != null)
                        Positioned(
                          left: _faceRegion!.left,
                          top: _faceRegion!.top,
                          child: Container(
                            width: _faceRegion!.width,
                            height: _faceRegion!.height,
                            decoration: BoxDecoration(
                              color: _avgColor.withOpacity(0.4),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Column(
                          children: [
                            Container(width: 50, height: 50, color: _avgColor),
                            const SizedBox(height: 8),
                            Text(
                              getSkinToneRecommendation(_avgColor),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _captureAndUpload,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Capture & Upload'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
