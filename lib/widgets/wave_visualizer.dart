import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:flutter/material.dart';

class WaveVisualizer extends StatelessWidget {
  WaveVisualizer({
    Key? key,
    required this.columnHeight,
    required this.columnWidth,
  }) : super(key: key);

  final double columnHeight;
  final double columnWidth;

  final List<int> duration = [900, 700, 600, 800, 500];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(
        10,
        (index) => VisualComponent(
          width: columnWidth,
          height: columnHeight,
          duration: duration[index % 5],
          color: index % 2 == 0 ? CustomColors.black : Colors.black26,
        ),
      ),
    );
  }
}

class VisualComponent extends StatefulWidget {
  const VisualComponent({
    Key? key,
    required this.duration,
    required this.color,
    required this.height,
    required this.width,
  }) : super(key: key);

  final int duration;
  final Color color;
  final double height;
  final double width;

  @override
  State<VisualComponent> createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  late final Animation<double> animation;
  late final AnimationController animController;

  @override
  void initState() {
    animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );

    final curvedAnimation = CurvedAnimation(
      parent: animController,
      curve: Curves.easeInOutSine,
    );

    animation = Tween<double>(
      begin: 0,
      end: widget.height,
    ).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });
    animController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: animation.value,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
