import 'package:flutter/material.dart';

class LeftAlignedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final EdgeInsets padding;

  const LeftAlignedText({
    Key? key,
    required this.text,
    required this.style,
    this.padding = const EdgeInsets.fromLTRB(10, 10, 10, 5), // 기본 패딩을 EdgeInsets.all(10)으로 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: style,
        ),
      ),
    );
  }
}
