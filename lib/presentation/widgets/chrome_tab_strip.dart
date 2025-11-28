// presentation/widgets/chrome_tab_strip.dart - Chrome-style Tab Strip
import 'package:flutter/material.dart';
import '../../domain/entities/browser_tab.dart';

class ChromeTabStrip extends StatefulWidget {
  final List<BrowserTab> tabs;
  final String? activeTabId;
  final Function(String) onTabSelected;
  final Function(String) onTabClosed;
  final VoidCallback onNewTab;

  const ChromeTabStrip({
    super.key,
    required this.tabs,
    this.activeTabId,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
  });

  @override
  State<ChromeTabStrip> createState() => _ChromeTabStripState();
}

class _ChromeTabStripState extends State<ChromeTabStrip>
    with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292A2D) : const Color(0xFFF8F9FA),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // New tab button
          Container(
            width: 40,
            height: 32,
            margin: const EdgeInsets.only(left: 8, right: 4),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: widget.onNewTab,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                  ),
                ),
              ),
            ),
          ),

          // Tab list
          Expanded(
            child: ListView.builder(
              controller: _listScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: widget.tabs.length,
              itemBuilder: (context, index) {
                final tab = widget.tabs[index];
                final isActive = tab.id == widget.activeTabId;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: _ChromeTab(
                    tab: tab,
                    isActive: isActive,
                    onTap: () => widget.onTabSelected(tab.id),
                    onClose: () => widget.onTabClosed(tab.id),
                  ),
                );
              },
            ),
          ),

          // Optional: Tab menu button
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => _showTabMenu(context),
                borderRadius: BorderRadius.circular(8),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTabMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF292A2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Tab menu items
            _buildTabMenuItem(
              icon: Icons.add,
              title: 'New tab',
              onTap: () {
                widget.onNewTab();
                Navigator.pop(context);
              },
            ),
            _buildTabMenuItem(
              icon: Icons.refresh,
              title: 'Refresh all tabs',
              onTap: () => Navigator.pop(context),
            ),
            _buildTabMenuItem(
              icon: Icons.close,
              title: 'Close all tabs',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTabMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black87,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ChromeTab extends StatefulWidget {
  final BrowserTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _ChromeTab({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_ChromeTab> createState() => _ChromeTabState();
}

class _ChromeTabState extends State<_ChromeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) {
          _animationController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 32,
                constraints: const BoxConstraints(minWidth: 120, maxWidth: 240),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? (isDark ? const Color(0xFF3C4043) : Colors.white)
                      : (_isHovering
                          ? (isDark ? const Color(0xFF3C4043) : const Color(0xFFF1F3F4))
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isActive
                        ? (isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0))
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    
                    // Favicon or tab icon
                    _buildTabIcon(),
                    
                    const SizedBox(width: 6),
                    
                    // Tab title
                    Expanded(
                      child: Text(
                        widget.tab.title.isNotEmpty 
                            ? widget.tab.title
                            : 'New Tab',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isActive
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368)),
                          fontSize: 12,
                          fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    
                    // Close button
                    if (true) // Always show close button for Chrome-like behavior
                      _buildCloseButton(),
                    
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabIcon() {
    final url = widget.tab.url.toLowerCase();
    
    if (url.startsWith('https://')) {
      return Icon(
        Icons.lock,
        size: 14,
        color: widget.isActive
            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
            : const Color(0xFF34A853),
      );
    } else if (url.contains('google.com')) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: Color(0xFF4285F4),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (url.contains('github.com')) {
      return Icon(
        Icons.code,
        size: 14,
        color: widget.isActive
            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
            : Colors.black,
      );
    } else {
      return Icon(
        Icons.language,
        size: 14,
        color: widget.isActive
            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
            : const Color(0xFF5F6368),
      );
    }
  }

  Widget _buildCloseButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.close,
            size: 12,
            color: widget.isActive
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368)),
          ),
        ),
      ),
    );
  }
}
