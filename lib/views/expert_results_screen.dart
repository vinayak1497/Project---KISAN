import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ExpertHelpScreen extends StatefulWidget {
  const ExpertHelpScreen({super.key});

  @override
  State<ExpertHelpScreen> createState() => _ExpertHelpScreenState();
}

class _ExpertHelpScreenState extends State<ExpertHelpScreen> {
  final TextEditingController _descController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _selectedProblem = "Water";
  Position? _location;
  bool _isLoading = false;
  List<Map<String, String>> _results = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() => _location = pos);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) {
        setState(() {
          _descController.text = val.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _submit() async {
    if (_descController.text.isEmpty || _location == null) return;

    setState(() {
      _isLoading = true;
      _results.clear();
    });

    final prompt = '''
You are a government assistant. A farmer has asked for help:

Problem Type: $_selectedProblem  
Description: ${_descController.text}  
Location: Latitude ${_location!.latitude}, Longitude ${_location!.longitude}  

Suggest 3 expert services (NGOs, local businesses, government helplines, etc.) nearby that can help. Give output only in this exact format:

1. Name: ...
   Description: ...
   Contact: ...
   Google Maps: ...

2. Name: ...
   Description: ...
   Contact: ...
   Google Maps: ...

3. Name: ...
   Description: ...
   Contact: ...
   Google Maps: ...
''';

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent'),
        headers: {
          'Authorization':
              'Bearer AIzaSyCzNfaMSGCvoCVjrFdUo2fAV8yXNK9WK-g',
          'Content-Type': 'application/json',
        },
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

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

      final List<Map<String, String>> results = [];
      final matches = text.split(RegExp(r'\n\s*\d+\.\s+Name:'));

      for (var m in matches) {
        if (m.trim().isEmpty) continue;

        final entry = "Name:" + m.trim(); // Fix start
        final lines = entry.split('\n');
        final map = <String, String>{};

        for (final line in lines) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            final key = parts[0].trim().toLowerCase();
            final value = parts.sublist(1).join(':').trim();
            if (key == 'name') map['name'] = value;
            if (key == 'description') map['desc'] = value;
            if (key == 'contact') map['contact'] = value;
            if (key == 'google maps') map['map'] = value;
          }
        }

        if (map.containsKey('name') && map.containsKey('map')) {
          results.add(map);
        }
      }

      setState(() => _results = results);
    } catch (e) {
      print("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Help"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButtonFormField<String>(
            value: _selectedProblem,
            decoration: const InputDecoration(labelText: "Select Problem Type"),
            items: [
              "Water",
              "Electrical",
              "Crop Disease",
              "Land Docs",
              "Govt Docs"
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedProblem = val!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: "Describe your problem",
              suffixIcon: IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: const Icon(Icons.search),
            label: const Text("Find Experts"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(
                        child: Text("No services found. Try again."),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final r = _results[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r['name'] ?? "",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(r['desc'] ?? "",
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Text("Contact: ${r['contact'] ?? ''}",
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () async {
                                      final uri =
                                          Uri.tryParse(r['map'] ?? '');
                                      if (uri != null &&
                                          await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                            mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    child: const Text("View on Map →"),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
          ),
        ]),
      ),
    );
  }
}
  