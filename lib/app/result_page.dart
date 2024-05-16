import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  @override
  void initState() {


  }

  @override
  void dispose() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children:[
            Container(
              color: Color.fromARGB(255, 25, 15, 15),
            ),
            const MapBottomSheet()
          ]

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
        onVerticalDragUpdate: (details) {
          double? delta = details.primaryDelta;
          if (delta != null) {
            if (_longAnimation ||
                (_height <= _lowLimit && delta > 0) ||
                (_height >= _highLimit && delta < 0)) return;
            setState(() {
              if (_upThresh <= _height && _height <= _boundary) {
                _height = _highLimit;
                _longAnimation = true;
              } else if (_boundary <= _height && _height <= _downThresh) {
                _height = _lowLimit;
                _longAnimation = true;
              } else {
                _height -= delta;
              }
            });
          }
        },
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          width: MediaQuery.of(context).size.width,
          height: _height,
          child: SingleChildScrollView(
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
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '추천 데이트 코스',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '편집',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: places.length + travelTimes.length,
                  itemBuilder: (context, index) {
                    if (index % 2 == 0) {
                      int placeIndex = index ~/ 2;
                      return _buildPlaceItemWithTime(
                        icon: icons[placeIndex],
                        title: places[placeIndex],
                        address: addresses[placeIndex],
                        time: placeIndex == 0 ? '' : travelTimes[placeIndex - 1], // Add time for all except the first item
                      );
                    } else {
                      return SizedBox.shrink(); // Empty widget for odd indices, no need for travel time row anymore
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.directions_walk),
                    label: Text('이동시간 48분'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
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
                Icon(Icons.directions_walk, color: Colors.grey),
                SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey)),
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