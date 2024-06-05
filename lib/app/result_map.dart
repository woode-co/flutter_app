import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultMap extends StatefulWidget {
  const ResultMap({super.key});

  @override
  _ResultMapState createState() => _ResultMapState();
}

class _ResultMapState extends State<ResultMap> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  final List<Map<String, dynamic>> itinerary = [
    {
      "time": "14:00",
      "category": "landmark",
      "location": "신촌피아노거리",
      "x": 37.5557360489237,
      "y": 126.936950881804
    },
    {
      "time": "16:00",
      "category": "culture",
      "location": "서강대학교 박물관",
      "x": 37.5500895389708,
      "y": 126.938745912487
    },
    {
      "time": "18:30",
      "category": "food",
      "location": "독립문설렁탕1897",
      "x": 37.5577401213122,
      "y": 126.937429062935
    },
    {
      "time": "19:30",
      "category": "cafe",
      "location": "바나프레소 신촌점",
      "x": 37.5575294173655,
      "y": 126.93767370034
    }
  ];

  @override
  void initState() {
    super.initState();
    _initMarkersAndRoute();
  }

  void _initMarkersAndRoute() {
    for (var point in itinerary) {
      final marker = Marker(
        markerId: MarkerId(point['location']),
        position: LatLng(point['x'], point['y']),
        infoWindow: InfoWindow(title: point['location']),
      );
      _markers.add(marker);
      _routePoints.add(LatLng(point['x'], point['y']));
    }
    _getRoute();
  }

  Future<void> _getRoute() async {
    const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${_routePoints.first.latitude},${_routePoints.first.longitude}'
        '&destination=${_routePoints.last.latitude},${_routePoints.last.longitude}'
        '&waypoints=optimize:true|${_routePoints.skip(1).take(_routePoints.length - 2).map((e) => '${e.latitude},${e.longitude}').join('|')}'
        '&mode=walking'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      print('Failed to load directions');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Google Maps Example'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(itinerary[0]['x'], itinerary[0]['y']),
          zoom: 14,
        ),
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}