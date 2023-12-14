// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

class WebScraping {
  Future<String> getHTMLDoc(String query) async {
    String result = '';
    String url = 'https://www.google.com/search?q=$query&source=lnms&tbm=isch';
    Map<String, String> headers = {
      'Accept': '*/*',
      'Access-Control-Allow-Origin': '*',
      'User-Agent':
          "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36"
    };

    try {
      print('sending request...');
      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      result = response.body;
    } catch (e) {
      print(e);
    }

    return result;
  }

  Future<String> getImageFromWeb(String query) async {
    String result = '';
    String html = await getHTMLDoc(query);
    BeautifulSoup bs = BeautifulSoup(html);
    String raw = bs.find('img', class_: 'yWs4tf').toString();
    result = raw.split('src="').last.split(';').first;
    print(result);

    return result;
  }
}


