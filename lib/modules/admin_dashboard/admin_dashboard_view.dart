import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin_dashboard_controller.dart';
import '../../widgets/glassmorphism_card.dart';
import '../../core/controllers/branding_controller.dart';
import '../../core/constants/api_config.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Super Admin Portal', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF00E5FF))),
        backgroundColor: const Color(0xFF070C16).withOpacity(0.9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00E5FF)),
            tooltip: 'Refresh Data',
            onPressed: controller.fetchServerData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: controller.logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070C16), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isServerLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
            }
            return _buildMainDashboard(context);
          }),
        ),
      ),
    );
  }

  // --- MAIN DASHBOARD HOMEPAGE ---
  Widget _buildMainDashboard(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Grid of metrics
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard('Total Sales', '₹${controller.serverTotalSales.value.toStringAsFixed(0)}', Icons.monetization_on, const Color(0xFF00E5FF)),
                _buildMetricCard("Today's Sales", '₹${controller.serverTodaySales.value.toStringAsFixed(0)}', Icons.today, const Color(0xFF00E5FF)),
                _buildMetricCard('Spin Sales', '${controller.serverTotalSpins.value}', Icons.casino, const Color(0xFF00E676)),
                _buildMetricCard('Direct Sales', '${controller.serverDirectSalesCount.value} (₹${controller.serverDirectSalesAmount.value.toStringAsFixed(0)})', Icons.shopping_cart, const Color(0xFF00E676)),
                _buildMetricCard('Salesmen', '${controller.serverSalesmen.length}', Icons.people, const Color(0xFF00E5FF)),
                _buildMetricCard('Products', '${controller.serverProducts.length}', Icons.inventory_2, const Color(0xFF00E676)),
              ],
            ),
          ),

          // 2. Sales tracking chart
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '📊 SALES COLLECTION & SPINS TREND', 
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GlassmorphismCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SalesTrackingChart(
                    dates: controller.chartDatesList,
                    sales: controller.chartSalesList,
                    spins: controller.chartSpinsList,
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.horizontal_rule, color: Color(0xFF00E5FF), size: 16),
                      SizedBox(width: 4),
                      Text('Sales Collection (₹)', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      SizedBox(width: 16),
                      Icon(Icons.square, color: Color(0xFF00E676), size: 10),
                      SizedBox(width: 4),
                      Text('Spins Completed', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Grid Action Menu
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '🛠️ PORTAL ACTIONS MENU', 
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuActionButton(
                        'Spin Sales Report',
                        'Spin Log & CSV',
                        Icons.casino,
                        const Color(0xFF00E5FF),
                        () => Get.to(() => const HistoryLogsSubView()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMenuActionButton(
                        'Direct Sales Report',
                        'Direct Log & CSV',
                        Icons.shopping_cart,
                        const Color(0xFF00E676),
                        () => Get.to(() => const DirectSalesReportSubView()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuActionButton(
                        'Total Sales Report',
                        'Combined Log & CSV',
                        Icons.analytics,
                        const Color(0xFF00E5FF),
                        () => Get.to(() => const TotalSalesReportSubView()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMenuActionButton(
                        'Products',
                        'Manage Catalog',
                        Icons.shopping_bag,
                        const Color(0xFF00E676),
                        () => Get.to(() => const ProductsManagementSubView()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuActionButton(
                        'Salesmen',
                        'Setup Accounts',
                        Icons.badge,
                        const Color(0xFF00E5FF),
                        () => Get.to(() => const SalesmenManagementSubView()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMenuActionButton(
                        'Branding & Setup',
                        'Customize Titles & Logo',
                        Icons.tune,
                        const Color(0xFF00E676),
                        () => Get.to(() => const BrandingSetupSubView()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Auto-Sync details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GlassmorphismCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    controller.isServerOnline.value ? Icons.cloud_done : Icons.cloud_off,
                    color: controller.isServerOnline.value ? const Color(0xFF00E676) : Colors.redAccent,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.isServerOnline.value ? 'Sync Service Active' : 'Server Offline',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          controller.winners.isEmpty 
                              ? 'No offline records queued' 
                              : '${controller.unsyncedCount} records waiting for connection',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (controller.isSyncing.value)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2))
                  else if (controller.unsyncedCount > 0)
                    const Text('Auto-Sync Pending...', style: TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          if (controller.winners.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
              child: Text(
                'QUEUED OFFLINE TRANSACTIONS', 
                style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.winners.length,
              itemBuilder: (context, index) {
                final winner = controller.winners[index];
                return _buildOfflineCard(winner);
              },
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuActionButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle, 
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineCard(Map<String, dynamic> winner) {
    String timeStr = '';
    if (winner['created_at'] != null) {
      try {
        final dt = DateTime.parse(winner['created_at']).toLocal();
        timeStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (winner['photoPath'] != null && winner['photoPath'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(winner['photoPath']),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.white10),
                ),
              )
            else
              Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person, color: Colors.white30)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${winner['customerName']} (${winner['mobileNumber']})', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Prize: ${winner['prize']}', style: const TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('${winner['salesman']} • ${winner['product']} (Qty: ${winner['quantity']})', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  if (timeStr.isNotEmpty) Text(timeStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==========================================
// SUB-VIEW 1: HISTORY LOGS & NATIVE EXPORT
// ==========================================
class HistoryLogsSubView extends GetView<AdminDashboardController> {
  const HistoryLogsSubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Spin Sales Report', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
        backgroundColor: const Color(0xFF070C16).withOpacity(0.9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF00E676)),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportWinnersToCSV(filterType: 'spin'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070C16), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Dynamic Dropdown Filters Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Salesman Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() {
                          final salesmen = <String>[''];
                          for (var s in controller.serverSalesmen) {
                            final name = s['name']?.toString() ?? '';
                            if (name.isNotEmpty && !salesmen.contains(name)) {
                              salesmen.add(name);
                            }
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedSalesmanFilter.value,
                              dropdownColor: const Color(0xFF0D1B2A),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              hint: const Text('Salesman (All)', style: TextStyle(color: Colors.white70)),
                              items: salesmen.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s.isEmpty ? 'All Salesmen' : s),
                                );
                              }).toList(),
                              onChanged: (val) {
                                controller.selectedSalesmanFilter.value = val ?? '';
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Product Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() {
                          final products = <String>[''];
                          for (var p in controller.serverProducts) {
                            final name = p['name']?.toString() ?? '';
                            if (name.isNotEmpty && !products.contains(name)) {
                              products.add(name);
                            }
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedProductFilter.value,
                              dropdownColor: const Color(0xFF0D1B2A),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              hint: const Text('Product (All)', style: TextStyle(color: Colors.white70)),
                              items: products.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p,
                                  child: Text(p.isEmpty ? 'All Products' : p),
                                );
                              }).toList(),
                              onChanged: (val) {
                                controller.selectedProductFilter.value = val ?? '';
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Filtered Winners List
              Expanded(
                child: Obx(() {
                  final list = controller.filteredSpinWinners;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 10),
                          const Text('No records matching filters found.', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final w = list[index];
                      return _buildLiveHistoryCard(context, w);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1B2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXPORT SALES REPORT (CSV)',
              style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.exportWinnersToCSV(filterType: 'all');
                },
                icon: const Icon(Icons.all_inclusive, color: Colors.black),
                label: const Text('EXPORT ALL SALES RECORDS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.exportWinnersToCSV(filterType: 'spin');
                },
                icon: const Icon(Icons.stars, color: Colors.black),
                label: const Text('EXPORT SPIN RECORDS ONLY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.exportWinnersToCSV(filterType: 'direct');
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                label: const Text('EXPORT DIRECT SALES (WITHOUT SPIN)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveHistoryCard(BuildContext context, Map<String, dynamic> w) {
    String timeStr = '';
    if (w['created_at'] != null) {
      try {
        final dt = DateTime.parse(w['created_at']).toLocal();
        timeStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final imageUrl = (w['photo_path'] != null && w['photo_path'].toString().isNotEmpty)
        ? '${ApiConfig.baseUrl}/${w['photo_path'].toString().replaceAll('api/', '')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 65, height: 65, color: Colors.white10, child: const Icon(Icons.broken_image, size: 20, color: Colors.white24)),
                ),
              )
            else
              Container(width: 65, height: 65, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person, color: Colors.white24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${w['customer_name']} (${w['mobile_number']})', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Text('₹${w['net_amount']}', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: (w['spin_eligible'] == 1) ? const Color(0xFF00E5FF).withOpacity(0.15) : const Color(0xFF00E676).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: (w['spin_eligible'] == 1) ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          (w['spin_eligible'] == 1) ? 'SPIN SALE' : 'DIRECT',
                          style: TextStyle(
                            color: (w['spin_eligible'] == 1) ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (w['spin_eligible'] == 1) ? 'Prize: ${w['prize_won']}' : 'Direct Checkout',
                          style: TextStyle(
                            color: (w['spin_eligible'] == 1) ? const Color(0xFF00E676) : Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text('${w['salesman_name']} • ${w['product_name']} (Qty: ${w['quantity']})', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  if (timeStr.isNotEmpty) Text(timeStr, style: const TextStyle(color: Colors.white30, fontSize: 10)),
                  if (w['latitude'] != null && w['longitude'] != null && w['latitude'].toString().isNotEmpty && w['longitude'].toString().isNotEmpty && w['latitude'].toString() != 'null' && w['longitude'].toString() != 'null')
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: GestureDetector(
                        onTap: () async {
                          final lat = w['latitude'];
                          final lng = w['longitude'];
                          final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                          try {
                            if (await canLaunchUrl(googleMapsUrl)) {
                              await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                            }
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF00E5FF), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Location: ${w['latitude']}, ${w['longitude']}',
                              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(() {
                final id = int.tryParse(w['id'].toString()) ?? 0;
                controller.deleteWinner(id);
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this record?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}


// ==========================================
// SUB-VIEW 1B: DIRECT SALES REPORT & EXPORT
// ==========================================
class DirectSalesReportSubView extends GetView<AdminDashboardController> {
  const DirectSalesReportSubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Direct Sales Report', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
        backgroundColor: const Color(0xFF070C16).withOpacity(0.9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF00E676)),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportWinnersToCSV(filterType: 'direct'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070C16), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Dynamic Dropdown Filters Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Salesman Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() {
                          final salesmen = <String>[''];
                          for (var s in controller.serverSalesmen) {
                            final name = s['name']?.toString() ?? '';
                            if (name.isNotEmpty && !salesmen.contains(name)) {
                              salesmen.add(name);
                            }
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedSalesmanFilter.value,
                              dropdownColor: const Color(0xFF0D1B2A),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              hint: const Text('Salesman (All)', style: TextStyle(color: Colors.white70)),
                              items: salesmen.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s.isEmpty ? 'All Salesmen' : s),
                                );
                              }).toList(),
                              onChanged: (val) {
                                controller.selectedSalesmanFilter.value = val ?? '';
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Product Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() {
                          final products = <String>[''];
                          for (var p in controller.serverProducts) {
                            final name = p['name']?.toString() ?? '';
                            if (name.isNotEmpty && !products.contains(name)) {
                              products.add(name);
                            }
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedProductFilter.value,
                              dropdownColor: const Color(0xFF0D1B2A),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              hint: const Text('Product (All)', style: TextStyle(color: Colors.white70)),
                              items: products.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p,
                                  child: Text(p.isEmpty ? 'All Products' : p),
                                );
                              }).toList(),
                              onChanged: (val) {
                                controller.selectedProductFilter.value = val ?? '';
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Filtered Direct Winners List
              Expanded(
                child: Obx(() {
                  final list = controller.filteredDirectWinners;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 10),
                          const Text('No direct sales records found.', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final w = list[index];
                      return _buildLiveHistoryCard(context, w);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHistoryCard(BuildContext context, Map<String, dynamic> w) {
    String timeStr = '';
    if (w['created_at'] != null) {
      try {
        final dt = DateTime.parse(w['created_at']).toLocal();
        timeStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final imageUrl = (w['photo_path'] != null && w['photo_path'].toString().isNotEmpty)
        ? '${ApiConfig.baseUrl}/${w['photo_path'].toString().replaceAll('api/', '')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 65, height: 65, color: Colors.white10, child: const Icon(Icons.broken_image, size: 20, color: Colors.white24)),
                ),
              )
            else
              Container(width: 65, height: 65, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.shopping_cart, color: Colors.white24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${w['customer_name']} (${w['mobile_number']})', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Text('₹${w['net_amount']}', style: const TextStyle(color: Color(0xFF00E676), fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF00E676),
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          'DIRECT',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Direct Checkout',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text('${w['salesman_name']} • ${w['product_name']} (Qty: ${w['quantity']})', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  if (timeStr.isNotEmpty) Text(timeStr, style: const TextStyle(color: Colors.white30, fontSize: 10)),
                  if (w['latitude'] != null && w['longitude'] != null && w['latitude'].toString().isNotEmpty && w['longitude'].toString().isNotEmpty && w['latitude'].toString() != 'null' && w['longitude'].toString() != 'null')
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: GestureDetector(
                        onTap: () async {
                          final lat = w['latitude'];
                          final lng = w['longitude'];
                          final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                          try {
                            if (await canLaunchUrl(googleMapsUrl)) {
                              await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                            }
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF00E5FF), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Location: ${w['latitude']}, ${w['longitude']}',
                              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(() {
                final id = int.tryParse(w['id'].toString()) ?? 0;
                controller.deleteWinner(id);
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this record?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}


// ==========================================
// SUB-VIEW 1C: TOTAL SALES REPORT & EXPORT
// ==========================================
class TotalSalesReportSubView extends GetView<AdminDashboardController> {
  const TotalSalesReportSubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Total Sales Report', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
        backgroundColor: const Color(0xFF070C16).withOpacity(0.9),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF00E676)),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportWinnersToCSV(filterType: 'all'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070C16), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Dynamic Dropdown Filters Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Salesman Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() {
                          final salesmen = <String>[''];
                          for (var s in controller.serverSalesmen) {
                            final name = s['name']?.toString() ?? '';
                            if (name.isNotEmpty && !salesmen.contains(name)) {
                              salesmen.add(name);
                            }
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedSalesmanFilter.value,
                              dropdownColor: const Color(0xFF0D1B2A),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              hint: const Text('Salesman (All)', style: TextStyle(color: Colors.white70)),
                              items: salesmen.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s.isEmpty ? 'All Salesmen' : s),
                                );
                              }).toList(),
                              onChanged: (val) {
                                controller.selectedSalesmanFilter.value = val ?? '';
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Product Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() {
                          final products = <String>[''];
                          for (var p in controller.serverProducts) {
                            final name = p['name']?.toString() ?? '';
                            if (name.isNotEmpty && !products.contains(name)) {
                              products.add(name);
                            }
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedProductFilter.value,
                              dropdownColor: const Color(0xFF0D1B2A),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              hint: const Text('Product (All)', style: TextStyle(color: Colors.white70)),
                              items: products.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p,
                                  child: Text(p.isEmpty ? 'All Products' : p),
                                );
                              }).toList(),
                              onChanged: (val) {
                                controller.selectedProductFilter.value = val ?? '';
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Filtered Winners List
              Expanded(
                child: Obx(() {
                  final list = controller.filteredWinners;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 10),
                          const Text('No sales records found.', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final w = list[index];
                      return _buildLiveHistoryCard(context, w);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHistoryCard(BuildContext context, Map<String, dynamic> w) {
    String timeStr = '';
    if (w['created_at'] != null) {
      try {
        final dt = DateTime.parse(w['created_at']).toLocal();
        timeStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final imageUrl = (w['photo_path'] != null && w['photo_path'].toString().isNotEmpty)
        ? '${ApiConfig.baseUrl}/${w['photo_path'].toString().replaceAll('api/', '')}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 65, height: 65, color: Colors.white10, child: const Icon(Icons.broken_image, size: 20, color: Colors.white24)),
                ),
              )
            else
              Container(width: 65, height: 65, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.analytics, color: Colors.white24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${w['customer_name']} (${w['mobile_number']})', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Text('₹${w['net_amount']}', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: (w['spin_eligible'] == 1) ? const Color(0xFF00E5FF).withOpacity(0.15) : const Color(0xFF00E676).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: (w['spin_eligible'] == 1) ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          (w['spin_eligible'] == 1) ? 'SPIN SALE' : 'DIRECT',
                          style: TextStyle(
                            color: (w['spin_eligible'] == 1) ? const Color(0xFF00E5FF) : const Color(0xFF00E676),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (w['spin_eligible'] == 1) ? 'Prize: ${w['prize_won']}' : 'Direct Checkout',
                          style: TextStyle(
                            color: (w['spin_eligible'] == 1) ? const Color(0xFF00E676) : Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text('${w['salesman_name']} • ${w['product_name']} (Qty: ${w['quantity']})', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  if (timeStr.isNotEmpty) Text(timeStr, style: const TextStyle(color: Colors.white30, fontSize: 10)),
                  if (w['latitude'] != null && w['longitude'] != null && w['latitude'].toString().isNotEmpty && w['longitude'].toString().isNotEmpty && w['latitude'].toString() != 'null' && w['longitude'].toString() != 'null')
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: GestureDetector(
                        onTap: () async {
                          final lat = w['latitude'];
                          final lng = w['longitude'];
                          final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                          try {
                            if (await canLaunchUrl(googleMapsUrl)) {
                              await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                            }
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF00E5FF), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Location: ${w['latitude']}, ${w['longitude']}',
                              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(() {
                final id = int.tryParse(w['id'].toString()) ?? 0;
                controller.deleteWinner(id);
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this record?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}


// ==========================================
// SUB-VIEW 2: PRODUCT MANAGEMENT
// ==========================================
class ProductsManagementSubView extends GetView<AdminDashboardController> {
  const ProductsManagementSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Product Management', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
        backgroundColor: const Color(0xFF070C16).withOpacity(0.9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070C16), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ADD NEW PRODUCT', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GlassmorphismCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: Icon(Icons.shopping_bag, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Price (₹)',
                          prefixIcon: Icon(Icons.monetization_on, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final price = double.tryParse(priceController.text.trim()) ?? -1.0;
                            if (name.isEmpty || price < 0) {
                              Get.snackbar('Input Error', 'Please enter valid name and price.', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            controller.addProduct(name, price);
                            nameController.clear();
                            priceController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('ADD PRODUCT'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('EXISTING PRODUCTS', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.serverProducts.length,
                  itemBuilder: (context, index) {
                    final prod = controller.serverProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GlassmorphismCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prod['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('₹${prod['price'] ?? '0.00'}', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(() {
                                final id = int.tryParse(prod['id'].toString()) ?? 0;
                                controller.deleteProduct(id);
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this product?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}


// ==========================================
// SUB-VIEW 3: SALESMEN MANAGEMENT
// ==========================================
class SalesmenManagementSubView extends GetView<AdminDashboardController> {
  const SalesmenManagementSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final salesmanController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Salesmen Setup', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
        backgroundColor: const Color(0xFF070C16).withOpacity(0.9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070C16), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ADD NEW SALESMAN', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GlassmorphismCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: salesmanController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Salesman Name',
                          prefixIcon: Icon(Icons.person_add, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = salesmanController.text.trim();
                            if (name.isEmpty) {
                              Get.snackbar('Input Error', 'Please enter a name.', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            controller.addSalesman(name);
                            salesmanController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('ADD SALESMAN'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('REGISTERED SALESMEN', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.serverSalesmen.length,
                  itemBuilder: (context, index) {
                    final sm = controller.serverSalesmen[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GlassmorphismCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sm['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(() {
                                final id = int.tryParse(sm['id'].toString()) ?? 0;
                                controller.deleteSalesman(id);
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this salesman?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}


// ==========================================
// SUB-VIEW 4: BRANDING SETUP & WHEEL PRIZES
// ==========================================
class BrandingSetupSubView extends GetView<AdminDashboardController> {
  const BrandingSetupSubView({super.key});

  Future<void> _pickAndUploadLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        await controller.uploadLogoImage(image.path);
      }
    } catch (e) {
      Get.snackbar('Upload Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branding = Get.find<BrandingController>();
    final titleController = TextEditingController(text: branding.appTitle.value);
    final subtitleController = TextEditingController(text: branding.appSubtitle.value);
    final premiumController = TextEditingController(text: branding.premiumTitle.value);
    final superadminPassController = TextEditingController(text: branding.superadminPassword.value);
    final salesmanPassController = TextEditingController(text: branding.salesmanPassword.value);
    
    final prizeController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Branding Configurations', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
        backgroundColor: const Color(0xFF070C16).withOpacity(0.9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070C16), Color(0xFF0D1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WHITE LABEL BRANDING', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GlassmorphismCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Logo Image Preview and Upload Button
                      Obx(() {
                        final logo = branding.logoUrl.value;
                        return Column(
                          children: [
                            if (logo.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    logo,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => Container(
                                      height: 80,
                                      width: 80,
                                      color: Colors.white10,
                                      child: const Icon(Icons.broken_image, color: Colors.white30),
                                    ),
                                  ),
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: _pickAndUploadLogo,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('UPLOAD LOGO IMAGE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'App Title',
                          prefixIcon: Icon(Icons.title, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: subtitleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'App Subtitle',
                          prefixIcon: Icon(Icons.subtitles, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: premiumController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Premium Title',
                          prefixIcon: Icon(Icons.star, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      const Text(
                        'ACCESS SECURITY CONFIGURATION',
                        style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: superadminPassController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Super Admin Password',
                          prefixIcon: Icon(Icons.admin_panel_settings, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: salesmanPassController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Salesman Role Password',
                          prefixIcon: Icon(Icons.lock, color: Color(0xFF00E5FF)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final t = titleController.text.trim();
                            final s = subtitleController.text.trim();
                            final p = premiumController.text.trim();
                            final adminPass = superadminPassController.text.trim();
                            final salesPass = salesmanPassController.text.trim();

                            if (t.isEmpty) {
                              Get.snackbar('Input Error', 'App Title cannot be empty.', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            if (adminPass.isEmpty || salesPass.isEmpty) {
                              Get.snackbar('Input Error', 'Passwords cannot be empty.', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            
                            controller.updateBrandingSettings(t, s, p, adminPass, salesPass);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('SAVE BRANDING & PASSWORDS'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('MANAGE SPIN WHEEL PRIZES', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GlassmorphismCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: prizeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'New Prize (e.g. ₹5, ₹10)',
                            prefixIcon: Icon(Icons.casino, color: Color(0xFF00E5FF)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final val = prizeController.text.trim();
                          if (val.isEmpty) {
                            Get.snackbar('Input Error', 'Please enter a value.', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          controller.addSpin(val);
                          prizeController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('ADD'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.serverSpins.length,
                  itemBuilder: (context, index) {
                    final spin = controller.serverSpins[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GlassmorphismCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(spin['prize_name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(() {
                                final id = int.tryParse(spin['id'].toString()) ?? 0;
                                controller.deleteSpin(id);
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(VoidCallback onConfirm) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this spin prize?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        onConfirm();
        Get.back();
      },
    );
  }
}


// --- CUSTOM PAINTED CHART FOR TRENDS ---
class SalesTrackingChart extends StatelessWidget {
  final List<String> dates;
  final List<double> sales;
  final List<int> spins;

  const SalesTrackingChart({
    super.key,
    required this.dates,
    required this.sales,
    required this.spins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ChartPainter(dates, sales, spins),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<String> dates;
  final List<double> sales;
  final List<int> spins;

  _ChartPainter(this.dates, this.sales, this.spins);

  @override
  void paint(Canvas canvas, Size size) {
    if (dates.isEmpty) return;

    const double paddingLeft = 45.0;
    const double paddingBottom = 25.0;
    const double paddingTop = 15.0;
    const double paddingRight = 35.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    // Find Max values for dynamic scale
    double maxSales = sales.reduce((a, b) => a > b ? a : b);
    if (maxSales < 100.0) maxSales = 1000.0;

    int maxSpins = spins.reduce((a, b) => a > b ? a : b);
    if (maxSpins < 5) maxSpins = 5;

    // 1. Draw horizontal grid lines and labels
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 3; i++) {
      final y = paddingTop + chartHeight * (1 - i / 3);
      
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      // Y-Axis Left (Sales Amount Label)
      final labelVal = maxSales * (i / 3);
      textPainter.text = TextSpan(
        text: '₹${labelVal >= 1000 ? '${(labelVal / 1000).toStringAsFixed(1)}k' : labelVal.toStringAsFixed(0)}',
        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 6, y - textPainter.height / 2));

      // Y-Axis Right (Spins Count Label)
      final labelSpins = (maxSpins * (i / 3)).round();
      textPainter.text = TextSpan(
        text: '$labelSpins',
        style: const TextStyle(color: Color(0xFF00E676), fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - paddingRight + 6, y - textPainter.height / 2));
    }

    final double stepWidth = dates.length > 1
        ? chartWidth / (dates.length - 1)
        : chartWidth;

    // 2. Draw Daily Spins as Green Columns
    final barPaint = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final barStrokePaint = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final double barWidth = (stepWidth * 0.45).clamp(8.0, 16.0);

    for (int i = 0; i < dates.length; i++) {
      final x = paddingLeft + i * stepWidth;
      final double spinHeight = (spins[i] / maxSpins) * chartHeight;
      final y = paddingTop + chartHeight - spinHeight;

      if (spins[i] > 0) {
        final rect = Rect.fromLTRB(x - barWidth / 2, y, x + barWidth / 2, paddingTop + chartHeight);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), barPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), barStrokePaint);
      }
    }

    // 3. Draw Daily Sales as Line Graph (Sky Blue)
    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final shadowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dates.length; i++) {
      final x = paddingLeft + i * stepWidth;
      final double salesHeight = (sales[i] / maxSales) * chartHeight;
      final y = paddingTop + chartHeight - salesHeight;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, paddingTop + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        final prevX = paddingLeft + (i - 1) * stepWidth;
        final double prevSalesHeight = (sales[i - 1] / maxSales) * chartHeight;
        final prevY = paddingTop + chartHeight - prevSalesHeight;
        
        path.cubicTo(
          prevX + stepWidth / 2, prevY,
          x - stepWidth / 2, y,
          x, y
        );
        fillPath.cubicTo(
          prevX + stepWidth / 2, prevY,
          x - stepWidth / 2, y,
          x, y
        );
      }

      if (i == dates.length - 1) {
        fillPath.lineTo(x, paddingTop + chartHeight);
        fillPath.close();
      }
    }

    if (dates.length > 1) {
      canvas.drawPath(fillPath, shadowPaint);
      canvas.drawPath(path, linePaint);
    }

    // 4. Glowing markers and X-Axis Date Labels
    final markerPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    final markerGlow = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 0; i < dates.length; i++) {
      final x = paddingLeft + i * stepWidth;
      final double salesHeight = (sales[i] / maxSales) * chartHeight;
      final y = paddingTop + chartHeight - salesHeight;

      canvas.drawCircle(Offset(x, y), 5.0, markerGlow);
      canvas.drawCircle(Offset(x, y), 3.0, markerPaint);

      textPainter.text = TextSpan(
        text: dates[i],
        style: const TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, paddingTop + chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
