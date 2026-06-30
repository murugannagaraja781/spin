import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'congratulations_screen.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _picker = ImagePicker();

  bool _isSpinning = false;
  bool _spinCompleted = false;

  final List<String> _items = ['RS: 10', 'RS: 20', 'RS: 30', 'RS: 40', 'RS: 50', 'RS: 60', 'RS: 70', 'RS: 80', 'RS: 90'];
  final List<Color> _colors = [
    const Color(0xFFC72C41), // Red
    const Color(0xFF1E88E5), // Blue
    const Color(0xFF43A047), // Green
    const Color(0xFFF9A825), // Gold
    const Color(0xFF8E24AA), // Purple
    const Color(0xFF00ACC1), // Teal
    const Color(0xFFE53935), // Bright Red
    const Color(0xFFFBC02D), // Yellow
    const Color(0xFF1565C0), // Dark Blue
  ];
  String _winningItem = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _controller.addListener(() {
      // Play tick sound continuously during spin
      if (_controller.isAnimating && _controller.value % 0.1 < 0.02) {
        _audioPlayer.play(AssetSource('audio/tick.ogg'));
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Calculate winning item
        double pointerAngle = 1.5 * pi; // 270 degrees
        double normalizedRotation = _animation.value % (2 * pi);
        double currentAngle = (pointerAngle - normalizedRotation) % (2 * pi);
        if (currentAngle < 0) currentAngle += 2 * pi;
        int winningIndex = (currentAngle / (2 * pi / _items.length)).floor();

        setState(() {
          _isSpinning = false;
          _spinCompleted = true;
          _winningItem = _items[winningIndex];
        });
      }
    });
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _spinCompleted = false;
    });

    final random = Random();
    final double endAngle = (random.nextDouble() * 4 + 6) * pi; // spin 3 to 5 times
    
    _animation = Tween<double>(begin: 0, end: endAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc)
    );

    _controller.reset();
    _controller.forward();
  }

  Future<void> _submitAndCapture() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CongratulationsScreen(
              imagePath: image.path,
              winningPercentage: _winningItem,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111115), // Dark background matching the image
      appBar: AppBar(
        title: const Column(
          children: [
            Text('SPIN & WIN', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 2, fontFamily: 'Serif')),
            Text('Spin the wheel and win exciting prizes!', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // The Wheel itself
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _isSpinning || _spinCompleted ? _animation.value : 0,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black54, blurRadius: 30, spreadRadius: 10)
                          ]
                        ),
                        child: CustomPaint(
                          painter: WheelPainter(items: _items, colors: _colors),
                        ),
                      ),
                    );
                  },
                ),
                // Center Button (acts as SPIN button too)
                GestureDetector(
                  onTap: _isSpinning ? null : _spin,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFE066), Color(0xFFB8860B)],
                      ),
                      border: Border.all(color: const Color(0xFF553D00), width: 4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black87, blurRadius: 15, spreadRadius: 2)
                      ]
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.smoking_rooms, color: Color(0xFF553D00), size: 30),
                          if (!_isSpinning)
                            const Text('SPIN', style: TextStyle(color: Color(0xFF553D00), fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Indicator pointer at the top
                Positioned(
                  top: -15,
                  child: CustomPaint(
                    size: const Size(40, 50),
                    painter: PointerPainter(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            if (!_spinCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFB8860B), width: 2),
                  color: Colors.black54,
                ),
                child: const Text('TAP CENTER TO SPIN', style: TextStyle(fontSize: 18, color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              )
            else
              Column(
                children: [
                  Text(
                    'You won $_winningItem!',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submitAndCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8860B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Submit & Take Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;

  WheelPainter({required this.items, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Gold Ring Background
    final goldGradient = const SweepGradient(
      colors: [Color(0xFFB8860B), Color(0xFFFFD700), Color(0xFFB8860B), Color(0xFFFFD700), Color(0xFFB8860B)],
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

    // Little Light Bulbs
    final lightPaint = Paint()..color = const Color(0xFFFFF9C4)..style = PaintingStyle.fill;
    final lightShadow = Paint()
      ..color = const Color(0xAAFFD700)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (int i = 0; i < 24; i++) {
      final angle = i * (2 * pi / 24);
      final lightCenter = Offset(
        center.dx + (radius - 12) * cos(angle),
        center.dy + (radius - 12) * sin(angle),
      );
      canvas.drawCircle(lightCenter, 4, lightShadow);
      canvas.drawCircle(lightCenter, 3, lightPaint);
    }

    // Segments
    final rect = Rect.fromCircle(center: center, radius: radius - 28);
    final paint = Paint()..style = PaintingStyle.fill;
    final double sweepAngle = 2 * pi / items.length;

    for (int i = 0; i < items.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(rect, i * sweepAngle, sweepAngle, true, paint);

      // Gold line separating segments
      final linePaint = Paint()
        ..shader = goldGradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(
        center,
        Offset(center.dx + (radius - 28) * cos(i * sweepAngle), center.dy + (radius - 28) * sin(i * sweepAngle)),
        linePaint,
      );
      
      // Draw text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * sweepAngle + sweepAngle / 2);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 22, 
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 2))]
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Draw at a distance from center
      textPainter.paint(canvas, Offset((radius - 28) * 0.5, -textPainter.height / 2));
      canvas.restore();
    }
    
    // Inner Gold Ring
    final innerRingPaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, 52, innerRingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, size.height); // bottom tip
    path.lineTo(size.width * 0.2, size.height * 0.4); // left middle
    path.quadraticBezierTo(size.width * 0.2, 0, size.width / 2, 0); // top curve left to center
    path.quadraticBezierTo(size.width * 0.8, 0, size.width * 0.8, size.height * 0.4); // top curve center to right
    path.close();

    final goldGradient = const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFB8860B), Color(0xFF8B6508)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()..shader = goldGradient;
    canvas.drawPath(path, paint);
    
    // Add border to pointer
    final borderPaint = Paint()
      ..color = const Color(0xFF553D00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);

    // Add a red jewel in the center of the pointer
    final jewelPaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.35), 6, jewelPaint);
    
    // Jewel highlight
    final jewelHighlight = Paint()..color = Colors.white54;
    canvas.drawCircle(Offset(size.width / 2 - 2, size.height * 0.35 - 2), 2, jewelHighlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
