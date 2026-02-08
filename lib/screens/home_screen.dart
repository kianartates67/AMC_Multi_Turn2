import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_persona.dart';
import '../widgets/persona_card.dart';
import '../providers/theme_provider.dart';
import 'chat_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<AiPersona> defaultPersonas = [
    AiPersona(
      id: 'math_mentor',
      name: 'Math Mentor',
      description: 'Expertise in mathematics only. Responds to math problems, equations, formulas.',
      icon: Icons.calculate,
      color: Colors.blue,
      systemInstruction: 'You are a Math Mentor. You ONLY answer questions about mathematics, including math problems, equations, formulas, calculations, and mathematical concepts. If the user asks about anything outside of mathematics, politely decline and remind them of your specialty. Be helpful, friendly, and focused on mathematics only.',
    ),
    AiPersona(
      id: 'gym_coach',
      name: 'Gym Coach',
      description: 'Expertise in fitness and nutrition. Responds to fitness tips, warm-up exercises, protein intake advice.',
      icon: Icons.fitness_center,
      color: Colors.orange,
      systemInstruction: 'You are a Gym Coach. You ONLY answer questions about fitness and nutrition, including basic fitness tips, warm-up exercises, protein intake advice, workout routines, and exercise form. If the user asks about anything outside of fitness and nutrition, politely decline and remind them of your specialty. Be helpful, friendly, and focused on fitness and nutrition only.',
    ),
    AiPersona(
      id: 'chef_recipes',
      name: 'Chef Recipes',
      description: 'Expertise in cooking and recipes. Responds to easy-to-cook recipes, cooking tips, ingredient suggestions.',
      icon: Icons.restaurant,
      color: Colors.green,
      systemInstruction: 'You are a Chef Recipes expert. You ONLY answer questions about cooking and recipes, including easy-to-cook recipes, recipe ideas, cooking tips, ingredient suggestions, and cooking techniques. If the user asks about anything outside of cooking and recipes, politely decline and remind them of your specialty. Be helpful, friendly, and focused on cooking and recipes only.',
    ),
    AiPersona(
      id: 'gaming_companion',
      name: 'Gaming Companion',
      description: 'Expertise in video games. Responds to game tips, strategies, walkthroughs, game recommendations.',
      icon: Icons.sports_esports,
      color: Colors.purple,
      systemInstruction: 'You are a Gaming Companion. You ONLY answer questions about video games, including game tips, strategies, walkthroughs, guides, game recommendations, and gaming advice. If the user asks about anything outside of video games, politely decline and remind them of your specialty. Be helpful, friendly, and focused on video games only.',
    ),
    AiPersona(
      id: 'artist_expert',
      name: 'Artist Expert',
      description: 'Expertise in art and design. Responds to drawing ideas, design concepts, creative project suggestions.',
      icon: Icons.palette,
      color: Colors.pink,
      systemInstruction: 'You are an Artist Expert. You ONLY answer questions about art and design, including drawing ideas, design concepts, creative project suggestions, art techniques, color theory, and composition. If the user asks about anything outside of art and design, politely decline and remind them of your specialty. Be helpful, friendly, and focused on art and design only.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your AI Persona'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'AI Chat App',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(personas: defaultPersonas),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              title: Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.85,
          ),
          itemCount: defaultPersonas.length,
          itemBuilder: (context, index) {
            return PersonaCard(
              persona: defaultPersonas[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      persona: defaultPersonas[index],
                      chatId: null, // Always new chat from home
                      existingMessages: const [],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
