import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';

import '../core/gemini_service.dart';
import '../models/chat_message.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final GeminiService _gemini = GeminiService();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _controller.clear();
    });

    final reply = await _gemini.getGeminiReply(text);
    setState(() {
      _messages.insert(0, ChatMessage(text: reply, isUser: false));
    });

    _speak(reply);
  }

  void _startListening() async {
    if (!isListening) {
      final available = await _speech.initialize();
      if (available) {
        setState(() => isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Ask Kisan AI'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Card(
                    color: msg.isUser
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        msg.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isListening)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Lottie.asset(
                'assets/lottie/voice_wave.json',
                height: 80,
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    color: isListening ? Colors.red : Colors.black54,
                  ),
                  onPressed: _startListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
