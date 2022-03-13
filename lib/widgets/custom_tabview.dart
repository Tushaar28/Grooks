import 'package:flutter/material.dart';

class CustomTabView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final Widget? stub;
  final ValueChanged<int>? onPositionChange;
  final ValueChanged<double>? onScroll;
  final int? initPosition;

  const CustomTabView({
    Key? key,
    required this.itemCount,
    required this.tabBuilder,
    this.stub,
    this.onPositionChange,
    this.onScroll,
    this.initPosition,
  }) : super(key: key);

  @override
  _CustomTabsState createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabView>
    with TickerProviderStateMixin {
  late final TabController _controller;
  late int _currentCount;
  late int _currentPosition;

  @override
  void initState() {
    _currentPosition = widget.initPosition ?? 0;
    _controller = TabController(
      length: widget.itemCount,
      vsync: this,
      initialIndex: _currentPosition,
    );
    _controller.addListener(onPositionChange);
    _controller.animation!.addListener(onScroll);
    _currentCount = widget.itemCount;
    super.initState();
  }

  @override
  void didUpdateWidget(CustomTabView oldWidget) {
    if (_currentCount != widget.itemCount) {
      _controller.animation!.removeListener(onScroll);
      _controller.removeListener(onPositionChange);
      _controller.dispose();

      if (widget.initPosition != null) {
        _currentPosition = widget.initPosition!;
      }

      if (_currentPosition > widget.itemCount - 1) {
        _currentPosition = widget.itemCount - 1;
        _currentPosition = _currentPosition < 0 ? 0 : _currentPosition;
        if (widget.onPositionChange is ValueChanged<int>) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            if (mounted) {
              widget.onPositionChange!(_currentPosition);
            }
          });
        }
      }

      _currentCount = widget.itemCount;
      setState(() {
        _controller = TabController(
          length: widget.itemCount,
          vsync: this,
          initialIndex: _currentPosition,
        );
        _controller.addListener(onPositionChange);
        _controller.animation!.addListener(onScroll);
      });
    } else if (widget.initPosition != null) {
      _controller.animateTo(widget.initPosition!);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.animation!.removeListener(onScroll);
    _controller.removeListener(onPositionChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount < 1) return widget.stub ?? Container();

    return Align(
      alignment: Alignment.topCenter,
      child: TabBar(
        isScrollable: true,
        controller: _controller,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).hintColor,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
        tabs: List.generate(
          widget.itemCount,
          (index) => widget.tabBuilder(context, index),
        ),
      ),
    );
  }

  onPositionChange() {
    if (!_controller.indexIsChanging) {
      _currentPosition = _controller.index;
      if (widget.onPositionChange is ValueChanged<int>) {
        widget.onPositionChange!(_currentPosition);
      }
    }
  }

  onScroll() {
    if (widget.onScroll is ValueChanged<double>) {
      widget.onScroll!(_controller.animation!.value);
    }
  }
}
