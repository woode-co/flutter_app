import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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
  bool _isButtonPressed = false;

  void _togleButton() {
    setState(() {
      _isButtonPressed = !_isButtonPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.white,
                  Color(0xffFFD7D7),
                ])),
          ),
          Center(
            child: IconButton(
              icon: Image.asset('assets/woodeco_logo.png'),
              iconSize: 40,
              onPressed: _togleButton,
            ),
          ),
          if (_isButtonPressed)
            const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 300),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'AI에게 추천받는 중',
                      style: TextStyle(fontSize: 16),
                    ),
                  ]),
            ),
          if (!_isButtonPressed)
            const Center(
              child: Column(children: [
                SizedBox(height: 300),
                SizedBox(height: 20),
                SizedBox(height: 10),
                Text(
                  '터치하여 데이트하기',
                  style: TextStyle(fontSize: 16),
                ),
              ]),
            ),
          if (!_isButtonPressed) const MapBottomSheet(),
        ],
      ),
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
  late double _startHeight;

  final double _lowLimit = 100;
  final double _highLimit = 800;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  final TextEditingController _locationController = TextEditingController();

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

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    '설정',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Location Selection
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                hintText: 'Location',
                                labelText: '현재 위치',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // Location search logic
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Date Selection
                      const Text(
                        '데이트할 날짜를 선택해 주세요!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Time Selection
                      const Text(
                        '데이트 시간을 정해주세요!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text('시작 시간: ${_startTime.format(context)}'),
                              ElevatedButton(
                                onPressed: () => _selectTime(context, true),
                                child: const Text('Select Start Time'),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('끝나는 시간: ${_endTime.format(context)}'),
                              ElevatedButton(
                                onPressed: () => _selectTime(context, false),
                                child: const Text('Select End Time'),
                              ),
                            ],
                          ),
                        ],
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
}
