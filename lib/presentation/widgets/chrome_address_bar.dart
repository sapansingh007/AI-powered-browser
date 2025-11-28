// presentation/widgets/chrome_address_bar.dart - Chrome-style Address Bar
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/themes/app_theme.dart';

class ChromeAddressBar extends StatefulWidget {
  final String url;
  final String title;
  final bool isLoading;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBackPressed;
  final VoidCallback onForwardPressed;
  final VoidCallback onRefreshPressed;
  final VoidCallback onHomePressed;
  final Function(String) onUrlSubmitted;
  final VoidCallback onMenuPressed;

  const ChromeAddressBar({
    super.key,
    required this.url,
    required this.title,
    required this.isLoading,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBackPressed,
    required this.onForwardPressed,
    required this.onRefreshPressed,
    required this.onHomePressed,
    required this.onUrlSubmitted,
    required this.onMenuPressed,
  });

  @override
  State<ChromeAddressBar> createState() => _ChromeAddressBarState();
}

class _ChromeAddressBarState extends State<ChromeAddressBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.url);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChromeAddressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused) {
      _controller.text = widget.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Mobile breakpoint

    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16, // Less padding on mobile
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Navigation buttons - Hide some on mobile if needed
          if (!isMobile || screenWidth > 400) ...[
            // Back button
            _buildNavButton(
              icon: Icons.arrow_back,
              onPressed: widget.canGoBack ? widget.onBackPressed : null,
              isActive: widget.canGoBack,
              isLoading: widget.isLoading,
            ),
            const SizedBox(width: 4),
            // Forward button
            _buildNavButton(
              icon: Icons.arrow_forward,
              onPressed: widget.canGoForward ? widget.onForwardPressed : null,
              isActive: widget.canGoForward,
              isLoading: widget.isLoading,
            ),
            const SizedBox(width: 4),
            // Refresh button
            _buildNavButton(
              icon: Icons.refresh,
              onPressed: widget.onRefreshPressed,
              isActive: true,
              isLoading: widget.isLoading,
            ),
            const SizedBox(width: 4),
            // Home button
            _buildNavButton(
              icon: Icons.home,
              onPressed: widget.onHomePressed,
              isActive: true,
            ),
          ],

          // Reduced spacing on mobile
          SizedBox(width: isMobile ? 4 : 8),

          // Address bar
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isDark 
                    ? (_isFocused ? AppTheme.darkElevated : AppTheme.darkCard)
                    : (_isFocused ? Colors.white : AppTheme.lightElevated),
                borderRadius: BorderRadius.circular(isMobile ? 20 : 24), // Smaller radius on mobile
                border: Border.all(
                  color: _isFocused 
                      ? (isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4))
                      : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: (isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4)).withOpacity(0.2),
                          blurRadius: 6, // Reduced shadow on mobile
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  
                  // Security/lock icon
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isFocused
                        ? Icon(
                            Icons.search,
                            key: const ValueKey('search'),
                            size: 20,
                            color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                          )
                        : _buildSecurityIcon(),
                  ),

                  const SizedBox(width: 8),

                  // URL input field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _isFocused ? 'Search or enter address' : widget.title,
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                          fontSize: 14,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      maxLines: 1,
                      maxLength: 200, // Reduced for mobile
                      buildCounter: (context, {required currentLength, required isFocused, required maxLength}) => null, // Hide counter
                      onSubmitted: (value) {
                        String url = value.trim();
                        if (url.isNotEmpty) {
                          // Auto-add https:// if no protocol is specified
                          if (!url.startsWith('http://') && !url.startsWith('https://')) {
                            url = 'https://$url';
                          }
                          widget.onUrlSubmitted(url);
                          _focusNode.unfocus();
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8), // Add spacing before end elements

                  // Loading indicator or clear button
                  if (widget.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    )
                  else if (_isFocused && _controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.clear,
                          size: 18,
                          color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 12), // Fixed padding when not loading
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Menu button
          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isActive,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    size: 18,
                    color: isActive
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368)),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityIcon() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final url = widget.url.toLowerCase();

    IconData icon;
    Color color;

    if (url.startsWith('https://')) {
      icon = Icons.lock;
      color = const Color(0xFF34A853); // Green for secure
    } else if (url.startsWith('http://')) {
      icon = Icons.info_outline;
      color = const Color(0xFFEA4335); // Red for not secure
    } else if (url.startsWith('chrome://') || url.startsWith('file://')) {
      icon = Icons.info;
      color = const Color(0xFF4285F4); // Blue for internal pages
    } else {
      icon = Icons.search;
      color = isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368);
    }

    return Icon(
      icon,
      size: 20,
      color: color,
    );
  }

  Widget _buildMenuButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onMenuPressed,
          borderRadius: BorderRadius.circular(18),
          child: Icon(
            Icons.more_vert,
            size: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
