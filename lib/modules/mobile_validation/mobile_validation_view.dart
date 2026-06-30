import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mobile_validation_controller.dart';
import '../../widgets/glassmorphism_card.dart';

class MobileValidationView extends GetView<MobileValidationController> {
  const MobileValidationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller to listen for input text
    final TextEditingController textEditingController = TextEditingController(text: controller.mobileNumber.value);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Validation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  // Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1.5),
                    ),
                    child: const Icon(Icons.phone_iphone, color: Color(0xFFFFD700), size: 36),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Enter Customer Mobile',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    'To prevent abuse, each customer is allowed only one spin per day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 32),

                  // Mobile Input
                  TextField(
                    controller: textEditingController,
                    onChanged: (val) => controller.mobileNumber.value = val,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1.5),
                    decoration: const InputDecoration(
                      labelText: 'Customer Mobile Number',
                      labelStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.phone, color: Color(0xFFFFD700)),
                      counterStyle: TextStyle(color: Colors.white30),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Validation Action Button
                  Obx(() {
                    final isLoading = controller.isLoading.value;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : controller.validateAndProceed,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Text('VALIDATE & PROCEED'),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
