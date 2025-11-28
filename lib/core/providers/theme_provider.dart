// core/providers/theme_provider.dart - Centralized Theme Provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Centralized theme provider to avoid conflicts
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
