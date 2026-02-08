import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_session.dart';
import '../models/ai_persona.dart';
import '../screens/chat_screen.dart';

class HistoryItem extends StatelessWidget {
  final ChatSession session;
  final AiPersona persona;
  final VoidCallback onDelete;

  const HistoryItem({
    required this.session,
    required this.persona,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = session.messages.isNotEmpty ? session.messages.last.text : "No messages yet";
    final timeStr = DateFormat('MMM dd, HH:mm').format(session.lastUpdatedAt);

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => onDelete(),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  persona: persona,
                  chatId: session.id,
                  existingMessages: session.messages,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: persona.color.withOpacity(0.2),
            child: Icon(persona.icon, color: persona.color),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(persona.name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13),
          ),
          trailing: Icon(Icons.chevron_right, size: 20),
        ),
      ),
    );
  }
}
