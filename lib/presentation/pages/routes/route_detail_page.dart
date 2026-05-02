import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/classical_app_bar.dart';
import '../../../domain/enums/route_difficulty.dart';
import '../../providers/routes_providers.dart';

class RouteDetailPage extends ConsumerWidget {
  final int routeId;

  const RouteDetailPage({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeDetailProvider(routeId));
    final stopsAsync = ref.watch(routeStopsProvider(routeId));

    return Scaffold(
      appBar: const ClassicalAppBar(title: '路线详情'),
      body: routeAsync.when(
        data: (route) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route header
              Text(
                route.name,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _InfoChip(
                      icon: Icons.schedule, text: '${route.estimatedDays}天'),
                  const SizedBox(width: 12),
                  _InfoChip(
                      icon: Icons.terrain, text: route.difficulty.label),
                ],
              ),
              if (route.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  route.description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
              if (route.coverStory != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    route.coverStory!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],

              // Route map preview
              const SizedBox(height: 24),
              Text(
                '路线地图',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              stopsAsync.when(
                data: (routeWithStops) => _RouteMapPreview(
                  stops: routeWithStops.stops,
                ),
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),

              // Stops list
              const SizedBox(height: 24),
              Text(
                '路线站点',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              stopsAsync.when(
                data: (routeWithStops) => _buildStopsList(context, routeWithStops.stops),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                error: (e, _) => Text('加载站点失败: $e'),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  Widget _buildStopsList(BuildContext context, List<RouteStopWithDetails> stops) {
    return Column(
      children: [
        for (int i = 0; i < stops.length; i++)
          _StopCard(
            stop: stops[i],
            number: i + 1,
            isLast: i == stops.length - 1,
            onTap: () => _showStopDetail(context, stops[i]),
          ),
      ],
    );
  }

  void _showStopDetail(BuildContext context, RouteStopWithDetails stop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                stop.stop.title ?? stop.location?.name ?? '站点',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (stop.location != null && stop.modernLocation != null) ...[
                const SizedBox(height: 8),
                Text(
                  '古：${stop.location!.name} → 今：${stop.modernLocation!.name}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (stop.stop.arrivalStory != null) ...[
                const SizedBox(height: 16),
                Text(
                  '到达故事',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stop.stop.arrivalStory!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
              if (stop.stop.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  '简介',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stop.stop.description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
              if (stop.stop.stayDuration != null) ...[
                const SizedBox(height: 16),
                Text(
                  '建议停留：${stop.stop.stayDuration}天',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _StopCard extends StatelessWidget {
  final RouteStopWithDetails stop;
  final int number;
  final bool isLast;
  final VoidCallback? onTap;

  const _StopCard({
    required this.stop,
    required this.number,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Stop details
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.stop.title ?? stop.location?.name ?? '站点$number',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (stop.location != null && stop.modernLocation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '古：${stop.location!.name} → 今：${stop.modernLocation!.name}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (stop.stop.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        stop.stop.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Route map preview showing a small AMap with route polyline and stop markers.
class _RouteMapPreview extends StatefulWidget {
  final List<RouteStopWithDetails> stops;

  const _RouteMapPreview({required this.stops});

  @override
  State<_RouteMapPreview> createState() => _RouteMapPreviewState();
}

class _RouteMapPreviewState extends State<_RouteMapPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AMapWidget(
        initialCameraPosition: const CameraPosition(
          target: LatLng(34.5, 108.0),
          zoom: 4,
        ),
        polylines: {
          Polyline(
            points: widget.stops.map((_) => const LatLng(34.0, 108.0)).toList(),
            width: 4,
            color: Colors.amber,
          ),
        },
        markers: widget.stops.asMap().entries.map((entry) {
          return Marker(
            position: const LatLng(34.0, 108.0),
            infoWindow: InfoWindow(
              title: '${entry.key + 1}. ${entry.value.stop.title ?? ''}',
            ),
          );
        }).toSet(),
      ),
    );
  }
}
