import 'package:flutter/material.dart';
import 'package:test/api_integration.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:test/web_scraping.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/models.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({Key? key}) : super(key: key);
  @override
  CaptureScreenState createState() => CaptureScreenState();
}

class CaptureScreenState extends State<CaptureScreen> {
  late CameraController _cameraController;
  final APIIntegration apiIntegration = APIIntegration();
  final WebScraping webScraping = WebScraping();

  bool isIdentifying = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(firstCamera, ResolutionPreset.high);
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (!_cameraController.value.isInitialized || isIdentifying) {
      return;
    }

    setState(() {
      isIdentifying = true;
    });
    _cameraController.setFlashMode(FlashMode.off);

    final XFile file = await _cameraController.takePicture();
    final imageBytes = File(file.path).readAsBytesSync();
    final imageBase64 = base64Encode(Uint8List.fromList(imageBytes));

    final List<Plant>? identifiedPlants = await apiIntegration.identifyPlant(imageBase64);

    Navigator.pushNamed(context, '/results', arguments: identifiedPlants);
    setState(() {
      isIdentifying = false; // Set isIdentifying to false after returning from ResultsScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Identification'),
        backgroundColor: const Color.fromARGB(255, 14, 106, 17),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/plant2.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        // ignore: sized_box_for_whitespace
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_cameraController.value.isInitialized)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 30.0 / 40.0,
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: takePicture,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 14, 106, 17),
                    padding: const EdgeInsets.all(16.0),
                  ),
                  child: const Text(
                    'Identify Plant',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                if (isIdentifying) const SizedBox(height: 16.0),
                if (isIdentifying) const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final identifiedPlants =
        ModalRoute.of(context)!.settings.arguments as List<Plant>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 93, 13),
        title: const Text('Plant Identification Results'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/plant3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (identifiedPlants.isEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    child: const Card(
                      elevation: 4.0,
                      color: Color.fromARGB(255, 237, 86, 86),
                      child: Padding(
                        padding:  EdgeInsets.all(16.0),
                        child:  Text(
                          'No plants identified.',
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                for (var plant in identifiedPlants)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.lightGreen,
                      elevation: 4.0,
                      child: Column(
                        children: [
                          const SizedBox(height: 8.0),
                          Text(
                            'Name: ${plant.plantName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Probability: ${plant.probability.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
