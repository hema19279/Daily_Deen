import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../themes/app_colors.dart';
import '../viewmodels/qibla_viewmodel.dart';
import '../core/services/location_service.dart';

class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  @override
  void initState() {
    super.initState();
    final locationService = Provider.of<LocationService>(context, listen: false);
    Provider.of<QiblaViewModel>(context, listen: false).initialize(locationService);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QiblaViewModel>(context);
    final angle = (viewModel.qiblaDirection - viewModel.deviceHeading) * math.pi / 180;

    double angleDiff = (viewModel.qiblaDirection - viewModel.deviceHeading + 360) % 360;
    final isAligned = angleDiff <= 5 || angleDiff >= 355;
    final direction = angleDiff < 180 ? "right" : "left";
    final turnDegrees = angleDiff < 180 ? angleDiff : 360 - angleDiff;

    bool showTooltip = viewModel.qiblaDirection == 0.0 || viewModel.deviceHeading == 0.0;

    return Stack(
      children: [
        if (showTooltip)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: Colors.redAccent,
              child: const Text(
                'Unable to detect location or compass heading. Please check your device settings.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text('Qibla Direction', style: TextStyle(color: AppColors.theme, fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    'Point your device toward Makkah',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      boxShadow: [
                        BoxShadow(color: isAligned ? Colors.greenAccent : AppColors.theme.withAlpha(51), blurRadius: 15, spreadRadius: 5),
                      ],
                      border: Border.all(color: isAligned ? Colors.greenAccent : AppColors.theme.withAlpha(153), width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [AppColors.secondary, AppColors.primary],
                              stops: const [0.7, 1.0],
                            ),
                          ),
                          child: CustomPaint(painter: CompassPainter()),
                        ),

                        Transform.rotate(
                          angle: angle,
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 28,
                                  bottom: 0,
                                  left: 108,
                                  child: Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [AppColors.theme, AppColors.theme.withAlpha(26)],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Icon(Icons.location_on, color: AppColors.theme, size: 32),
                                ),
                                Positioned(
                                  top: 45,
                                  left: 0,
                                  right: 0,
                                  child: Icon(Icons.mosque, color: AppColors.theme, size: 24),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.theme,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppColors.theme.withAlpha(77), blurRadius: 8, spreadRadius: 2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.theme.withAlpha(77)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation, color: AppColors.theme),
                        const SizedBox(width: 8),
                        Text(
                          isAligned ? "Facing Qibla" : "${turnDegrees.toStringAsFixed(0)}° to the $direction",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.theme.withAlpha(102)
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    const tickLength = 10.0;

    for (int i = 0; i < 360; i += 30) {
      final angle = i * math.pi / 180;
      final start = Offset(
        center.dx + (size.width / 2 - tickLength) * math.cos(angle),
        center.dy + (size.height / 2 - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (size.width / 2) * math.cos(angle),
        center.dy + (size.height / 2) * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}