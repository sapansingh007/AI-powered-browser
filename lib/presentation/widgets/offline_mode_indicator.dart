// presentation/widgets/offline_mode_indicator.dart - Offline Mode Indicator
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_provider.dart';

class OfflineModeIndicator extends ConsumerWidget {
  const OfflineModeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (offlineState.shouldUseOfflineMode) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E8E3E) : const Color(0xFFE8F5E8),
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF2E8E4E) : const Color(0xFFC8E6C9),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Offline Mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    offlineState.isOnline 
                        ? 'Offline mode enabled manually'
                        : 'No internet connection',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF388E3C),
                    ),
                  ),
                ],
              ),
            ),
            if (offlineState.isOnline)
              TextButton(
                onPressed: () => ref.read(offlineProvider.notifier).disableOfflineMode(),
                child: Text(
                  'Go Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class OfflineModeBanner extends ConsumerWidget {
  const OfflineModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!offlineState.isOnline && !offlineState.isOfflineMode) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFFE53935) : const Color(0xFFFFEBEE),
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFFEF5350) : const Color(0xFFFFCDD2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No internet connection',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(offlineProvider.notifier).enableOfflineMode(),
              child: Text(
                'Enable Offline',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
