import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A custom loading indicator widget with different types of animations.
///
/// This widget provides a loading indicator with three types of animations:
/// 1. Smile animation.
/// 2. Icon animation.
/// 3. Normal loading animation with text.
class CustomLoading extends StatefulWidget {
  /// Creates a [CustomLoading] widget.
  ///
  /// The [type] parameter specifies the type of loading animation to display.
  /// - 0: Smile animation.
  /// - 1: Icon animation.
  /// - 2: Normal loading animation with text.
  const CustomLoading({Key? key, this.type = 0}) : super(key: key);

  /// The type of loading animation to display.
  final int type;

  @override
  _CustomLoadingState createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the loading indicator based on the specified [type].
    return Stack(children: [
      Visibility(visible: widget.type == 0, child: _buildLoadingOne()),
      Visibility(visible: widget.type == 1, child: _buildLoadingTwo()),
      Visibility(visible: widget.type == 2, child: _buildLoadingThree()),
    ]);
  }

  /// Builds the smile animation loading indicator.
  Widget _buildLoadingOne() {
    return Stack(alignment: Alignment.center, children: [
      RotationTransition(
        alignment: Alignment.center,
        turns: _controller,
        child: Image.network(
          'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101174606.png',
          height: 110,
          width: 110,
        ),
      ),
      Image.network(
        'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101181404.png',
        height: 60,
        width: 60,
      ),
    ]);
  }

  /// Builds the icon animation loading indicator.
  Widget _buildLoadingTwo() {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/images/tomato-icon.png',
        height: 50,
        width: 50,
      ),
      RotationTransition(
        alignment: Alignment.center,
        turns: _controller,
        child: Image.network(
          'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101173708.png',
          height: 80,
          width: 80,
        ),
      ),
    ]);
  }

  /// Builds the normal loading animation with text.
  Widget _buildLoadingThree() {
    return Center(
      child: Container(
        height: 120,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RotationTransition(
            alignment: Alignment.center,
            turns: _controller,
            child: Image.network(
              'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101163010.png',
              height: 50,
              width: 50,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text('Loading...'),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
