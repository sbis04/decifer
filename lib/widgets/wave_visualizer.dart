import 'package:deepgram_transcribe/res/custom_colors.dart';
import 'package:flutter/material.dart';

class WaveVisualizer extends StatelessWidget {
  WaveVisualizer({
    Key? key,
    required this.columnHeight,
    required this.columnWidth,
    this.isPaused = true,
    this.widthFactor = 1,
    this.isBarVisible = true,
    this.color = CustomColors.black,
  }) : super(key: key);

  final double columnHeight;
  final double columnWidth;
  final bool isPaused;
  final double widthFactor;
  final bool isBarVisible;
  final Color color;

  final List<int> duration = [900, 700, 600, 800, 500];

  @override
  Widget build(BuildContext context) {
    final List<double> initialHeight = [
      columnHeight / 3,
      columnHeight / 1.5,
      columnHeight,
      columnHeight / 1.5,
      columnHeight / 3
    ];
    return Stack(
      children: [
        SizedBox(
          height: columnHeight,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(
                  10,
                  (index) => VisualComponent(
                    width: columnWidth,
                    height: columnHeight,
                    duration: duration[index % 5],
                    initialHeight: isPaused ? initialHeight[index % 5] : null,
                    color: index % 2 == 0
                        ? color.withOpacity(0.1)
                        : color.withOpacity(0.03),
                  ),
                ),
              ),
              isBarVisible
                  ? Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: double.maxFinite,
                        height: 4,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        SizedBox(
          height: columnHeight,
          child: ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List<Widget>.generate(
                      10,
                      (index) => VisualComponent(
                        width: columnWidth,
                        height: columnHeight,
                        duration: duration[index % 5],
                        initialHeight:
                            isPaused ? initialHeight[index % 5] : null,
                        color: index % 2 == 0
                            ? color
                            : color.withOpacity(0.3),
                      ),
                    ),
                  ),
                  isBarVisible
                      ? Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            width: double.maxFinite,
                            height: 4,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ],
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
    this.initialHeight,
  }) : super(key: key);

  final int duration;
  final Color color;
  final double height;
  final double width;
  final double? initialHeight;

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
      curve: Curves.easeInOut,
    );

    animation = Tween<double>(
      begin: 20,
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
      height: widget.initialHeight ?? animation.value,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
