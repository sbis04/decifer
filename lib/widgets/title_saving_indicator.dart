import 'package:flutter/material.dart';

class TitleSavingIndicator extends StatelessWidget {
  const TitleSavingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
              strokeWidth: 2,
            ),
          ),
        ),
      ],
    );
  }
}
