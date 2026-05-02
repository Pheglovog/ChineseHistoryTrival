import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ShareCard extends StatelessWidget {
  final String ancientName;
  final String? modernName;
  final String dynastyName;
  final String? adminLevel;
  final GlobalKey repaintKey = GlobalKey();

  ShareCard({
    super.key,
    required this.ancientName,
    this.modernName,
    required this.dynastyName,
    this.adminLevel,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.gold, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynasty tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 0.5),
              ),
              child: Text(
                dynastyName,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ancient name
            Text(
              ancientName,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            if (modernName != null) ...[
              const SizedBox(height: 8),
              Text(
                '今：$modernName',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            if (adminLevel != null) ...[
              const SizedBox(height: 8),
              Text(
                adminLevel!,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // App branding
            const Divider(color: AppColors.gold, thickness: 0.5),
            const SizedBox(height: 8),
            Text(
              '华夏足迹 · 踏寻千年足迹',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> share() async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(
          format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final buffer = byteData.buffer;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_card.png');
      await file.writeAsBytes(buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '$ancientName${modernName != null ? " → $modernName" : ""} | 华夏足迹',
      );
    } catch (e) {
      // Fallback to text share
      await Share.share(
        '$ancientName${modernName != null ? " → $modernName" : ""} | 华夏足迹 - 跟随古人脚步旅游',
      );
    }
  }
}
