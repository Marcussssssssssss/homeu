import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSelectionScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapSelectionScreen({super.key, this.initialLocation});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  LatLng? _pickedLocation;

  final LatLng _defaultCenter = const LatLng(3.1390, 101.6869);

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tap to drop a pin'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F314F),
        actions: [
          if (_pickedLocation != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
              icon: const Icon(Icons.check, color: Color(0xFF1E3A8A)),
              label: const Text(
                'Confirm',
                style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _pickedLocation ?? _defaultCenter,
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            setState(() {
              _pickedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.homeu.app',
          ),
          if (_pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _pickedLocation!,
                  width: 50,
                  height: 50,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFC53030),
                    size: 45,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}