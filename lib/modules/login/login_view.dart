import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_controller.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../core/controllers/branding_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final logo = Get.find<BrandingController>().logoUrl.value;
                    if (logo.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Image.network(
                          logo,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.stars, color: Color(0xFF00E5FF), size: 64),
                        ),
                      );
                    }
                    return const Icon(Icons.stars, color: Color(0xFF00E5FF), size: 64);
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'LUCKY SPIN',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'REWARDS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 4),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => Text(
                    Get.find<BrandingController>().appTitle.value,
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    Get.find<BrandingController>().appSubtitle.value,
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(height: 32),
                  TextField(
                    onChanged: (val) => controller.password.value = val,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Admin Password',
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00E5FF)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.login,
                      child: const Text('LOGIN'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse('https://www.minikuttybeedi.com');
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.language, color: Color(0xFF00E5FF), size: 16),
                    label: const Text(
                      'Visit www.minikuttybeedi.com',
                      style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
