import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  final LatLng _initialPosition = const LatLng(37.5642, 127.0016); // Default to a location
  late LatLng _lastMapPosition;
  bool _isMapCreated = false;

  @override
  void initState() {
    super.initState();
    _lastMapPosition = _initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15.0,
            ),
            markers: {_createMarker()},
            onCameraMove: _onCameraMove,
          ),
          if (!_isMapCreated)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
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
        _lastMapPosition = position.target;
      });
    }
  }

  Marker _createMarker() {
    return Marker(
      markerId: const MarkerId('selected-location'),
      position: _lastMapPosition,
      draggable: true,
      onDragEnd: (LatLng newPosition) {
        setState(() {
          _lastMapPosition = newPosition;
        });
      },
    );
  }

  void _confirmLocation() {
    // Return the selected location to the previous screen
    Navigator.pop(context, _lastMapPosition);
  }
}
