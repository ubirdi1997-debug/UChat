import 'package:equatable/equatable.dart';
import 'message.dart';

/// Chat model
class Chat extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final Message? lastMessage;
  final int unreadCount;
  final bool isTyping;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const Chat({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    this.isTyping = false,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Create from JSON
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      participantId: json['participant_id'] as String,
      participantName: json['participant_name'] as String,
      participantAvatar: json['participant_avatar'] as String?,
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isTyping: json['is_typing'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_id': participantId,
      'participant_name': participantName,
      'participant_avatar': participantAvatar,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'is_typing': isTyping,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Copy with updated fields
  Chat copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    Message? lastMessage,
    int? unreadCount,
    bool? isTyping,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    participantId,
    participantName,
    participantAvatar,
    lastMessage,
    unreadCount,
    isTyping,
    createdAt,
    updatedAt,
  ];
}
