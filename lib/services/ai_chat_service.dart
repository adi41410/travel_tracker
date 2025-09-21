import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import 'database_service.dart';

class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  final DatabaseService _db = DatabaseService();
  final List<ChatMessage> _messages = [];
  final StreamController<List<ChatMessage>> _messagesController =
      StreamController<List<ChatMessage>>.broadcast();

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // For demo purposes, we'll use a simple mock AI response
  // In a real app, you would integrate with OpenAI, Gemini, or other AI services
  final List<String> _mockResponses = [
    "Hello! I'm your travel assistant. How can I help you plan your next adventure?",
    "That sounds like an amazing trip! I'd recommend checking the weather and local customs.",
    "Have you considered visiting local markets? They're great for experiencing authentic culture.",
    "Don't forget to pack essentials like a portable charger and comfortable walking shoes!",
    "I can help you find the best restaurants, attractions, and hidden gems in your destination.",
    "Would you like some tips for budget-friendly travel or luxury experiences?",
    "Make sure to backup your photos and keep digital copies of important documents.",
    "Local transportation apps can be really helpful for getting around efficiently.",
  ];

  Future<void> initializeChat() async {
    // Load previous messages from database
    await _loadMessagesFromDB();

    // Add welcome message if no messages exist
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: _generateId(),
        content:
            "Hi there! I'm your AI travel assistant. I can help you with travel tips, recommendations, and planning. What would you like to know?",
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(welcomeMessage);
      await _saveMessageToDB(welcomeMessage);
      _messagesController.add(_messages);
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: _generateId(),
      content: content.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    await _saveMessageToDB(userMessage);
    _messagesController.add(_messages);

    // Add typing indicator
    final typingMessage = ChatMessage(
      id: _generateId(),
      content: "AI is typing...",
      isFromUser: false,
      timestamp: DateTime.now(),
      type: ChatMessageType.typing,
    );

    _messages.add(typingMessage);
    _messagesController.add(_messages);

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Remove typing indicator
    _messages.removeWhere((msg) => msg.type == ChatMessageType.typing);

    // Generate AI response
    final aiResponse = await _generateAIResponse(content);
    final aiMessage = ChatMessage(
      id: _generateId(),
      content: aiResponse,
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(aiMessage);
    await _saveMessageToDB(aiMessage);
    _messagesController.add(_messages);
  }

  Future<String> _generateAIResponse(String userMessage) async {
    // For demo purposes, we'll use mock responses
    // In a real app, you would call an AI service like OpenAI API

    final random = Random();
    final baseResponse = _mockResponses[random.nextInt(_mockResponses.length)];

    // Add some context-aware responses
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('budget') ||
        lowerMessage.contains('cheap') ||
        lowerMessage.contains('money')) {
      return "For budget travel, I recommend using public transport, staying in hostels or guesthouses, eating at local markets, and looking for free walking tours. Many museums also have free admission days!";
    } else if (lowerMessage.contains('food') ||
        lowerMessage.contains('restaurant') ||
        lowerMessage.contains('eat')) {
      return "Food is one of the best parts of traveling! Try to eat where locals eat, check out street food (if safe), and don't miss regional specialties. Food apps like Zomato or local equivalents can be helpful.";
    } else if (lowerMessage.contains('safety') ||
        lowerMessage.contains('safe')) {
      return "Safety first! Research your destination, keep copies of important documents, stay in well-reviewed accommodations, trust your instincts, and keep emergency contacts handy. Register with your embassy if traveling internationally.";
    } else if (lowerMessage.contains('packing') ||
        lowerMessage.contains('pack')) {
      return "Pack light and smart! Bring versatile clothing, comfortable shoes, a portable charger, basic first aid items, and check airline baggage restrictions. Roll clothes instead of folding to save space!";
    }

    return baseResponse;
  }

  Future<void> _loadMessagesFromDB() async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'chat_messages',
        orderBy: 'timestamp ASC',
      );

      _messages.clear();
      _messages.addAll(maps.map((map) => ChatMessage.fromMap(map)));
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
      // Create table if it doesn't exist
      await _createChatTable();
    }
  }

  Future<void> _saveMessageToDB(ChatMessage message) async {
    try {
      final db = await _db.database;
      await db.insert('chat_messages', message.toMap());
    } catch (e) {
      debugPrint('Error saving chat message: $e');
      await _createChatTable();
      final db = await _db.database;
      await db.insert('chat_messages', message.toMap());
    }
  }

  Future<void> _createChatTable() async {
    final db = await _db.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        isFromUser INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        type TEXT DEFAULT 'text'
      )
    ''');
  }

  Future<void> clearChat() async {
    try {
      final db = await _db.database;
      await db.delete('chat_messages');
      _messages.clear();
      _messagesController.add(_messages);

      // Re-add welcome message
      await initializeChat();
    } catch (e) {
      debugPrint('Error clearing chat: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  void dispose() {
    _messagesController.close();
  }
}
