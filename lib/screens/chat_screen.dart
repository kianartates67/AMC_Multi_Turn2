import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_persona.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';
import '../services/chat_storage_service.dart';

class ChatScreen extends StatefulWidget {
  final AiPersona persona;
  final String? chatId;
  final List<ChatMessage> existingMessages;

  const ChatScreen({
    required this.persona,
    this.chatId,
    this.existingMessages = const [],
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String _currentChatId;
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  final ChatStorageService _storageService = ChatStorageService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    messages.addAll(widget.existingMessages);
    _currentChatId = widget.chatId ?? 'chat_${widget.persona.name}_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}';
    if (messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void addMessage(String text, String role, {Uint8List? imageBytes}) {
    setState(() {
      messages.add(ChatMessage(
        text: text,
        role: role,
        timestamp: DateTime.now(),
        imageBytes: imageBytes,
      ));
    });
    scrollToBottom();
    _saveChatSession();
  }

  Future<void> _saveChatSession() async {
    final session = ChatSession(
      id: _currentChatId,
      personaType: widget.persona.name,
      messages: messages,
      createdAt: widget.existingMessages.isEmpty && messages.length <= 2 
          ? DateTime.now() 
          : (await _storageService.loadChatById(_currentChatId))?.createdAt ?? DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
    await _storageService.saveChat(session);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> handleSend(String text, {Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && imageBytes == null) return;

    addMessage(text, "user", imageBytes: imageBytes);
    setState(() => _isLoading = true);

    try {
      final aiResponse = await GeminiService.sendMultiTurnMessage(
        messages,
        systemInstruction: widget.persona.systemInstruction,
      );
      addMessage(aiResponse, "model");
    } catch (e) {
      addMessage('❌ Error: $e', "model");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      handleSend("Analyze this image", imageBytes: bytes);
    }
  }

  void _exportChat() {
    String chatText = messages.map((m) => "${m.role == 'user' ? 'You' : widget.persona.name}: ${m.text}").join("\n\n");
    Share.share(chatText, subject: 'Chat History with ${widget.persona.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.persona.icon, color: Colors.white),
            SizedBox(width: 8),
            Text(widget.persona.name, style: TextStyle(fontSize: 18)),
          ],
        ),
        backgroundColor: widget.persona.color,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _exportChat,
            tooltip: 'Export Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.persona.icon, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text('Start chatting with ${widget.persona.name}!', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Text(
                      widget.persona.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: messages[index]);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: widget.persona.color),
                  ),
                  SizedBox(width: 12),
                  Text('🤖 ${widget.persona.name} is thinking...', style: TextStyle(fontStyle: FontStyle.italic, color: widget.persona.color.withOpacity(0.9))),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.image, color: widget.persona.color),
                onPressed: _pickImage,
              ),
              Expanded(
                child: InputBar(onSendMessage: (text) => handleSend(text), accentColor: widget.persona.color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
