// File: lib/widgets/loading/skeleton_loader.dart
// Purpose: Skeleton loading components for better perceived performance
// Step: 12.2 - Loading States and UX Components

import 'package:flutter/material.dart';

/// A shimmer effect widget for skeleton loading
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? 
        (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ?? 
        (isDarkMode ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// A skeleton box for loading content
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];

    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// A skeleton avatar for loading profile pictures
class SkeletonAvatar extends StatelessWidget {
  final double radius;
  final Color? color;

  const SkeletonAvatar({
    super.key,
    this.radius = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: radius * 2,
      height: radius * 2,
      borderRadius: BorderRadius.circular(radius),
      color: color,
    );
  }
}

/// A skeleton text line with realistic width variations
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final int lines;
  final double spacing;
  final BorderRadius? borderRadius;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 16,
    this.lines = 1,
    this.spacing = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return SkeletonBox(
        width: width,
        height: height,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 4),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        // Vary the width for realistic text appearance
        final lineWidth = index == lines - 1 
            ? (width ?? 200) * 0.7  // Last line shorter
            : width;
        
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: SkeletonBox(
            width: lineWidth,
            height: height,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 4),
          ),
        );
      }),
    );
  }
}

/// A skeleton card for loading card-like content
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final bool hasAvatar;
  final bool hasSubtitle;
  final bool hasActions;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.hasAvatar = false,
    this.hasSubtitle = true,
    this.hasActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasAvatar)
              Row(
                children: [
                  const SkeletonAvatar(radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonText(width: 120, height: 16),
                        if (hasSubtitle) ...[
                          const SizedBox(height: 4),
                          const SkeletonText(width: 80, height: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              const SkeletonText(width: double.infinity, height: 18),
              if (hasSubtitle) ...[
                const SizedBox(height: 8),
                const SkeletonText(width: 200, height: 14),
              ],
            ],
            const SizedBox(height: 16),
            const SkeletonText(lines: 2, height: 14, spacing: 6),
            if (hasActions) ...[
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SkeletonBox(
                    width: 80,
                    height: 32,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  const SizedBox(width: 8),
                  SkeletonBox(
                    width: 80,
                    height: 32,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A skeleton list item for loading lists
class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final bool hasSubtitle;
  final EdgeInsets padding;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.hasSubtitle = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (hasLeading) ...[
              const SkeletonAvatar(radius: 20),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonText(width: double.infinity, height: 16),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 6),
                    const SkeletonText(width: 150, height: 12),
                  ],
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: 16),
              const SkeletonBox(width: 24, height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

/// A skeleton screen for loading entire screens
class SkeletonScreen extends StatelessWidget {
  final bool hasAppBar;
  final bool hasBottomNav;
  final String? title;
  final List<Widget>? customContent;

  const SkeletonScreen({
    super.key,
    this.hasAppBar = true,
    this.hasBottomNav = false,
    this.title,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
          ? AppBar(
              title: title != null
                  ? Text(title!)
                  : const ShimmerWidget(
                      child: SkeletonText(width: 120, height: 20),
                    ),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            )
          : null,
      body: customContent != null
          ? ShimmerWidget(
              child: Column(children: customContent!),
            )
          : _buildDefaultContent(),
      bottomNavigationBar: hasBottomNav
          ? _buildSkeletonBottomNav(context)
          : null,
    );
  }

  Widget _buildDefaultContent() {
    return ShimmerWidget(
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => const SkeletonListTile(),
      ),
    );
  }

  Widget _buildSkeletonBottomNav(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: const ShimmerWidget(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SkeletonBox(width: 24, height: 24),
            SkeletonBox(width: 24, height: 24),
            SkeletonBox(width: 24, height: 24),
            SkeletonBox(width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

/// Predefined skeleton layouts for common UI patterns
class SkeletonLayouts {
  /// Settings screen skeleton
  static Widget settings() {
    return ShimmerWidget(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme settings section
          const SkeletonText(width: 100, height: 16),
          const SizedBox(height: 16),
          const SkeletonCard(height: 200),
          
          const SizedBox(height: 24),
          
          // Other sections
          const SkeletonText(width: 120, height: 16),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SkeletonCard(height: 60),
          )),
        ],
      ),
    );
  }

  /// Calendar view skeleton
  static Widget calendar() {
    return ShimmerWidget(
      child: Column(
        children: [
          // Calendar header
          Container(
            height: 60,
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                SkeletonBox(width: 24, height: 24),
                SizedBox(width: 16),
                Expanded(child: SkeletonText(height: 20)),
                SizedBox(width: 16),
                SkeletonBox(width: 24, height: 24),
              ],
            ),
          ),
          
          // Calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 35,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.all(2),
                child: const SkeletonBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Course list skeleton
  static Widget courseList() {
    return ShimmerWidget(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SkeletonCard(
            height: 120,
            hasAvatar: false,
            hasSubtitle: true,
            hasActions: true,
          ),
        ),
      ),
    );
  }
}