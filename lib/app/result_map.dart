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
  }

  void _initMarkersAndRoute() {
    final itinerary = widget.result['itinerary'];
    print('Initializing markers and route with itinerary: $itinerary');
    final coordinates = widget.result['coordinates'];
    for (var coordinate in coordinates){
      polylineCoordinates.add(LatLng(coordinate[1], coordinate[0]));
    }
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