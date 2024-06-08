import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:woodeco/app/token_manager.dart' as woodeco_token_manager;
import 'package:http/http.dart' as http;
import 'map_screen.dart'; // Import the MapScreen file
import 'package:woodeco/app/result_page.dart';
import 'package:time_range_picker/time_range_picker.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isButtonPressed = false;
  LatLng _currentPosition = const LatLng(37.5642, 127.0016); // Default to Seoul
  final TextEditingController _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _updateLocationText();
    });
  }

  void _toggleButton() {
    setState(() {
      _isButtonPressed = !_isButtonPressed;
      if (_isButtonPressed) {
        _sendPostRequest();
      }
    });
  }

  Future<void> _sendPostRequest() async {
    String? userId = woodeco_token_manager.TokenManager.instance.accessToken;
    if (userId == null) {
      print("No access token available");
      return;
    }
    final response = await http.post(
      Uri.parse('http://49.247.34.221:8000/recsys'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'start_t': _startTime.format(context),
        'end_t': _endTime.format(context),
        'curr_x': _currentPosition.latitude,
        'curr_y': _currentPosition.longitude,
      }),
    );

    if (response.statusCode == 200) {
      print('Request successful');
      Map<String, dynamic> result = jsonDecode(utf8.decode(response.bodyBytes));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultPage(result: result),
        ),
      );
      _isButtonPressed = !_isButtonPressed;
    } else {
      print('Request failed with status: ${response.statusCode}');
      _isButtonPressed = !_isButtonPressed;
    }
  }

  void _updateLocationText() async {
    String address = await _getAddressFromLatLng(_currentPosition);
    setState(() {
      _locationController.text = address;
    });
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    const String apiKey =
        'AIzaSyCJavimIFYZyiAVYixMbLIHQlao--W0DTw'; // Replace with your Google Maps API key
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey&language=ko';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return data['results'][0]['formatted_address'];
      } else {
        return 'No address available';
      }
    } else {
      throw Exception('Failed to load address');
    }
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

  Future<void> _selectLocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
    if (result != null) {
      setState(() {
        _currentPosition = result as LatLng; // 상태 변수 업데이트
        _updateLocationText();
      });
    }
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
              onPressed: _toggleButton,
            ),
          ),
          if (_isButtonPressed)
            const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 300),
                    SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: Color.fromARGB(255, 255, 164, 157),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'AI에게 추천받는 중',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ]),
            ),
          if (!_isButtonPressed)
            const Center(
              child: Column(children: [
                SizedBox(height: 290),
                Text(
                  '터치하여 데이트하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          if (!_isButtonPressed)
            MapBottomSheet(
                currentPosition: _currentPosition,
                locationController: _locationController,
                selectedDate: _selectedDate,
                startTime: _startTime,
                endTime: _endTime,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                onStartTimeChanged: (time) {
                  setState(() {
                    _startTime = time;
                  });
                },
                onEndTimeChanged: (time) {
                  setState(() {
                    _endTime = time;
                  });
                },
                onLocationChanged: (position) {
                  setState(() {
                    _currentPosition = position;
                    _updateLocationText();
                  });
                }),
        ],
      ),
    );
  }
}

class MapBottomSheet extends StatefulWidget {
  final LatLng currentPosition;
  final TextEditingController locationController;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;
  final ValueChanged<LatLng> onLocationChanged;

  const MapBottomSheet({
    Key? key,
    required this.currentPosition,
    required this.locationController,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.onDateChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  late double _height;
  late double _startHeight;

  final double _lowLimit = 100;
  final double _highLimit = 500;

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
      initialDate: widget.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.selectedDate) {
      widget.onDateChanged(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeRange? result = await showTimeRangePicker(
      context: context,
      ticks: 12,
      ticksColor: Colors.grey,
      ticksOffset: -12,
      strokeColor: const Color.fromARGB(255, 255, 175, 175),
      handlerColor: const Color.fromARGB(255, 255, 147, 147),
      selectedColor: const Color.fromARGB(255, 251, 146, 146),
      start: widget.startTime,
      end: widget.endTime,
      minDuration: const Duration(hours: 2),
      maxDuration: const Duration(hours: 8),
      labels: ["24 h", "3 h", "6 h", "9 h", "12 h", "15 h", "18 h", "21 h"]
          .asMap()
          .entries
          .map((e) {
        return ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value);
      }).toList(),
      labelOffset: -30,
      disabledTime: TimeRange(
          startTime: const TimeOfDay(hour: 22, minute: 0),
          endTime: const TimeOfDay(hour: 5, minute: 0)),
      disabledColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
    );
    if (result != null) {
      widget.onStartTimeChanged(result.startTime);
      widget.onEndTimeChanged(result.endTime);
    }

    print("result $result");
  }

  Future<void> _selectLocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
    if (result != null) {
      widget.onLocationChanged(result as LatLng);
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
                      IconButton(
                        icon: const Icon(Icons.map,
                            color: Color.fromARGB(255, 255, 148, 148),
                            size: 100),
                        onPressed: () => _selectLocation(context),
                      ),

                      TextField(
                        controller: widget.locationController,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: '데이트 장소',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 255, 165, 165))),
                        ),
                        readOnly: true,
                      ),

                      const SizedBox(height: 16.0),

                      // Date Selection

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.calendar_today,
                                      color: Color.fromARGB(255, 255, 148, 148),
                                      size: 100),
                                  onPressed: () => _selectDate(context),
                                ),
                                Text(DateFormat('   yyyy년\nMM월 dd일')
                                    .format(widget.selectedDate),style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.access_time,
                                    color: Color.fromARGB(255, 255, 148, 148),
                                    size: 100),
                                onPressed: () => _selectTime(context),
                              ),
                              Text('FROM ${widget.startTime.format(context)}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              Text('TO ${widget.endTime.format(context)}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                            ],
                          ))
                        ],
                      ),

                      // Time Selection
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
