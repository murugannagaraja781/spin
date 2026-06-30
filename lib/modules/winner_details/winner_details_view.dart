import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'winner_details_controller.dart';
import '../../widgets/glassmorphism_card.dart';

class WinnerDetailsView extends GetView<WinnerDetailsController> {
  const WinnerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000814), Color(0xFF0D1B2A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassmorphismCard(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 64),
                    const SizedBox(height: 16),
                    const Text('PRIZE WON', style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 2)),
                    Text(
                      controller.prize,
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      onChanged: (val) => controller.customerName.value = val,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        prefixIcon: Icon(Icons.person, color: Color(0xFFFFD700)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (val) => controller.mobileNumber.value = val,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone, color: Color(0xFFFFD700)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.continueToPhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('PROCEED TO PHOTO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
