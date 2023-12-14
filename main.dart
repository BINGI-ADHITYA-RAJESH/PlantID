import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PlantIdentificationPage(),
    );
  }
}

class PlantIdentificationPage extends StatefulWidget {
  const PlantIdentificationPage({super.key});

  @override
  PlantIdentificationPageState createState() => PlantIdentificationPageState();
}

class PlantIdentificationPageState extends State<PlantIdentificationPage> {
  final String apiKey = 'ZOxBs2mM47Kw1l97rPZvbuTaS2TyeeFrUt9Rq65RM9quxRpOqS';
  late CameraController _cameraController;
  // ignore: avoid_init_to_null
   XFile? _capturedImage;
  PlantsAPI plantsAPI = PlantsAPI();

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
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
    if (!_cameraController.value.isInitialized) {
      return;
    }

    final XFile file = await _cameraController.takePicture();

  final imageBytes = File(file.path).readAsBytesSync();
  final image = img.decodeImage(Uint8List.fromList(imageBytes));

  
  if (image == null) {
    // Handle the case where image decoding fails
    return;
  }

  final base64Image = base64Encode(image as List<int>);

  List<Plant> identifiedPlants = await plantsAPI.identifyPlant(base64Image);

    setState(() {
      _capturedImage = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Identification'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: takePicture,
                child: const Text('Take Picture for Plant Identification'),
              ),
              if (_capturedImage != null)
                Image.file(File(_capturedImage!.path)),
            ],
          ),
        ),
      ),
    );
  }
}

class Plant {
  final int id;
  final double probability;
  final String plantName;
  final String imagePath;

  Plant({
    required this.id,
    required this.probability,
    required this.plantName,
    required this.imagePath,
  });
}


class PlantsAPI {
  final String _endpoint = 'https://api.plant.id/v3';
  
  get plantUrl => null;

  Future<List<Plant> >identifyPlant(String base64Image) async {
    
    List<String> images = [];
    List<Plant> plants = [];

    images.add(base64Image);
    Map<String, dynamic> body = {'images': images};
    try {
      var apiKey = 'ZOxBs2mM47Kw1l97rPZvbuTaS2TyeeFrUt9Rq65RM9quxRpOqS';
      http.Response response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Accept': '*/*',
          'Access-Control-Allow-Origin': '*',
          'Api-Key': apiKey,
        },
        body: jsonEncode(body),
      );
      Map<String, dynamic> results =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (results['is_plant']) {
        List<dynamic> suggesstions = results['suggestions'];
        for (var suggesstion in suggesstions) {
          Map<String, dynamic> plant = suggesstion as Map<String, dynamic>;
          String name = plant['plant_name'] as String;
          plants.add(Plant(
              id: plant['id'] as int,
              probability: (plant['probability'] as double) * 100,
              plantName: name,
              imagePath: plantUrl));
        }

        return plants;
      } else {
        return plants;
      }
    } catch (e) {
      return plants;
    }
  }
}
