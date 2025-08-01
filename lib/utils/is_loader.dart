import 'package:flutter/material.dart';
import 'dart:math' as math;

// Main loader widget with office table and chair theme
class OfficeLoader extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;
  final Duration duration;
  final String? loadingText;
  final TextStyle? textStyle;
  final OfficeLoaderType type;
  final double? value; // Progress value (0.0 to 1.0)
  final bool showProgressRing; // Whether to show progress ring

  const OfficeLoader({
    Key? key,
    this.size = 70.0,
    this.primaryColor = const Color(0xFFFF6B35), // Orange primary
    this.accentColor = const Color(0xFFFF8C42), // Blended orange accent
    this.duration = const Duration(milliseconds: 1800),
    this.loadingText,
    this.textStyle,
    this.type = OfficeLoaderType.desk,
    this.value,
    this.showProgressRing = false,
  }) : super(key: key);

  @override
  State<OfficeLoader> createState() => _OfficeLoaderState();
}

enum OfficeLoaderType { desk, meeting, workspace }

class _OfficeLoaderState extends State<OfficeLoader>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring (if enabled)
            if (widget.showProgressRing)
              SizedBox(
                width: widget.size + 20,
                height: widget.size + 20,
                child: CircularProgressIndicator(
                  value: widget.value,
                  strokeWidth: 3.0,
                  color: widget.primaryColor,
                  backgroundColor: widget.primaryColor.withOpacity(0.2),
                ),
              ),

            // Main office loader animation
            AnimatedBuilder(
              animation: Listenable.merge([_slideAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: OfficeTableChairPainter(
                      primaryColor: widget.primaryColor,
                      accentColor: widget.accentColor,
                      slideProgress: _slideAnimation.value,
                      type: widget.type,
                      progressValue: widget.value,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        if (widget.loadingText != null) ...[
          SizedBox(height: 16),
          Text(
            widget.loadingText!,
            style: widget.textStyle ??
                TextStyle(
                  fontSize: 14,
                  color: widget.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],

        // Show progress percentage if value is provided
        if (widget.value != null) ...[
          SizedBox(height: 8),
          Text(
            '${(widget.value! * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: widget.primaryColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class OfficeTableChairPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double slideProgress;
  final OfficeLoaderType type;
  final double? progressValue;

  OfficeTableChairPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.slideProgress,
    required this.type,
    this.progressValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (type) {
      case OfficeLoaderType.desk:
        _drawSingleDesk(canvas, center, radius);
        break;
      case OfficeLoaderType.meeting:
        _drawMeetingSetup(canvas, center, radius);
        break;
      case OfficeLoaderType.workspace:
        _drawWorkspaceGrid(canvas, center, radius);
        break;
    }
  }

  void _drawSingleDesk(Canvas canvas, Offset center, double radius) {
    final tableOutlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final tableFillPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final chairOutlinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final chairFillPaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Draw table with outline design
    final tableRect = Rect.fromCenter(
      center: center,
      width: radius * 1.4,
      height: radius * 0.8,
    );

    // Fill first, then outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, Radius.circular(8)),
      tableFillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, Radius.circular(8)),
      tableOutlinePaint,
    );

    // Draw table legs (outline style)
    final legPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final legPositions = [
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.3),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.3),
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.1),
    ];

    for (final legPos in legPositions) {
      canvas.drawLine(
        legPos,
        Offset(legPos.dx, legPos.dy + radius * 0.25),
        legPaint,
      );
    }

    // Draw chair with sliding animation
    final chairOffset = math.sin(slideProgress * math.pi * 2) * radius * 0.15;
    final chairCenter = Offset(center.dx, center.dy + radius * 0.7 + chairOffset);

    // Chair seat (outline design)
    final chairRect = Rect.fromCenter(
      center: chairCenter,
      width: radius * 0.6,
      height: radius * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chairRect, Radius.circular(6)),
      chairFillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chairRect, Radius.circular(6)),
      chairOutlinePaint,
    );

    // Chair backrest (outline design)
    final backrestRect = Rect.fromCenter(
      center: Offset(chairCenter.dx, chairCenter.dy - radius * 0.3),
      width: radius * 0.5,
      height: radius * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(backrestRect, Radius.circular(4)),
      chairFillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(backrestRect, Radius.circular(4)),
      chairOutlinePaint,
    );

    // Chair legs
    final chairLegPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(chairCenter.dx - radius * 0.2, chairCenter.dy + radius * 0.2),
      Offset(chairCenter.dx - radius * 0.2, chairCenter.dy + radius * 0.35),
      chairLegPaint,
    );
    canvas.drawLine(
      Offset(chairCenter.dx + radius * 0.2, chairCenter.dy + radius * 0.2),
      Offset(chairCenter.dx + radius * 0.2, chairCenter.dy + radius * 0.35),
      chairLegPaint,
    );
  }

  void _drawMeetingSetup(Canvas canvas, Offset center, double radius) {
    final tableOutlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final tableFillPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final chairOutlinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final chairFillPaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Draw oval meeting table (outline design)
    final tableRect = Rect.fromCenter(
      center: center,
      width: radius * 1.6,
      height: radius * 1.0,
    );
    canvas.drawOval(tableRect, tableFillPaint);
    canvas.drawOval(tableRect, tableOutlinePaint);

    // Draw 6 chairs around the table
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2 / 6) + (slideProgress * math.pi * 2);
      final chairDistance = radius * 0.9;
      final chairCenter = Offset(
        center.dx + chairDistance * math.cos(angle),
        center.dy + chairDistance * math.sin(angle),
      );

      final opacity = (math.sin(slideProgress * math.pi * 2 + i * 0.5) + 1) / 2;
      final animatedChairFillPaint = Paint()
        ..color = chairFillPaint.color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill;

      final animatedChairOutlinePaint = Paint()
        ..color = chairOutlinePaint.color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw chair (outline design)
      canvas.drawCircle(chairCenter, radius * 0.15, animatedChairFillPaint);
      canvas.drawCircle(chairCenter, radius * 0.15, animatedChairOutlinePaint);

      // Draw chair backrest
      final backrestCenter = Offset(
        chairCenter.dx - (radius * 0.2) * math.cos(angle),
        chairCenter.dy - (radius * 0.2) * math.sin(angle),
      );
      canvas.drawCircle(backrestCenter, radius * 0.08, animatedChairFillPaint);
      canvas.drawCircle(backrestCenter, radius * 0.08, animatedChairOutlinePaint);
    }
  }

  void _drawWorkspaceGrid(Canvas canvas, Offset center, double radius) {
    final tableOutlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final tableFillPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final chairOutlinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final chairFillPaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Draw 4 workstations in a grid
    final positions = [
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
    ];

    for (int i = 0; i < positions.length; i++) {
      final delay = i * 0.25;
      final animProgress = ((slideProgress + delay) % 1.0);
      final scale = 0.8 + (math.sin(animProgress * math.pi * 2) * 0.2);
      final opacity = 0.6 + (math.sin(animProgress * math.pi * 2) * 0.4);

      // Draw desk (outline design)
      final deskSize = radius * 0.35 * scale;
      final deskRect = Rect.fromCenter(
        center: positions[i],
        width: deskSize,
        height: deskSize * 0.7,
      );

      final animatedTableFillPaint = Paint()
        ..color = tableFillPaint.color.withOpacity(opacity * 0.2)
        ..style = PaintingStyle.fill;

      final animatedTableOutlinePaint = Paint()
        ..color = tableOutlinePaint.color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawRRect(
        RRect.fromRectAndRadius(deskRect, Radius.circular(4)),
        animatedTableFillPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(deskRect, Radius.circular(4)),
        animatedTableOutlinePaint,
      );

      // Draw chair (outline design)
      final chairRect = Rect.fromCenter(
        center: Offset(positions[i].dx, positions[i].dy + deskSize * 0.6),
        width: deskSize * 0.4,
        height: deskSize * 0.3,
      );

      final animatedChairFillPaint = Paint()
        ..color = chairFillPaint.color.withOpacity(opacity * 0.25)
        ..style = PaintingStyle.fill;

      final animatedChairOutlinePaint = Paint()
        ..color = chairOutlinePaint.color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(chairRect, Radius.circular(2)),
        animatedChairFillPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(chairRect, Radius.circular(2)),
        animatedChairOutlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Convenient wrapper methods for different screens
class CoworkingLoaders {
  // Login/Authentication screens
  static Widget auth({String? text}) => OfficeLoader(
    type: OfficeLoaderType.desk,
    loadingText: text ?? "",
  );

  // Booking/Search screens
  static Widget booking({String? text}) => OfficeLoader(
    type: OfficeLoaderType.workspace,
    loadingText: text ?? "",
  );

  // Meeting room screens
  static Widget meeting({String? text}) => OfficeLoader(
    type: OfficeLoaderType.meeting,
    loadingText: text ?? "",
  );

  // Profile/Settings screens
  static Widget profile({String? text}) => OfficeLoader(
    type: OfficeLoaderType.desk,
    loadingText: text ?? "",
  );

  // Payment screens
  static Widget payment({String? text}) => OfficeLoader(
    type: OfficeLoaderType.desk,
    loadingText: text ?? "",
  );

  // General loading
  static Widget general({String? text}) => OfficeLoader(
    type: OfficeLoaderType.desk,
    loadingText: text ?? "",
  );

  // Progress loader for image/file loading
  static Widget progress({
    required double? value,
    String? text,
    bool showRing = true,
    OfficeLoaderType type = OfficeLoaderType.desk,
    double size = 70.0,
  }) => OfficeLoader(
    type: type,
    value: value,
    showProgressRing: showRing,

    size: size,
  );

  // Custom loader with specific colors
  static Widget custom({
    required Color primaryColor,
    required Color accentColor,
    required String text,
    OfficeLoaderType type = OfficeLoaderType.desk,
    double size = 70.0,
    double? value,
    bool showProgressRing = false,
  }) => OfficeLoader(
    primaryColor: primaryColor,
    accentColor: accentColor,
    loadingText: text,
    type: type,
    size: size,
    value: value,
    showProgressRing: showProgressRing,
  );
}

