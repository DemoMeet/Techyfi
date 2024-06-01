import 'package:flutter/material.dart';

class ScanningAnimation extends StatefulWidget {
  @override
  _ScanningAnimationState createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/qrcode.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: 0,
                child: Container(
                  height: 5,
                  width: 150,
                  color: Colors.blue,
                  margin: EdgeInsets.only(
                    top: 160 * _animation.value * 0.9,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
