import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'submit_success_controller.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../core/controllers/branding_controller.dart';
import 'package:share_plus/share_plus.dart';

class SubmitSuccessView extends GetView<SubmitSuccessController> {
  const SubmitSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000814), Color(0xFF0D1B2A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Obx(() {
              if (controller.isSubmitting.value) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFFFD700)),
                    const SizedBox(height: 20),
                    const Text(
                      'Submitting Data & Creating Invoice...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                );
              }

              if (controller.isSuccess.value) {
                final data = controller.data;
                final bool isEligible = data['spin_eligible'] == true;
                final double orderTotal = data['orderTotal'] as double? ?? 0.0;
                final double discount = data['discount_applied'] as double? ?? 0.0;
                final double netAmount = data['net_amount'] as double? ?? 0.0;
                final String prize = data['prize']?.toString() ?? '';
                final String invNo = 'INV-${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';
                
                final now = DateTime.now();
                final String formattedDate = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

                final List<dynamic> items = data['items'] ?? [
                  {
                    'name': data['product'] ?? '',
                    'quantity': data['quantity'] ?? 1,
                    'price': double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0,
                  }
                ];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 70),
                        const SizedBox(height: 12),
                        const Text(
                          'ORDER COMPLETED SUCCESSFULLY!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 20),
                        
                        // Invoice Card
                        GlassmorphismCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Branding Logo / Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(() {
                                    final logo = Get.find<BrandingController>().logoUrl.value;
                                    if (logo.isNotEmpty) {
                                      return Image.network(
                                        logo,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.stars, color: Color(0xFF00E5FF), size: 40),
                                      );
                                    }
                                    return const Icon(Icons.stars, color: Color(0xFF00E5FF), size: 40);
                                  }),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Obx(() => Text(
                                        Get.find<BrandingController>().appTitle.value,
                                        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.bold),
                                      )),
                                      const Text(
                                        'TAX INVOICE',
                                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white24, height: 24, thickness: 1),
                              
                              // Invoice Header Metadata
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Invoice No: $invNo', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text(formattedDate, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Salesman: ${data['salesman']}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                              const SizedBox(height: 16),
                              
                              // Customer details card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('BILL TO:', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(data['customerName'] ?? 'Walk-in Customer', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                    if (data['mobileNumber']?.toString().isNotEmpty == true) ...[
                                      const SizedBox(height: 2),
                                      Text('Mob: ${data['mobileNumber']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Items Header
                              const Row(
                                  children: [
                                    Expanded(flex: 3, child: Text('ITEM', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold))),
                                    Expanded(flex: 1, child: Text('QTY', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                    Expanded(flex: 1, child: Text('RATE', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                    Expanded(flex: 1, child: Text('TOTAL', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                  ],
                              ),
                              const Divider(color: Colors.white10, height: 16),
                              
                              // Item Line Rows (dynamic loop)
                              ...items.map((item) {
                                final String itemName = item['name'] ?? '';
                                final int itemQty = item['quantity'] as int? ?? 1;
                                final double itemPrice = (item['price'] is double) ? item['price'] : (double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0);
                                final double itemSubtotal = itemPrice * itemQty;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: Text(itemName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                                      Expanded(flex: 1, child: Text('$itemQty', style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center)),
                                      Expanded(flex: 1, child: Text('₹${itemPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.right)),
                                      Expanded(flex: 1, child: Text('₹${itemSubtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(color: Colors.white24, height: 32, thickness: 1),
                              
                              // Billing Calculations
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  Text('₹${orderTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                ],
                              ),
                              if (isEligible && discount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.stars, color: Colors.greenAccent, size: 16),
                                        const SizedBox(width: 4),
                                        Text('Lucky Spin Discount ($prize)', style: const TextStyle(color: Colors.greenAccent, fontSize: 14)),
                                      ],
                                    ),
                                    Text('-₹${discount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                              const Divider(color: Colors.white10, height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Net Payable', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(
                                    '₹${netAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 20, fontWeight: FontWeight.bold, shadows: [
                                      Shadow(color: Color(0xFF00E5FF), blurRadius: 6),
                                    ]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Invoice footer note
                              const Center(
                                child: Text(
                                  'Thank you for your business!',
                                  style: TextStyle(color: Colors.white30, fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final appTitle = Get.find<BrandingController>().appTitle.value;
                                  final StringBuffer itemsBuffer = StringBuffer();
                                  for (var item in items) {
                                    final String name = item['name'] ?? '';
                                    final int qty = item['quantity'] as int? ?? 1;
                                    final double price = (item['price'] is double) ? item['price'] : (double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0);
                                    final double total = price * qty;
                                    itemsBuffer.writeln('$name (x$qty) - ₹${price.toStringAsFixed(2)}: ₹${total.toStringAsFixed(2)}');
                                  }

                                  final invoiceText = '''
🏆 $appTitle 🏆
---------------------------------
TAX INVOICE
---------------------------------
Invoice No: $invNo
Date: $formattedDate
Salesman: ${data['salesman']}
Customer: ${data['customerName'] ?? 'Walk-in Customer'}
${data['mobileNumber']?.toString().isNotEmpty == true ? 'Mobile: ' + data['mobileNumber'] : ''}
---------------------------------
ITEMS:
${itemsBuffer.toString()}---------------------------------
Subtotal: ₹${orderTotal.toStringAsFixed(2)}
${(isEligible && discount > 0) ? 'Spin Discount (' + prize + '): -₹' + discount.toStringAsFixed(2) : ''}
Net Amount: ₹${netAmount.toStringAsFixed(2)}
---------------------------------
Thank you for your business!
''';
                                  Share.share(invoiceText, subject: 'Invoice $invNo');
                                },
                                icon: const Icon(Icons.share, size: 18),
                                label: const Text('SHARE BILL'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: controller.backToHome,
                                icon: const Icon(Icons.home, size: 18),
                                label: const Text('NEW ORDER'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Failed Submission State
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassmorphismCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Submission Failed',
                        style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'We were unable to submit this order details. It remains saved locally in the super admin dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: controller.backToHome,
                        child: const Text('BACK TO CUSTOMERS'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
