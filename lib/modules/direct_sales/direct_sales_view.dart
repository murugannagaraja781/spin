import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'direct_sales_controller.dart';
import '../../widgets/glassmorphism_card.dart';

class DirectSalesView extends GetView<DirectSalesController> {
  const DirectSalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Sales Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000814), Color(0xFF0D1B2A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salesman Header Card
                  GlassmorphismCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Color(0xFF00E676), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SALESMAN',
                                style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                              ),
                              Obx(() => Text(
                                controller.salesman.value,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form: Product & Qty Selection
                  const Text(
                    'ADD PRODUCT TO CART',
                    style: TextStyle(color: Color(0xFF00E676), fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GlassmorphismCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Product Dropdown
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
                          }
                          if (controller.products.isEmpty) {
                            return const Text('No products available.', style: TextStyle(color: Colors.white60));
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                value: controller.selectedProduct.value,
                                dropdownColor: const Color(0xFF0D1B2A),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E676)),
                                isExpanded: true,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                items: controller.products.map((p) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: p,
                                    child: Text('${p['name']} (₹${p['price']})'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.selectedProduct.value = val;
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),

                        // Quantity Picker
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quantity:', style: TextStyle(color: Colors.white70, fontSize: 15)),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (controller.quantity.value > 1) {
                                      controller.quantity.value--;
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00E676), size: 28),
                                ),
                                Container(
                                  width: 60,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    controller: controller.qtyTextController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (val) {
                                      final parsed = int.tryParse(val) ?? 1;
                                      controller.quantity.value = parsed > 0 ? parsed : 1;
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.quantity.value++,
                                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E676), size: 28),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Add Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.addToCart,
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text('ADD TO CART'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cart Items Header
                  const Text(
                    'CART ITEMS',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Cart ListView
                  Expanded(
                    child: Obx(() {
                      if (controller.cartItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.white.withOpacity(0.1)),
                              const SizedBox(height: 8),
                              const Text('Cart is empty', style: TextStyle(color: Colors.white30, fontSize: 14)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: controller.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.cartItems[index];
                          final prod = item['product'];
                          final int qty = item['quantity'];
                          final double price = double.tryParse(prod['price'].toString()) ?? 0.0;
                          final double subtotal = price * qty;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: GlassmorphismCard(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF00E5FF), size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod['name'] ?? '',
                                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '₹${price.toStringAsFixed(2)} x $qty',
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => controller.removeFromCart(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Checkout Card
                  Obx(() {
                    if (controller.cartItems.isEmpty) return const SizedBox.shrink();
                    return GlassmorphismCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Checkout Amount:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(
                                '₹${controller.cartTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.submitCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('SUBMIT DIRECT ENTRY', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Loading Overlay
          Obx(() {
            if (controller.isSubmitting.value) {
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF00E5FF)),
                      SizedBox(height: 16),
                      Text('Submitting sales entries...', style: TextStyle(color: Colors.white70, fontSize: 15)),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
