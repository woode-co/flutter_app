import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final bool userSex;
  final List<bool> userTastes;
  const MainPage({
    Key? key,
    required this.userSex,
    required this.userTastes,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xffFFD7D7),
                ]
              )
            ),
            child:Center(
              child: IconButton(
                icon: Image.asset('assets/woodeco_logo.png'),
                iconSize: 40,
                onPressed: (){
                },
              ),
            )
          ),
          const MapBottomSheet()
        ],
      )
    );
  }
}

class MapBottomSheet extends StatefulWidget {
  const MapBottomSheet({super.key});

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  late double _height;

  final double _lowLimit = 50;
  final double _highLimit = 600;
  final double _upThresh = 100;
  final double _boundary = 500;
  final double _downThresh = 550;

  /// 100 -> 600, 550 -> 100 으로 애니메이션이 진행 될 때,
  /// 드래그로 인한 _height의 변화 방지
  bool _longAnimation = false;

  @override
  void initState() {
    super.initState();
    _height = _lowLimit;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0.0,
        child: GestureDetector(
            onVerticalDragUpdate: ((details) {

              // delta: y축의 변화량, 우리가 보기에 위로 움직이면 양의 값, 아래로 움직이면 음의 값
              double? delta = details.primaryDelta;
              if (delta != null) {

                /// Long Animation이 진행 되고 있을 때는 드래그로 높이 변화 방지, 
                /// 그리고 low limit 보다 작을 때 delta가 양수,
                /// High limit 보다 크거나 같을 때 delta가 음수이면 드래그로 높이 변화 방지
                if (_longAnimation ||
                    (_height <= _lowLimit && delta > 0) ||
                    (_height >= _highLimit && delta < 0)) return;
                setState(() {
                  /// 600으로 높이 설정
                  if (_upThresh <= _height && _height <= _boundary) {
                    _height = _highLimit;
                    _longAnimation = true;
                  } 
                  /// 100으로 높이 설정
                  else if (_boundary <= _height && _height <= _downThresh) {
                    _height = _lowLimit;
                    _longAnimation = true;
                  } 
                  /// 기본 작동
                  else {
                    _height -= delta;
                  }
                });
              }
            }),
            child: AnimatedContainer(
              curve: Curves.bounceOut,
              onEnd: () {
                if (_longAnimation) {
                  setState(() {
                    _longAnimation = false;
                  });
                }
              },
              duration: const Duration(milliseconds: 400),
              decoration: const BoxDecoration(
                  boxShadow: [BoxShadow(blurRadius: 6, spreadRadius: 0.7)],
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              width: MediaQuery.of(context).size.width,
              height: _height,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 70,
                    height: 4.5,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    
                  ),
                ],
              ),
            )));
  }
}