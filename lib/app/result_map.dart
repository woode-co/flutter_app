import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
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
    }
    print('Markers initialized: $_markers');
    print('Route points initialized: $_routePoints');
  }

  void getPolyPoints() async {
    for (int i = 0; i < _routePoints.length - 1; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(_routePoints[i].latitude, _routePoints[i].longitude),
        PointLatLng(_routePoints[i + 1].latitude, _routePoints[i + 1].longitude),
        travelMode: TravelMode.walking,
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
    }

    setState(() {});
    print('Polyline coordinates: $polylineCoordinates');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Google Maps Example'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _controller.complete(controller);
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.result['itinerary'][0]['x'], widget.result['itinerary'][0]['y']),
          zoom: 14,
        ),
        markers: _markers,
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
      ),
    );
  }
}
