import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/listing_provider.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController mapController = MapController();
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _loadListingsOnMap();
  }

  void _loadListingsOnMap() {
    final listings = Provider.of<ListingProvider>(context, listen: false).listings;
    setState(() {
      markers = listings.map((listing) {
        return Marker(
          point: LatLng(listing.latitude, listing.longitude),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/listingDetail',
                arguments: listing,
              );
            },
            onLongPress: () {
              LocationService.openLocationInMaps(
                latitude: listing.latitude,
                longitude: listing.longitude,
                label: listing.name,
              );
            },
            child: Tooltip(
              message: '${listing.name}\nLong-press to open on map',
              child: Icon(
                Icons.location_on,
                color: AppTheme.accentGold,
                size: 40,
              ),
            ),
          ),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        elevation: 0,
      ),
      body: Consumer<ListingProvider>(
        builder: (context, provider, _) {
          if (provider.listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 80,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No listings to display',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: const MapOptions(
                  initialCenter: LatLng(-1.9536, 29.8739), // Kigali coordinates
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kigali.resto_kigali',
                  ),
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.small(
                  backgroundColor: AppTheme.accentGold,
                  onPressed: _refreshMarkers,
                  child: const Icon(Icons.refresh, color: AppTheme.surfaceDark),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _refreshMarkers() {
    _loadListingsOnMap();
  }
}
