// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test/web_scraping.dart';
import 'package:test/models.dart';


class APIIntegration {
  final String apiKey =
      'ZOxBs2mM47Kw1l97rPZvbuTaS2TyeeFrUt9Rq65RM9quxRpOqS'; // Replace with your Plant.id API key

  Future<List<Plant>?> identifyPlant(String base64Image) async {
    final webScraping = WebScraping();
    const apiUrl = 'https://api.plant.id/v2/identify';
    final headers = {
      'Accept': '*/*',
      'Access-Control-Allow-Origin': '*',
      'Api-Key': apiKey,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode({
          'images': [base64Image]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        if (jsonResponse['is_plant']) {
          final suggestions = jsonResponse['suggestions'];
          final identifiedPlants = <Plant>[];
          for (var suggestion in suggestions) {
            Map<String, dynamic> plant = suggestion as Map<String, dynamic>;
            String name = plant['plant_name'] as String;
            String plantUrl = await webScraping.getImageFromWeb(name);
            identifiedPlants.add(Plant(
              id: plant['id'] as int,
              probability: (plant['probability'] as double) * 100,
              plantName: name,
              imagePath: plantUrl,
            ));
          }
          return identifiedPlants;
        } else {
          return [];
        }
      } else {
        print('API request failed with status code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
    
  }
}
