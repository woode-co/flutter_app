import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {}

  @override
  void dispose() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        color: const Color.fromARGB(255, 25, 15, 15),
      ),
      const MapBottomSheet()
    ]));
  }
}

class MapBottomSheet extends StatefulWidget {
  const MapBottomSheet({super.key});

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  late double _height;
  late double _startHeight;

  final double _lowLimit = 100;
  final double _highLimit = 800;

  List<String> places = ["현재 위치", "동대문엽기떡볶이 본점", "청계천", "스타벅스 광화문점"];
  List<String> addresses = [
    "서울특별시 중구 퇴계로 75길 7",
    "서울특별시 중구 퇴계로 75길 8",
    "서울특별시 종로구",
    "서울특별시 종로구 세종대로 167"
  ];
  List<IconData> icons = [
    Icons.my_location,
    Icons.local_dining,
    Icons.park,
    Icons.local_cafe
  ];
  List<String> travelTimes = ["3분", "2분", "43분"];

  final bool _longAnimation = false;

  @override
  void initState() {
    super.initState();
    _height = _lowLimit;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _height = MediaQuery.of(context).size.height - details.globalPosition.dy;
      if (_height < _lowLimit) {
        _height = _lowLimit;
      } else if (_height > _highLimit) {
        _height = _highLimit;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      if (_height < (MediaQuery.of(context).size.height / 2)) {
        _height = _lowLimit;
      } else {
        _height = _highLimit;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      child: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), // 애니메이션 시간 설정
          curve: Curves.easeInOut,
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 6, spreadRadius: 0.7)],
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          width: MediaQuery.of(context).size.width,
          height: _height,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 70,
                height: 4.5,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '추천 데이트 코스',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '편집',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: places.length + travelTimes.length,
                        itemBuilder: (context, index) {
                          if (index % 2 == 0) {
                            int placeIndex = index ~/ 2;
                            return _buildPlaceItemWithTime(
                              icon: icons[placeIndex],
                              title: places[placeIndex],
                              address: addresses[placeIndex],
                              time: placeIndex == 0
                                  ? ''
                                  : travelTimes[placeIndex -
                                      1], // Add time for all except the first item
                            );
                          } else {
                            return const SizedBox
                                .shrink(); // Empty widget for odd indices, no need for travel time row anymore
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.directions_walk),
                          label: const Text('이동시간 48분'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceItemWithTime({
    required IconData icon,
    required String title,
    required String address,
    required String time,
  }) {
    return Row(
      children: [
        if (time.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const Icon(Icons.directions_walk, color: Colors.grey),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        Expanded(
          child: ListTile(
            leading: Icon(icon, color: Colors.red),
            title: Text(title),
            subtitle: Text(address),
          ),
        ),
      ],
    );
  }
}
