# UChat Phase 2 Features - Implementation Guide

## Overview

This document outlines the advanced features added to UChat in Phase 2, including media sharing, voice/video calls, encryption, and security enhancements.

---

## 📱 New Features

### 1. Media Sharing

#### Photo Sharing
- **Pick from Gallery**: Select existing photos from device
- **Take Photo**: Capture new photo with camera
- **Auto Compression**: Images are automatically compressed to optimize bandwidth
- **Max Resolution**: 1920x1920 pixels with 85% quality

#### Video Sharing
- **Pick from Gallery**: Select existing videos
- **Record Video**: Record new video with camera
- **Duration Limit**: Maximum 5 minutes per video
- **Optimized for Mobile**: Suitable file sizes for mobile networks

#### Location Sharing
- **Current Location**: Share real-time GPS coordinates
- **Address Lookup**: Automatically fetch human-readable address
- **Map Integration**: Ready for Google Maps/Apple Maps display
- **Accuracy**: High accuracy location with fallback

#### Voice Messages
- **Record**: Tap and hold to record voice message
- **Quick Send**: Release to send automatically
- **Cancel**: Slide to cancel recording
- **Format**: AAC-LC encoding at 128kbps, 44.1kHz
- **Playback**: In-app audio player

#### File Sharing
- **Any File Type**: Share documents, PDFs, archives, etc.
- **File Picker**: Native file selection interface
- **Size Limits**: Configurable per deployment

### 2. Communication Features

#### Voice Calls
- **WebRTC Integration**: Real-time audio communication
- **Peer-to-Peer**: Direct connection for optimal quality
- **Call Controls**: Mute, speaker, end call
- **Network Adaptation**: Adjusts to network conditions

#### Video Calls
- **High Quality**: Up to HD video streaming
- **Camera Switch**: Toggle between front/rear camera
- **Video/Audio Toggle**: Control video and audio independently
- **Network Efficient**: Adaptive bitrate streaming

#### Emoji Support
- **Full Emoji Picker**: Access to all standard emojis
- **Quick Access**: Recently used emojis
- **Search**: Find emojis by name or category
- **Native Integration**: Platform-specific emoji rendering

### 3. Security & Privacy Features

#### End-to-End Encryption
- **AES-256 Encryption**: Military-grade encryption
- **Message Encryption**: All text messages encrypted
- **Media Encryption**: Photos, videos, and files encrypted
- **Key Management**: Secure key generation and storage
- **Forward Secrecy**: New keys for each session

#### MPIN (Mobile PIN)
- **4-6 Digit PIN**: Configurable PIN length
- **Secure Storage**: PIN hash stored in platform keychain
- **Auto-Lock**: Lock app when going to background
- **Change PIN**: Update PIN anytime from settings
- **Failed Attempts**: Configurable lockout policy

#### Biometric Authentication
- **Fingerprint**: Touch ID / Fingerprint sensor
- **Face Recognition**: Face ID / Face unlock
- **Device Support**: Adapts to available biometrics
- **Fallback**: MPIN fallback if biometric fails
- **Privacy**: Biometric data never leaves device

#### Auto-Delete Messages
- **Configurable Duration**:
  - 1 Hour
  - 2 Hours
  - 24 Hours (default)
  - Never (keep forever)
- **Per-Chat Settings**: Each chat can have different settings
- **Global Default**: Set default for all new chats
- **Local Delete**: Deletes only from your device
- **Automatic**: Background service handles deletion

### 4. Performance Optimizations

#### Fast App Performance
- **Lazy Loading**: Load messages on-demand
- **Image Caching**: Cache images for instant display
- **Video Optimization**: Compressed video delivery
- **Background Sync**: Efficient background updates
- **Network Optimization**: Minimal data usage

#### Efficient Media Handling
- **Progressive Loading**: Load media progressively
- **Thumbnail Generation**: Quick preview thumbnails
- **Compression**: Automatic compression before upload
- **Caching Strategy**: Intelligent cache management

---

## 🔧 Implementation Details

### Dependencies Added

