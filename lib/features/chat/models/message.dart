import 'package:equatable/equatable.dart';

/// Message status enum
enum MessageStatus {
  sending,
  sent,
  delivered,
  seen,
  failed,
}

/// Chat message model
class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? editedAt;
  final bool isDeleted;
  
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.status,
    required this.timestamp,
    this.editedAt,
    this.isDeleted = false,
  });
  
  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      status: MessageStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'] as String)
          : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }
  
  /// Copy with updated fields
  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? editedAt,
    bool? isDeleted,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    content,
    status,
    timestamp,
    editedAt,
    isDeleted,
  ];
}
