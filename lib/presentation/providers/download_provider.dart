// presentation/providers/download_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
import '../../domain/entities/downloaded_file.dart';
import '../../data/local/hive_database.dart';

class DownloadState {
  final List<DownloadedFile> downloadedFiles;
  final bool isDownloading;
  final double downloadProgress;
  final String? error;

  DownloadState({
    required this.downloadedFiles,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.error,
  });

  DownloadState copyWith({
    List<DownloadedFile>? downloadedFiles,
    bool? isDownloading,
    double? downloadProgress,
    String? error,
  }) {
    return DownloadState(
      downloadedFiles: downloadedFiles ?? this.downloadedFiles,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      error: error ?? this.error,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  DownloadNotifier() : super(DownloadState(downloadedFiles: [])) {
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final files = HiveDatabase.getFiles();
    
    // If no files exist, add some sample files for testing
    if (files.isEmpty) {
      final sampleFiles = [
        DownloadedFile(
          id: 'sample-1',
          name: 'sample-document.pdf',
          path: '/sample/sample-document.pdf',
          type: 'pdf',
          size: 2048576, // 2MB
          downloadedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DownloadedFile(
          id: 'sample-2',
          name: 'presentation-slides.pptx',
          path: '/sample/presentation-slides.pptx',
          type: 'pptx',
          size: 5242880, // 5MB
          downloadedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        DownloadedFile(
          id: 'sample-3',
          name: 'data-analysis.xlsx',
          path: '/sample/data-analysis.xlsx',
          type: 'xlsx',
          size: 1048576, // 1MB
          downloadedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      // Save sample files to Hive
      for (final file in sampleFiles) {
        await HiveDatabase.saveFile(file);
      }
      
      state = state.copyWith(downloadedFiles: sampleFiles);
    } else {
      state = state.copyWith(downloadedFiles: files);
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    state = state.copyWith(isDownloading: true, downloadProgress: 0.0, error: null);

    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode == 200) {
        final contentLength = streamedResponse.contentLength ?? 0;
        final received = <int>[];
        int totalReceived = 0;

        final directory = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${directory.path}/downloads');

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final file = File('${downloadsDir.path}/$fileName');
        final sink = file.openWrite();

        await for (final chunk in streamedResponse.stream) {
          sink.add(chunk);
          received.addAll(chunk);
          totalReceived += chunk.length;
          
          if (contentLength > 0) {
            final progress = totalReceived / contentLength;
            state = state.copyWith(downloadProgress: progress);
          }
        }

        await sink.close();

        const uuid = Uuid();
        final downloadedFile = DownloadedFile(
          id: uuid.v4(),
          name: fileName,
          path: file.path,
          type: _getFileType(fileName, url),
          size: await file.length(),
          downloadedAt: DateTime.now(),
        );

        await HiveDatabase.saveFile(downloadedFile);
        await _loadDownloadedFiles(); // Reload files

        state = state.copyWith(isDownloading: false, downloadProgress: 1.0);
      } else {
        throw Exception('Failed to download file: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: 'Download failed: $e',
      );
    }
  }

  String _getFileType(String fileName, String url) {
    // First try to get MIME type from file name
    final mimeType = lookupMimeType(fileName);
    if (mimeType != null) {
      if (mimeType.startsWith('application/pdf')) return 'pdf';
      if (mimeType.contains('word') || mimeType.contains('document')) return 'docx';
      if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) return 'pptx';
      if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) return 'xlsx';
      if (mimeType.startsWith('text/')) return 'txt';
      if (mimeType.startsWith('image/')) return 'image';
      if (mimeType.startsWith('video/')) return 'video';
      if (mimeType.startsWith('audio/')) return 'audio';
    }
    
    // Fallback to extension-based detection
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'docx';
      case 'ppt':
      case 'pptx':
        return 'pptx';
      case 'xls':
      case 'xlsx':
        return 'xlsx';
      case 'txt':
      case 'md':
        return 'txt';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return 'image';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'flac':
        return 'audio';
      default:
        return ext.isEmpty ? 'unknown' : ext;
    }
  }

  Future<void> importLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileName = filePath.split('/').last;
      const uuid = Uuid();
      final downloadedFile = DownloadedFile(
        id: uuid.v4(),
        name: fileName,
        path: filePath,
        type: _getFileType(fileName, ''),
        size: await file.length(),
        downloadedAt: DateTime.now(),
      );

      await HiveDatabase.saveFile(downloadedFile);
      await _loadDownloadedFiles();
    } catch (e) {
      state = state.copyWith(error: 'Failed to import file: $e');
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final file = state.downloadedFiles.firstWhere((f) => f.id == fileId);
      final fileObj = File(file.path);

      if (await fileObj.exists()) {
        await fileObj.delete();
      }

      final updatedFiles = state.downloadedFiles.where((f) => f.id != fileId).toList();
      // Update Hive storage
      await _updateHiveFiles(updatedFiles);

      state = state.copyWith(downloadedFiles: updatedFiles);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete file: $e');
    }
  }

  Future<void> _updateHiveFiles(List<DownloadedFile> files) async {
    // Clear and re-save all files
    /*
    final data = files.map(HiveDatabase._fileToMap).toList();
    await HiveDatabase._filesBox.put('downloaded_files', data);
    */
    await HiveDatabase.replaceAllFiles(files);
  }

  // Public method to refresh files from storage
  Future<void> refreshFiles() async {
    await _loadDownloadedFiles();
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier();
});