```yaml
# Media & Communication
image_picker: ^1.0.5           # Photo/Video selection
video_player: ^2.8.1           # Video playback
record: ^5.0.4                 # Audio recording
audioplayers: ^5.2.1           # Audio playback
emoji_picker_flutter: ^1.6.3   # Emoji picker
geolocator: ^10.1.0            # Location services
geocoding: ^2.1.1              # Address lookup
permission_handler: ^11.1.0    # Runtime permissions
flutter_webrtc: ^0.9.46        # Voice/Video calls

# File Handling
path_provider: ^2.1.1          # File paths
flutter_image_compress: ^2.1.0 # Image compression
file_picker: ^6.1.1            # File selection

# Security
local_auth: ^2.1.8             # Biometric auth
encrypt: ^5.0.3                # Encryption
```

### Core Services

#### 1. MediaService
**Location**: `lib/features/chat/services/media_service.dart`

Functions:
- `pickImageFromGallery()` - Select photo from gallery
- `takePhoto()` - Capture new photo
- `pickVideoFromGallery()` - Select video
- `recordVideo()` - Record new video
- `pickFile()` - Select any file
- `compressImage()` - Compress image data
- `startRecording()` - Start audio recording
- `stopRecording()` - Stop and save recording
- `getCurrentLocation()` - Get GPS location
- `requestPermissions()` - Request all permissions

#### 2. EncryptionService
**Location**: `lib/core/security/encryption_service.dart`

Functions:
- `generateKey()` - Generate encryption key
- `encryptMessage()` - Encrypt text message
- `decryptMessage()` - Decrypt text message
- `encryptFile()` - Encrypt file data
- `decryptFile()` - Decrypt file data
- `hashData()` - Generate hash

#### 3. AppSecurityService
**Location**: `lib/core/security/app_security_service.dart`

Functions:
- `canCheckBiometrics()` - Check biometric support
- `authenticateWithBiometrics()` - Perform biometric auth
- `setMpin()` - Set new MPIN
- `verifyMpin()` - Verify MPIN
- `isMpinEnabled()` - Check if MPIN is enabled
- `isBiometricEnabled()` - Check if biometric is enabled
- `shouldLockApp()` - Check if app should lock

### Models

#### MessageMedia
**Location**: `lib/features/chat/models/message_media.dart`

Represents media attachments:
```dart
enum MessageType {
  text, image, video, audio, voice, location, file
}

class MessageMedia {
  final String id;
  final MessageType type;
  final String url;
  final String? thumbnailUrl;
  final String? localPath;
  final int? duration;
  final double? fileSize;
  final Map<String, dynamic>? metadata;
}
```

#### ChatSettings
**Location**: `lib/features/chat/models/chat_settings.dart`

Per-chat configuration:
```dart
enum AutoDeleteDuration {
  oneHour, twoHours, twentyFourHours, never
}

class ChatSettings {
  final String chatId;
  final AutoDeleteDuration autoDeleteDuration;
  final bool encryptionEnabled;
  final bool notificationsEnabled;
}
```

### UI Components

#### SecuritySettingsScreen
**Location**: `lib/features/settings/presentation/pages/security_settings_screen.dart`

Features:
- Enable/Disable MPIN
- Setup biometric authentication
- Configure auto-lock
- View encryption status
- Security information display

---

## 🚀 Usage Examples

### Sending a Photo

```dart
final mediaService = MediaService();

// Pick image
final imageFile = await mediaService.pickImageFromGallery();
if (imageFile != null) {
  // Compress image
  final compressed = await mediaService.compressImage(imageFile);
  
  // Create message with media
  final message = Message(
    id: uuid.v4(),
    chatId: chatId,
    senderId: currentUserId,
    content: '', // Optional caption
    messageType: MessageType.image,
    media: MessageMedia(
      id: uuid.v4(),
      type: MessageType.image,
      url: uploadedUrl, // After upload
      localPath: imageFile.path,
    ),
    isEncrypted: true,
    timestamp: DateTime.now(),
    status: MessageStatus.sending,
  );
  
  // Send message
  await chatService.sendMessage(message);
}
```

### Recording Voice Message

