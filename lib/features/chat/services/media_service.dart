import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

/// Media service for handling photos, videos, audio, and location
class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();
  
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Uuid _uuid = const Uuid();
  
  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw MediaException('Failed to pick image: $e');
    }
  }
  
  /// Take photo with camera
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw MediaException('Failed to take photo: $e');
    }
  }
  
  /// Pick video from gallery
  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video == null) return null;
      return File(video.path);
    } catch (e) {
      throw MediaException('Failed to pick video: $e');
    }
  }
  
  /// Record video with camera
  Future<File?> recordVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video == null) return null;
      return File(video.path);
    } catch (e) {
      throw MediaException('Failed to record video: $e');
    }
  }
  
  /// Pick any file
  Future<File?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) return null;
      
      final path = result.files.first.path;
      if (path == null) return null;
      
      return File(path);
    } catch (e) {
      throw MediaException('Failed to pick file: $e');
    }
  }
  
  /// Compress image
  Future<Uint8List?> compressImage(File file, {int quality = 85}) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
      );
      return result;
    } catch (e) {
      throw MediaException('Failed to compress image: $e');
    }
  }
  
  /// Start recording audio
  Future<void> startRecording() async {
    try {
      // Check permission
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        throw MediaException('Microphone permission not granted');
      }
      
      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${_uuid.v4()}.m4a';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
    } catch (e) {
      throw MediaException('Failed to start recording: $e');
    }
  }
  
  /// Stop recording audio
  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      return path;
    } catch (e) {
      throw MediaException('Failed to stop recording: $e');
    }
  }
  
  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.stop();
    } catch (e) {
      // Ignore cancel errors
    }
  }
  
  /// Check if recording
  Future<bool> isRecording() async {
    try {
      return await _audioRecorder.isRecording();
    } catch (e) {
      return false;
    }
  }
  
  /// Get current location
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Check permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          throw MediaException('Location permission denied');
        }
      }
      
      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Get address
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        }
      } catch (e) {
        // Address lookup failed, continue without it
      }
      
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'accuracy': position.accuracy,
      };
    } catch (e) {
      throw MediaException('Failed to get location: $e');
    }
  }
  
  /// Request permissions
  Future<bool> requestPermissions() async {
    final permissions = await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
      Permission.storage,
      Permission.location,
    ].request();
    
    return permissions.values.every((status) => status.isGranted);
  }
  
  /// Check if permissions are granted
  Future<bool> hasAllPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
      Permission.storage,
      Permission.location,
    ].request();
    
    return statuses.values.every((status) => status.isGranted);
  }
}

class MediaException implements Exception {
  final String message;
  MediaException(this.message);
  
  @override
  String toString() => 'MediaException: $message';
}
