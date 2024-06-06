import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'result_map.dart';

class ResultPage extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultPage({Key? key, required this.result}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
          ResultMap(result: widget.result),
          MapBottomSheet(result: widget.result),
        ]));
  }
}

class MapBottomSheet extends StatefulWidget {
  final Map<String, dynamic> result;

  const MapBottomSheet({Key? key, required this.result}) : super(key: key);

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  late double _height;
  late double _startHeight;

  final double _lowLimit = 100;
  final double _highLimit = 800;

  @override
  void initState() {
    super.initState();
    _height = _lowLimit;
  }

  Future<List<String>> _fetchAddresses(List<LatLng> latLngs) async {
    return await Future.wait(latLngs.map((latLng) => _getAddressFromLatLng(latLng)).toList());
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    const String apiKey = 'AIzaSyCJavimIFYZyiAVYixMbLIHQlao--W0DTw';  // Replace with your Google Maps API key
    final String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey&language=ko';

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

  IconData getIconFromPlace(String category) {
    switch (category) {
      case 'cafe':
        return Icons.local_cafe;
      case 'landmark':
        return Icons.location_city;
      case 'food':
        return Icons.restaurant;
      case 'culture':
        return Icons.museum;
      default:
        return Icons.place; // Default icon if no match is found
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> itinerary = List<Map<String, dynamic>>.from(widget.result['itinerary']);
    List<LatLng> latLngs = itinerary.map<LatLng>((item) => LatLng(item['x'], item['y'])).toList();  // Note: LatLng uses (latitude, longitude)
    List<String> places = itinerary.map<String>((item) => item['location'] as String).toList();
    List<IconData> icons = List.generate(places.length, (index) => getIconFromPlace(itinerary[index]['category']));  // Placeholder icons
    List<int> travelTimes = List<int>.from(widget.result['durations']);

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
          child: FutureBuilder<List<String>>(
            future: _fetchAddresses(latLngs),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load addresses'));
              } else {
                List<String> addresses = snapshot.data ?? [];
                return Column(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                        ? ' '
                                        : '${travelTimes[placeIndex - 1]}분', // Add time for all except the first item
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
                                label: Text('이동시간 ${travelTimes.reduce((a, b) => a + b)}분'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(height:10),
                          ],

                        ),
                      ),
                    ),
                  ],
                );
              }
            },
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,0,0,10),
      child: Row(
        children: [
          if (time != ' ')
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Column(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.grey),
                  const SizedBox(height: 4),
                  Container(
                    width: 40, // 고정된 가로 너비를 설정
                    alignment: Alignment.center,
                    child: Text(
                      time,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          if(time == ' ')
            SizedBox(width: 50),
          Expanded(
            child: ListTile(
              leading: Icon(icon, color: Colors.red),
              title: Text(title),
              subtitle: Text(address),
            ),
          ),
        ],
      ),
    );
  }
}