```dart
final mediaService = MediaService();

// Start recording
await mediaService.startRecording();

// Wait for user to finish...

// Stop recording
final audioPath = await mediaService.stopRecording();
if (audioPath != null) {
  // Create voice message
  final message = Message(
    id: uuid.v4(),
    chatId: chatId,
    senderId: currentUserId,
    content: 'Voice message',
    messageType: MessageType.voice,
    media: MessageMedia(
      id: uuid.v4(),
      type: MessageType.voice,
      url: uploadedUrl,
      localPath: audioPath,
      duration: audioDuration,
    ),
    isEncrypted: true,
    timestamp: DateTime.now(),
    status: MessageStatus.sending,
  );
  
  await chatService.sendMessage(message);
}
```

### Sharing Location

```dart
final mediaService = MediaService();

// Get current location
final locationData = await mediaService.getCurrentLocation();

// Create location message
final message = Message(
  id: uuid.v4(),
  chatId: chatId,
  senderId: currentUserId,
  content: locationData['address'] ?? 'Location',
  messageType: MessageType.location,
  media: MessageMedia(
    id: uuid.v4(),
    type: MessageType.location,
    url: '', // Optional map preview URL
    metadata: locationData,
  ),
  isEncrypted: true,
  timestamp: DateTime.now(),
  status: MessageStatus.sending,
);

await chatService.sendMessage(message);
```

### Setting Auto-Delete

```dart
// Update chat settings
final settings = ChatSettings(
  chatId: chatId,
  autoDeleteDuration: AutoDeleteDuration.twoHours,
  encryptionEnabled: true,
  notificationsEnabled: true,
);

await chatService.updateChatSettings(settings);
```

### Encrypting Messages

```dart
final encryptionService = EncryptionService();

// Generate or retrieve chat encryption key
final encryptionKey = await getChatEncryptionKey(chatId);

// Encrypt message
final encryptedContent = encryptionService.encryptMessage(
  message.content,
  encryptionKey,
);

// Send encrypted message
final encryptedMessage = message.copyWith(
  content: encryptedContent,
  isEncrypted: true,
);

await chatService.sendMessage(encryptedMessage);
```

---

## 📋 Platform-Specific Configuration

### Android

#### Permissions (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### iOS

#### Permissions (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>UChat needs camera access to take photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>UChat needs microphone access for voice messages and calls</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>UChat needs photo library access to share images</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>UChat needs location access to share your location</string>
<key>NSFaceIDUsageDescription</key>
<string>UChat uses Face ID to secure your app</string>
```

---

## 🔐 Security Considerations

### Message Encryption
- All messages encrypted with AES-256
- Unique encryption key per chat
- Keys stored in secure storage
- Forward secrecy supported

### MPIN Security
- PIN never stored in plain text
- Hashed before storage
- Stored in platform keychain
- Failed attempt tracking

### Biometric Security
- Biometric data never leaves device
- Platform-managed security
- Fallback to MPIN always available
- Can be disabled anytime

### Auto-Delete
- Background service monitors expiry
- Local deletion only (not peer device)
- Configurable per chat
- Can be disabled (keep forever)

---

## 🧪 Testing

### Unit Tests
- EncryptionService encryption/decryption
- ChatSettings duration calculations
- Message model serialization

### Integration Tests
- Media upload/download flow
- Encryption end-to-end
- Auto-delete background service

### UI Tests
- Security settings screen
- MPIN setup flow
- Biometric authentication

---

## 📈 Performance Metrics

### Targets
- Message send latency: <500ms
- Image upload: <3s for 2MB image
- Video upload: <10s for 10MB video
- App launch: <2s cold start
- MPIN verification: <100ms

### Optimization Strategies
- Image compression before upload
- Lazy loading of media
- Cached image rendering
- Background upload queue
- Efficient encryption

---

## 🔄 Future Enhancements

### Phase 3 (Planned)
- Group video calls
- Screen sharing
- Message reactions
- Message forwarding
- Chat backup/restore
- Multi-device sync

### Phase 4 (Planned)
- AI-powered features
- Translation
- Voice-to-text
- Advanced encryption (Signal Protocol)

---

## 📞 Support

For issues or questions:
- Technical: Create GitHub issue
- Security: security@usafe.in
- General: support@usafe.in

---

**Built with ❤️ by the UChat team**
