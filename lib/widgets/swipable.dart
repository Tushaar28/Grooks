import 'package:flutter/material.dart';

class SwipeableWidget extends StatefulWidget {
  final Widget child;
  final double height;
  final VoidCallback onSwipeCallback;
  final double swipePercentage;

  const SwipeableWidget({
    Key? key,
    required this.child,
    required this.height,
    required this.onSwipeCallback,
    this.swipePercentage = 0.75,
  })  : assert(
          swipePercentage <= 1.0,
        ),
        super(key: key);

  @override
  _SwipeableWidgetState createState() => _SwipeableWidgetState();
}

class _SwipeableWidgetState extends State<SwipeableWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var startPosition = 0.0;
  var endPosition = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        setState(() {
          startPosition = details.localPosition.dx;
        });
      },
      onPanUpdate: (DragUpdateDetails details) {
        final widgetSize = context.size!.width;

        final minimumToStartSwiping = widgetSize * 0.25;
        if (startPosition <= minimumToStartSwiping) {
          setState(() {
            endPosition = details.localPosition.dx;
          });

          final widgetSize = context.size!.width;
          _controller.value = 1 - ((details.localPosition.dx) / widgetSize);
        }
      },
      onPanEnd: (DragEndDetails details) async {
        final delta = endPosition - startPosition;
        final widgetSize = context.size!.width;
        final deltaNeededToBeSwiped = widgetSize * widget.swipePercentage;
        if (delta > deltaNeededToBeSwiped) {
          _controller.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
          widget.onSwipeCallback();
        } else {
          _controller.animateTo(
            1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
        }
      },
      child: SizedBox(
        height: widget.height,
        child: Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: _controller.value,
            heightFactor: 1.0,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
