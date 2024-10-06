import 'package:flutter/material.dart';

class AnimatedOptionsList extends StatefulWidget {
  final List<String> options;
  final Function(String) onOptionSelected;
  final VoidCallback onDismiss;
  final Offset position;

  const AnimatedOptionsList({
    Key? key,
    required this.options,
    required this.onOptionSelected,
    required this.onDismiss,
    required this.position,
  }) : super(key: key);

  @override
  _AnimatedOptionsListState createState() => _AnimatedOptionsListState();
}

class _AnimatedOptionsListState extends State<AnimatedOptionsList> with TickerProviderStateMixin {
  late AnimationController _sizeController;
  late Animation<double> _sizeAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _sizeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _sizeController,
      curve: Curves.easeOut,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _sizeController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _fadeController.reverse().then((_) {
      _sizeController.reverse().then((_) {
        if (mounted) {
          widget.onDismiss();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final menuWidth = 200.0;
    final menuHeight = widget.options.length * 56.0; // Assuming each option is 56 pixels high

    // Adjust position if it goes off-screen
    double adjustedLeft = widget.position.dx;
    double adjustedTop = widget.position.dy;

    if (adjustedLeft + menuWidth > screenSize.width) {
      adjustedLeft = screenSize.width - menuWidth;
    }

    if (adjustedTop + menuHeight > screenSize.height) {
      adjustedTop = screenSize.height - menuHeight;
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _handleDismiss,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          Positioned(
            left: adjustedLeft,
            top: adjustedTop,
            child: SizeTransition(
              sizeFactor: _sizeAnimation,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: menuWidth,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.options.map((option) => 
                        ListTile(
                          title: Text(option),
                          onTap: () {
                            widget.onOptionSelected(option);
                            _handleDismiss();
                          },
                        )
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}