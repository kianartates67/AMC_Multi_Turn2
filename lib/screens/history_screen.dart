import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../models/ai_persona.dart';
import '../services/chat_storage_service.dart';
import '../widgets/history_item.dart';

class HistoryScreen extends StatefulWidget {
  final List<AiPersona> personas;

  const HistoryScreen({required this.personas});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ChatStorageService _storageService = ChatStorageService();
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final sessions = await _storageService.loadAllChats();
    sessions.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  AiPersona _getPersonaByType(String type) {
    return widget.personas.firstWhere((p) => p.name == type);
  }

  Future<void> _deleteSession(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Chat?'),
        content: Text('This conversation will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteChat(id);
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No history found', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView.builder(
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            final session = _sessions[index];
            final persona = _getPersonaByType(session.personaType);
            return HistoryItem(
              session: session,
              persona: persona,
              onDelete: () => _deleteSession(session.id),
            );
          },
        ),
      ),
    );
  }
}
