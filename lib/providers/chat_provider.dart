import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/ai_chat_service.dart';

class ChatProvider with ChangeNotifier {
  final AIChatService _chatService = AIChatService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<ChatMessage>> get messagesStream => _chatService.messagesStream;

  ChatProvider() {
    _init();
  }

  void _init() {
    _chatService.messagesStream.listen((messages) {
      _messages = messages;
      notifyListeners();
    });
    _chatService.initializeChat();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _chatService.sendMessage(content);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    try {
      await _chatService.clearChat();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
