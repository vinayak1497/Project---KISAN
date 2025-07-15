import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = "AIzaSyCzNfaMSGCvoCVjrFdUo2fAV8yXNK9WK-g"; // 🔐 Replace this

  Future<String> getGeminiReply(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['candidates'][0]['content']['parts'][0]['text'];
    } else {
      return '⚠️ Something went wrong. Try again.';
    }
  }
}
