import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ResultMap extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultMap({super.key, required this.result});

  @override
  _ResultMapState createState() => _ResultMapState();
}

class _ResultMapState extends State<ResultMap> {
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final List<LatLng> _routePoints = [];
  final List<String> _routeNames = [];
  List<LatLng> polylineCoordinates = [];
  String googleApiKey = 'AIzaSyCJavimIFYZyiAVYixMbLIHQlao--W0DTw'; // Replace with your Google Map Key

  @override
  void initState() {
    super.initState();
    _initMarkersAndRoute();
    getPolyPoints();
  }

  void _initMarkersAndRoute() {
    final itinerary = widget.result['itinerary'];
    print('Initializing markers and route with itinerary: $itinerary');

    for (var point in itinerary) {
      final marker = Marker(
        markerId: MarkerId(point['location']),
        position: LatLng(point['x'], point['y']), // Note: LatLng uses (latitude, longitude)
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: point['location']),
      );
      _markers.add(marker);
      _routePoints.add(LatLng(point['x'], point['y'])); // Note: LatLng uses (latitude, longitude)
      _routeNames.add(point['location']);
    }
    print('Markers initialized: $_markers');
    print('Route points initialized: $_routePoints');
  }

  Future<void> getPolyPoints() async {
    final List<LatLng> newPolylineCoordinates = [];

    try {
      for (int i = 0; i < _routePoints.length - 1; i++) {
        final response = await http.get(
          Uri.parse(
            'https://maps.googleapis.com/maps/api/directions/json'
                '?origin=${_routePoints[i].latitude},${_routePoints[i].longitude}'
                '&destination=${_routePoints[i + 1].latitude},${_routePoints[i + 1].longitude}'
                '&mode=transit'
                '&key=$googleApiKey',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            final points = data['routes'][0]['overview_polyline']['points'];
            final path = decodePolyline(points);
            newPolylineCoordinates.addAll(path);
          } else {
            print('No route found between ${_routePoints[i]} and ${_routePoints[i + 1]}');
          }
        } else {
          throw Exception('Failed to load directions');
        }
      }

      if (newPolylineCoordinates.isEmpty) {
        _showNoRouteFoundDialog();
      } else {
        setState(() {
          polylineCoordinates = newPolylineCoordinates;
        });
      }
    } catch (e) {
      print('Error fetching polyline points: $e');
      _showErrorDialog(e.toString());
    }

    print('Polyline coordinates: $polylineCoordinates');
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng point = LatLng((lat / 1E5), (lng / 1E5));
      polyline.add(point);
    }

    return polyline;
  }

  void _showNoRouteFoundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('경로 없음'),
          content: const Text('지정된 위치들 간에 경로를 찾을 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('에러'),
          content: Text('오류가 발생했습니다: $message'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          _controller.complete(controller);
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.result['itinerary'][0]['x'], widget.result['itinerary'][0]['y']),
          zoom: 15,
        ),
        markers: _markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: const Color.fromARGB(255, 255, 150, 150),
            width: 5,
          ),
        },
      ),
    );
  }
}
