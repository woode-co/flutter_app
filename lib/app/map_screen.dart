import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194); // Default to San Francisco
  late LatLng _lastMapPosition;
  late Marker _marker;
  bool _isMapCreated = false;

  @override
  void initState() {
    super.initState();
    _lastMapPosition = _initialPosition;
    _marker = Marker(
      markerId: const MarkerId('selected-location'),
      position: _initialPosition,
      draggable: true,
      onDragEnd: (LatLng newPosition) {
        setState(() {
          _lastMapPosition = newPosition;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
      ),
      body: _isMapCreated
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10.0,
              ),
              markers: {_marker},
              onCameraMove: _onCameraMove,
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmLocation,
        tooltip: 'Confirm Location',
        child: const Icon(Icons.check),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _isMapCreated = true;
    });
  }

  void _onCameraMove(CameraPosition position) {
    if (_isMapCreated) {
      setState(() {
        _marker = Marker(
          markerId: const MarkerId('selected-location'),
          position: position.target,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _lastMapPosition = newPosition;
            });
          },
        );
      });
    }
  }

  void _confirmLocation() {
    // Handle location confirmation logic here
    print('Selected location: ${_lastMapPosition.latitude}, ${_lastMapPosition.longitude}');
    }
}
