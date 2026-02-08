import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyAbGw0XLEQjNek-8ATvmAikLIZxJFNpyJw';
  
  // Using v1beta as it often has better support for system instructions in some regions/keys
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static List<Map<String, dynamic>> _formatMessages(List<ChatMessage> messages) {
    return messages.map((msg) {
      List<Map<String, dynamic>> parts = [{'text': msg.text}];
      
      if (msg.imageBytes != null) {
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Encode(msg.imageBytes!),
          }
        });
      }

      return {
        'role': msg.role,
        'parts': parts,
      };
    }).toList();
  }

  static Future<String> sendMultiTurnMessage(
    List<ChatMessage> conversationHistory, {
    required String systemInstruction,
  }) async {
    try {
      final formattedMessages = _formatMessages(conversationHistory);

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': formattedMessages,
          // FIXED: Changed 'systemInstruction' to 'system_instruction' (snake_case)
          'system_instruction': {
            'parts': [{'text': systemInstruction}]
          },
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        return 'Error: ${response.statusCode} - ${errorData['error']?['message'] ?? response.body}';
      }
    } catch (e) {
      return 'Network Error: $e';
    }
  }
}
