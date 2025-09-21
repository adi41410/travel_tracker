class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final ChatMessageType type;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isFromUser': isFromUser ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.toString().split('.').last,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      content: map['content'],
      isFromUser: map['isFromUser'] == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      type: ChatMessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ChatMessageType.text,
      ),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isFromUser,
    DateTime? timestamp,
    ChatMessageType? type,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isFromUser: isFromUser ?? this.isFromUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

enum ChatMessageType { text, typing, error }
