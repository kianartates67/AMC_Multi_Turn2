import 'dart:convert';
import 'dart:typed_data';

class ChatMessage {
  final String text;
  final String role; // "user" or "model"
  final DateTime timestamp;
  final Uint8List? imageBytes; // For Image Integration

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.imageBytes,
  });

  bool get isUserMessage => role == "user";

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      role: json['role'],
      timestamp: DateTime.parse(json['timestamp']),
      imageBytes: json['imageBytes'] != null ? base64Decode(json['imageBytes']) : null,
    );
  }
}
