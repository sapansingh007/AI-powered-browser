// presentation/pages/files_page.dart - UPDATED
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/downloaded_file.dart';
import '../providers/download_provider.dart';

class FilesPage extends ConsumerWidget {
  const FilesPage({super.key});

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    try {
      print('Starting file picker'); // Debug print
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'docx', 'doc', 'pptx', 'ppt', 'xlsx', 'xls', 'txt', 'rtf',
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg',
          'mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv',
          'mp3', 'wav', 'flac', 'aac', 'ogg',
          'zip', 'rar', '7z', 'tar', 'gz'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        print('File selected: ${file.name}, path: ${file.path}'); // Debug print
        
        if (!context.mounted) return;
        
        // Import the file into the system
        await ref.read(downloadProvider.notifier).importLocalFile(file.path!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File imported: ${file.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        print('File import completed'); // Debug print
      } else {
        print('No file selected'); // Debug print
      }
    } catch (e) {
      print('File picker error: $e'); // Debug print
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      // print('Error opening file: $e');
      debugPrint('Error opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadProvider);
    final files = downloadState.downloadedFiles;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        elevation: 0,
        titleSpacing: isMobile ? 0 : 16,
        title: Text(
          'Files & Downloads',
          style: TextStyle(
            color: isDark ? const Color(0xFFE8EAED) : const Color(0xFF202124),
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        actions: [
          if (screenWidth > 400) // Only show add button on larger screens
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () => _pickFile(context, ref),
            ),
          if (screenWidth > 350) // Only show download button on larger screens
            IconButton(
              icon: Icon(
                Icons.download,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                // Example download - replace with actual URL from browser
                ref.read(downloadProvider.notifier).downloadFile(
                  'https://example.com/sample.pdf',
                  'sample.pdf',
                );
              },
            ),
          // Always show menu button for mobile
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => _showMobileMenu(context, ref, isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Download progress notification bar
          if (downloadState.isDownloading)
            _buildDownloadProgressBanner(downloadState.downloadProgress, isDark, isMobile),
          
          // Main content
          Expanded(
            child: _buildFilesList(files, ref, isDark, isMobile),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'File Options',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.add_rounded,
              color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
            ),
            title: Text(
              'Import File',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickFile(context, ref);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.download_rounded,
              color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
            ),
            title: Text(
              'Download Sample',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(downloadProvider.notifier).downloadFile(
                'https://example.com/sample.pdf',
                'sample.pdf',
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.refresh_rounded,
              color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
            ),
            title: Text(
              'Refresh Files',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(downloadProvider.notifier).refreshFiles();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDownloadProgressBanner(double progress, bool isDark, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
            : [const Color(0xFF4285F4), const Color(0xFF1A73E8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: isDark ? const Color(0xFF8AB4F8) : Colors.white,
                size: isMobile ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Downloading file...',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF8AB4F8) : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8AB4F8) : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8AB4F8),
                      const Color(0xFF4285F4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList(List<DownloadedFile> files, WidgetRef ref, bool isDark, bool isMobile) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: isMobile ? 60 : 80,
              color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFBDC1C6),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'No downloaded files yet',
              style: TextStyle(
                color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 0),
              child: Text(
                'Download files from the browser or import local files',
                style: TextStyle(
                  color: isDark ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
                  fontSize: isMobile ? 13 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _buildFileCard(file, ref, isDark, context, isMobile);
      },
    );
  }

  Widget _buildFileCard(DownloadedFile file, WidgetRef ref, bool isDark, BuildContext context, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
        leading: Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F4),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          ),
          child: _getFileIcon(file.type, isMobile),
        ),
        title: Text(
          file.name,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: isMobile ? 2 : 4),
          child: Row(
            children: [
              Icon(
                Icons.storage_rounded,
                size: isMobile ? 12 : 14,
                color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
              ),
              SizedBox(width: isMobile ? 2 : 4),
              Text(
                _formatFileSize(file.size),
                style: TextStyle(
                  color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: isMobile ? 4 : 8),
              Icon(
                Icons.schedule_rounded,
                size: isMobile ? 12 : 14,
                color: isDark ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
              ),
              SizedBox(width: isMobile ? 2 : 4),
              Text(
                _formatDate(file.downloadedAt),
                style: TextStyle(
                  color: isDark ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile) // Only show summary button on larger screens
              IconButton(
                icon: Icon(
                  Icons.summarize_rounded,
                  color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                  size: 20,
                ),
                onPressed: () {
                  _showSummaryDialog(context, file);
                },
              ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? const Color(0xFFEA4335) : const Color(0xFFD93025),
                size: isMobile ? 18 : 20,
              ),
              onPressed: () {
                _showDeleteDialog(context, ref, file);
              },
            ),
          ],
        ),
        onTap: () => _openFile(file.path),
      ),
    );
  }

  Widget _getFileIcon(String fileType, bool isMobile) {
    final iconSize = isMobile ? 20.0 : 24.0;
    
    switch (fileType) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: const Color(0xFFEA4335), size: iconSize);
      case 'docx':
      case 'doc':
        return Icon(Icons.description, color: const Color(0xFF4285F4), size: iconSize);
      case 'pptx':
      case 'ppt':
        return Icon(Icons.slideshow, color: const Color(0xFFFBBC04), size: iconSize);
      case 'xlsx':
      case 'xls':
        return Icon(Icons.table_chart, color: const Color(0xFF34A853), size: iconSize);
      case 'txt':
      case 'md':
        return Icon(Icons.text_snippet, color: const Color(0xFF5F6368), size: iconSize);
      case 'image':
        return Icon(Icons.image, color: const Color(0xFF9334E6), size: iconSize);
      case 'video':
        return Icon(Icons.videocam, color: const Color(0xFFEA4335), size: iconSize);
      case 'audio':
        return Icon(Icons.audiotrack, color: const Color(0xFFFBBC04), size: iconSize);
      case 'unknown':
        return Icon(Icons.help_outline, color: const Color(0xFF5F6368), size: iconSize);
      default:
        return Icon(Icons.insert_drive_file, color: const Color(0xFF8AB4F8), size: iconSize);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, DownloadedFile file) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text(
          'Delete File',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this file?',
              style: TextStyle(
                color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_rounded,
                    color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(downloadProvider.notifier).deleteFile(file.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('File deleted successfully'),
                  backgroundColor: const Color(0xFF34A853),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA4335),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSummaryDialog(BuildContext context, DownloadedFile file) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.summarize_rounded,
              color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Summarize ${file.name}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File summarization feature allows you to extract key information from your downloaded documents.',
              style: TextStyle(
                color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_rounded,
                    color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatFileSize(file.size)} • ${file.type.toUpperCase()}',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F3F2F) : const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF34A853) : const Color(0xFF34A853).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: const Color(0xFF34A853),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI-powered summarization will be available in the next update.',
                      style: TextStyle(
                        color: const Color(0xFF34A853),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Summarization feature coming soon!'),
                  backgroundColor: const Color(0xFFFBBC04),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coming Soon'),
          ),
        ],
      ),
    );
  }
}