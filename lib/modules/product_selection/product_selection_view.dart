import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'product_selection_controller.dart';
import '../../widgets/glassmorphism_card.dart';

class ProductSelectionView extends GetView<ProductSelectionController> {
  const ProductSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Selection', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Header Card
                GlassmorphismCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Color(0xFFFFD700), size: 30),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ORDERING FOR',
                              style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              controller.customerName,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'CHOOSE PRODUCT',
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Dynamic Products Grid
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                    ));
                  }
                  if (controller.products.isEmpty) {
                    return const Text('No products available.', style: TextStyle(color: Colors.white70));
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return Obx(() {
                        final isSelected = controller.selectedProduct.value?['id'] == product['id'];
                        return GestureDetector(
                          onTap: () => controller.selectProduct(product),
                          child: GlassmorphismCard(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              decoration: BoxDecoration(
                                border: isSelected ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 32, color: isSelected ? const Color(0xFFFFD700) : Colors.white60),
                                  const SizedBox(height: 10),
                                  Text(
                                    product['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${product['price']}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white54,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
                const SizedBox(height: 24),

                // Quantity Picker Card
                const Text(
                  'SELECT QUANTITY',
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GlassmorphismCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => controller.updateQuantity(controller.quantity.value - 1),
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFFFD700), size: 28),
                          ),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: TextFormField(
                              controller: controller.qtyTextController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                                controller.updateQuantity(parsed);
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.updateQuantity(controller.quantity.value + 1),
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFD700), size: 28),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Order Total Card
                GlassmorphismCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: Colors.white70, fontSize: 15)),
                          Obx(() {
                            final price = controller.selectedProduct.value?['price'] ?? '0.00';
                            return Text('₹$price x ${controller.quantity.value}', style: const TextStyle(color: Colors.white70, fontSize: 15));
                          }),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Obx(() => Text(
                            '₹${controller.orderTotal.value.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.bold, shadows: [
                              Shadow(color: Color(0xFFFFD700), blurRadius: 10),
                            ]),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Eligibility / Action Cards
                const Text(
                  'IS ELIGIBLE FOR LUCKY SPIN?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // Eligible (Yes)
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.proceedToSpin,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E351E), Color(0xFF101B10)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stars, color: Colors.greenAccent, size: 36),
                              SizedBox(height: 10),
                              Text(
                                'YES',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              Text(
                                'Proceed to Spin',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Not Eligible (No)
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.proceedToDirectComplete,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A1F1F), Color(0xFF1D1010)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_checkout, color: Colors.redAccent, size: 36),
                              SizedBox(height: 10),
                              Text(
                                'NO',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              Text(
                                'Complete Order',
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
