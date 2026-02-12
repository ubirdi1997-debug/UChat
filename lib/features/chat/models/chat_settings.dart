import 'package:equatable/equatable.dart';

/// Auto-delete duration options
enum AutoDeleteDuration {
  oneHour,
  twoHours,
  twentyFourHours,
  never,
}

extension AutoDeleteDurationExtension on AutoDeleteDuration {
  Duration? get duration {
    switch (this) {
      case AutoDeleteDuration.oneHour:
        return const Duration(hours: 1);
      case AutoDeleteDuration.twoHours:
        return const Duration(hours: 2);
      case AutoDeleteDuration.twentyFourHours:
        return const Duration(hours: 24);
      case AutoDeleteDuration.never:
        return null;
    }
  }
  
  String get displayName {
    switch (this) {
      case AutoDeleteDuration.oneHour:
        return '1 Hour';
      case AutoDeleteDuration.twoHours:
        return '2 Hours';
      case AutoDeleteDuration.twentyFourHours:
        return '24 Hours';
      case AutoDeleteDuration.never:
        return 'Never';
    }
  }
}

/// Chat settings model
class ChatSettings extends Equatable {
  final String chatId;
  final AutoDeleteDuration autoDeleteDuration;
  final bool encryptionEnabled;
  final bool notificationsEnabled;
  final DateTime? lastUpdated;
  
  const ChatSettings({
    required this.chatId,
    this.autoDeleteDuration = AutoDeleteDuration.twentyFourHours,
    this.encryptionEnabled = true,
    this.notificationsEnabled = true,
    this.lastUpdated,
  });
  
  factory ChatSettings.fromJson(Map<String, dynamic> json) {
    return ChatSettings(
      chatId: json['chat_id'] as String,
      autoDeleteDuration: AutoDeleteDuration.values.firstWhere(
        (d) => d.name == json['auto_delete_duration'],
        orElse: () => AutoDeleteDuration.twentyFourHours,
      ),
      encryptionEnabled: json['encryption_enabled'] as bool? ?? true,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'auto_delete_duration': autoDeleteDuration.name,
      'encryption_enabled': encryptionEnabled,
      'notifications_enabled': notificationsEnabled,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
  
  ChatSettings copyWith({
    String? chatId,
    AutoDeleteDuration? autoDeleteDuration,
    bool? encryptionEnabled,
    bool? notificationsEnabled,
    DateTime? lastUpdated,
  }) {
    return ChatSettings(
      chatId: chatId ?? this.chatId,
      autoDeleteDuration: autoDeleteDuration ?? this.autoDeleteDuration,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  @override
  List<Object?> get props => [
    chatId,
    autoDeleteDuration,
    encryptionEnabled,
    notificationsEnabled,
    lastUpdated,
  ];
}
