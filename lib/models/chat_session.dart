import 'chat_message.dart';

class ChatSession {
  final String id;
  final String personaType;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  ChatSession({
    required this.id,
    required this.personaType,
    required this.messages,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaType': personaType,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      personaType: json['personaType'],
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
    );
  }

  ChatSession copyWith({
    List<ChatMessage>? messages,
    DateTime? lastUpdatedAt,
  }) {
    return ChatSession(
      id: this.id,
      personaType: this.personaType,
      messages: messages ?? this.messages,
      createdAt: this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
