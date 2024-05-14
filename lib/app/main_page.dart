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
          ),
          Center(
            child: IconButton(
              icon: Image.asset('assets/woodeco_logo.png'),
              iconSize: 40,
              onPressed: (){
              },
            ),
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

  bool _longAnimation = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 18, minute: 0);
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _height = _lowLimit;
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
              
              // Location Selection
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Location',
                        labelText: '현재 위치',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Location search logic
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              
              // Date Selection
              Text('데이트할 날짜를 선택해 주세요!'),
              Row(
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              
              // Time Selection
              Text('데이트 시간을 정해주세요!'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('시작 시간: ${_startTime.format(context)}'),
                      ElevatedButton(
                        onPressed: () => _selectTime(context, true),
                        child: Text('Select Start Time'),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('끝나는 시간: ${_endTime.format(context)}'),
                      ElevatedButton(
                        onPressed: () => _selectTime(context, false),
                        child: Text('Select End Time'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
