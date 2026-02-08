import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';

class ChatStorageService {
  static const String _chatsKey = 'chats';

  Future<void> saveChat(ChatSession chat) async {
    final prefs = await SharedPreferences.getInstance();
    final allChats = await loadAllChats();
    final index = allChats.indexWhere((c) => c.id == chat.id);

    if (index != -1) {
      allChats[index] = chat;
    } else {
      allChats.add(chat);
    }

    final chatsJson = allChats.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_chatsKey, chatsJson);
  }

  Future<List<ChatSession>> loadAllChats() async {
    final prefs = await SharedPreferences.getInstance();
    final chatsJson = prefs.getStringList(_chatsKey) ?? [];
    return chatsJson
        .map((json) => ChatSession.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<ChatSession?> loadChatById(String id) async {
    final allChats = await loadAllChats();
    try {
      return allChats.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteChat(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final allChats = await loadAllChats();
    allChats.removeWhere((c) => c.id == id);

    final chatsJson = allChats.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_chatsKey, chatsJson);
  }

  Future<List<ChatSession>> getChatsForPersona(String personaType) async {
    final allChats = await loadAllChats();
    return allChats.where((c) => c.personaType == personaType).toList();
  }
}
