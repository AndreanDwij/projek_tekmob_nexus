import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../shared/enums.dart';
import '../report/report_model.dart';
import 'map_provider.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mapProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<ReportModel> reports) {
    return reports.map((report) {
      return Marker(
        markerId: MarkerId(report.id),
        position: LatLng(report.latitude, report.longitude),
        infoWindow: InfoWindow(
          title: report.category.label,
          snippet: report.description,
          onTap: () => context.go('/report/detail/${report.id}'),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(report.category),
        ),
      );
    }).toSet();
  }

  double _getMarkerHue(ReportCategory category) {
    switch (category) {
      case ReportCategory.sampah:
        return BitmapDescriptor.hueOrange;
      case ReportCategory.drainase:
        return BitmapDescriptor.hueBlue;
      case ReportCategory.jalan:
        return BitmapDescriptor.hueAzure;
      case ReportCategory.pohon:
        return BitmapDescriptor.hueGreen;
      case ReportCategory.polusi:
        return BitmapDescriptor.hueRed;
      case ReportCategory.lainnya:
        return BitmapDescriptor.hueViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          if (state.isLoading)
            const LoadingIndicator()
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  state.currentLatitude ?? AppConstants.defaultLatitude,
                  state.currentLongitude ?? AppConstants.defaultLongitude,
                ),
                zoom: 13,
              ),
              markers: _buildMarkers(state.filteredReports),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            ),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(null, 'Semua', state.selectedCategory == null),
                  ...ReportCategory.values.map(
                    (cat) => _buildFilterChip(
                      cat,
                      cat.label,
                      state.selectedCategory == cat,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.xxl,
            right: AppSpacing.md,
            child: FloatingActionButton(
              onPressed: () => context.go('/report/create'),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ReportCategory? category, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(mapProvider.notifier).filterByCategory(category);
        },
      ),
    );
  }
}
