import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapSelectionScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapSelectionScreen({super.key, this.initialLocation});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  LatLng? _pickedLocation;
  String? _pickedAddress;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isFetchingAddress = false;

  final LatLng _defaultCenter = const LatLng(3.1390, 101.6869);

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    if (_pickedLocation != null) {
      _getAddressFromLatLng(_pickedLocation!);
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'HomeU_App/1.0 (contact@homeu.com)'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final displayName = data[0]['display_name'];

          final newPos = LatLng(lat, lon);
          setState(() {
            _pickedLocation = newPos;
            _pickedAddress = displayName;
            _searchController.text = displayName;
          });
          _mapController.move(newPos, 15.0);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Address not found')));
        }
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng point) async {
    setState(() => _isFetchingAddress = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'HomeU_App/1.0 (contact@homeu.com)'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          setState(() {
            _pickedAddress = data['display_name'];
            _searchController.text = data['display_name'];
          });
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    } finally {
      if (mounted) setState(() => _isFetchingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F314F),
        actions: [
          if (_pickedLocation != null)
            TextButton.icon(
              onPressed: _isFetchingAddress
                  ? null
                  : () {
                Navigator.of(context).pop({
                  'location': _pickedLocation,
                  'address': _pickedAddress
                });
              },
              icon: const Icon(Icons.check, color: Color(0xFF1E3A8A)),
              label: const Text(
                'Confirm',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation ?? _defaultCenter,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _pickedLocation = point;
                  _pickedAddress = null;
                });
                _getAddressFromLatLng(point);
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

          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search address or building...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1E3A8A),
                  ),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF1E3A8A),
                          ),
                          onPressed: () =>
                              _searchAddress(_searchController.text),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: _searchAddress,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
