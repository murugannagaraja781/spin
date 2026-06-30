import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'spin_wheel_controller.dart';
import '../../core/controllers/branding_controller.dart';

class SpinWheelView extends StatefulWidget {
  const SpinWheelView({super.key});

  @override
  State<SpinWheelView> createState() => _SpinWheelViewState();
}

class _SpinWheelViewState extends State<SpinWheelView> {
  final SpinWheelController controller = Get.find();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    ever(controller.spinCompleted, (completed) {
      if (completed) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  bool get _isPremium => controller.product.contains('20');

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool preventBack = controller.isSpinning.value || controller.spinCompleted.value;
      return PopScope(
        canPop: !preventBack,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !preventBack,
        title: Obx(() {
          final branding = Get.find<BrandingController>();
          return Column(
            children: [
              Text(
                _isPremium ? branding.premiumTitle.value : branding.appTitle.value, 
                style: TextStyle(
                  color: _isPremium ? const Color(0xFFFFD700) : const Color(0xFF00E5FF), 
                  fontSize: _isPremium ? 18 : 22, 
                  fontWeight: FontWeight.bold,
                  shadows: _isPremium ? [
                    const Shadow(color: Color(0xFFFFD700), blurRadius: 10)
                  ] : null
                )
              ),
              if (!_isPremium)
                Text(
                  branding.appSubtitle.value, 
                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.normal)
                ),
            ],
          );
        }),
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: _isPremium
                  ? const LinearGradient(
                      colors: [Color(0xFF0F0B01), Color(0xFF2C1E03), Color(0xFF000000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF000814), Color(0xFF0D1B2A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer gorgeous gold frame with light bulbs
                    CustomPaint(
                      size: const Size(360, 360),
                      painter: WheelFramePainter(),
                    ),
                    // FortuneWheel in the center (sized smaller to fit inside the frame)
                    SizedBox(
                      width: 295,
                      height: 295,
                      child: FortuneWheel(
                        selected: controller.wheelController.stream,
                        onAnimationEnd: controller.onSpinEnd,
                        animateFirst: false,
                        indicators: <FortuneIndicator>[
                          FortuneIndicator(
                            alignment: Alignment.topCenter,
                            child: TriangleIndicator(
                              color: _isPremium ? const Color(0xFFFFDF00) : const Color(0xFF00E5FF),
                            ),
                          ),
                          FortuneIndicator(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _isPremium
                                    ? const RadialGradient(
                                        colors: [Color(0xFFFFE066), Color(0xFFB8860B), Color(0xFF8B6508)],
                                      )
                                    : null,
                                color: _isPremium ? null : const Color(0xFF0D1B2A),
                                border: Border.all(
                                  color: _isPremium ? const Color(0xFFFFDF00) : const Color(0xFF00E5FF), 
                                  width: _isPremium ? 4 : 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isPremium ? const Color(0xFFFFD700) : const Color(0xFF00E5FF).withOpacity(0.5), 
                                    blurRadius: _isPremium ? 20 : 10, 
                                    spreadRadius: _isPremium ? 4 : 2,
                                  )
                                ],
                              ),
                              padding: EdgeInsets.all(_isPremium ? 12 : 16),
                              child: Icon(
                                _isPremium ? Icons.stars : Icons.smoking_rooms, 
                                color: _isPremium ? const Color(0xFF553D00) : const Color(0xFF00E5FF), 
                                size: _isPremium ? 44 : 40,
                              ),
                            ),
                          ),
                        ],
                        items: [
                          for (int i = 0; i < controller.prizes.length; i++)
                            FortuneItem(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 36.0),
                                child: Text(
                                  controller.prizes[i],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              style: FortuneItemStyle(
                                color: _getColorForPrize(controller.prizes[i], i),
                                borderColor: _isPremium ? const Color(0xFFFFD700) : const Color(0xFF00E5FF),
                                borderWidth: _isPremium ? 3 : 2,
                                textStyle: TextStyle(
                                  color: _isPremium ? const Color(0xFFFFD700) : Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  shadows: _isPremium ? [
                                    const Shadow(color: Colors.black, blurRadius: 6, offset: Offset(1, 1))
                                  ] : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Obx(() => controller.spinCompleted.value
                    ? Column(
                        children: [
                          Text(
                            'Congratulations ${controller.customerName}!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You Won: ${controller.winningPrize.value}',
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: _isPremium ? const Color(0xFFFFD700) : const Color(0xFF00E676),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: controller.continueToWinnerDetails,
                            child: const Text('PROCEED'),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: controller.isSpinning.value ? null : controller.spin,
                        child: const Text('SPIN THE WHEEL'),
                      )),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    ),
  );
});
}

  Color _getColorForPrize(String prize, int index) {
    if (_isPremium) {
      // Premium elegant colors: alternate Gold hues and Obsidian blacks
      final premiumColors = [
        const Color(0xFF1E1E24), // Obsidian Black
        const Color(0xFFD4AF37), // Metallic Gold
        const Color(0xFF3F0071), // Royal Violet
        const Color(0xFF8B6508), // Dark Gold / Bronze
        const Color(0xFF111116), // Deep Jet
        const Color(0xFFC5A059), // Antique Gold
        const Color(0xFF2C3E50), // Midnight Slate
        const Color(0xFFFFDF00), // Bright Gold
        const Color(0xFF5B0E2D), // Deep Royal Crimson
        const Color(0xFF2E4053), // Slate Charcoal
      ];
      return premiumColors[index % premiumColors.length];
    } else {
      int val = int.tryParse(prize.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (val <= 10) return Colors.blue.shade800;
      if (val <= 20) return Colors.green.shade800;
      if (val <= 30) return Colors.purple.shade800;
      if (val <= 40) return Colors.orange.shade800;
      return Colors.red.shade900;
    }
  }
}

class WheelFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Gold Ring Background with SweepGradient
    final goldGradient = const SweepGradient(
      colors: [
        Color(0xFFB8860B),
        Color(0xFFFFD700),
        Color(0xFFB8860B),
        Color(0xFFFFD700),
        Color(0xFFB8860B)
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final outerRingPaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;
    canvas.drawCircle(center, radius - 12, outerRingPaint);

    // Inner Dark Ring for border
    final innerDarkPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 26, innerDarkPaint);

    // Little Light Bulbs (24 bulbs)
    final lightPaint = Paint()..color = const Color(0xFFFFF9C4)..style = PaintingStyle.fill;
    final lightShadow = Paint()
      ..color = const Color(0xAAFFD700)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < 24; i++) {
      final angle = i * (2 * math.pi / 24);
      final lightCenter = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );
      canvas.drawCircle(lightCenter, 4, lightShadow);
      canvas.drawCircle(lightCenter, 3, lightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
