import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'salesman_selection_controller.dart';
import '../../widgets/glassmorphism_card.dart';

class SalesmanSelectionView extends GetView<SalesmanSelectionController> {
  const SalesmanSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Salesman'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: controller.logout,
          ),
          const SizedBox(width: 8),
        ],
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                GlassmorphismCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Obx(() {
                    if (controller.isLoading.value && controller.salesmen.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.selectedSalesman.value.isEmpty ? null : controller.selectedSalesman.value,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person, color: Color(0xFF00E5FF)),
                      ),
                      dropdownColor: const Color(0xFF0D1B2A),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                      hint: const Text('Select Salesman', style: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      items: controller.salesmen.map((salesman) {
                        return DropdownMenuItem<String>(
                          value: salesman,
                          child: Text(salesman),
                        );
                      }).toList(),
                      onChanged: controller.selectSalesman,
                    );
                  }),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.continueToCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('SALES WITH SPIN'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.continueToDirectSales,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('DIRECT SALES (NO SPIN)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
