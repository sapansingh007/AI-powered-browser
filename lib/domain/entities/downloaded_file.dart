// domain/entities/downloaded_file.dart
class DownloadedFile {
  final String id;
  final String name;
  final String path;
  final String type;
  final int size;
  final DateTime downloadedAt;

  DownloadedFile({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.downloadedAt,
  });
}