/// Message type enum
enum MessageType {
  text,
  image,
  video,
  audio,
  voice,
  location,
  file,
}

/// Message media model
class MessageMedia {
  final String id;
  final MessageType type;
  final String url;
  final String? thumbnailUrl;
  final String? localPath;
  final int? duration; // For audio/video in seconds
  final double? fileSize; // In bytes
  final String? mimeType;
  final Map<String, dynamic>? metadata; // For location: lat, lng, address
  
  const MessageMedia({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.localPath,
    this.duration,
    this.fileSize,
    this.mimeType,
    this.metadata,
  });
  
  factory MessageMedia.fromJson(Map<String, dynamic> json) {
    return MessageMedia(
      id: json['id'] as String,
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      localPath: json['local_path'] as String?,
      duration: json['duration'] as int?,
      fileSize: json['file_size'] as double?,
      mimeType: json['mime_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'local_path': localPath,
      'duration': duration,
      'file_size': fileSize,
      'mime_type': mimeType,
      'metadata': metadata,
    };
  }
  
  MessageMedia copyWith({
    String? id,
    MessageType? type,
    String? url,
    String? thumbnailUrl,
    String? localPath,
    int? duration,
    double? fileSize,
    String? mimeType,
    Map<String, dynamic>? metadata,
  }) {
    return MessageMedia(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localPath: localPath ?? this.localPath,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
    );
  }
}
