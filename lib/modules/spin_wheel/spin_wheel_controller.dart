import 'dart:async';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../core/constants/api_config.dart';

class SpinWheelController extends GetxController {
  final StreamController<int> wheelController = StreamController<int>();
  final AudioPlayer audioPlayer = AudioPlayer();
  
  final prizes = <String>[].obs;
  final isSpinning = false.obs;
  final spinCompleted = false.obs;
  final winningPrize = ''.obs;
  final isLoading = true.obs;
  final String _baseUrl = ApiConfig.baseUrl;
  
  late String salesman;
  late String customerName;
  late String mobileNumber;
  late String product;
  late String price;
  late int quantity;
  late double orderTotal;
  late bool spinEligible;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    salesman = args['salesman']?.toString() ?? '';
    customerName = args['customerName']?.toString() ?? '';
    mobileNumber = args['mobileNumber']?.toString() ?? '';
    product = args['product']?.toString() ?? '';
    price = args['price']?.toString() ?? '';
    quantity = args['quantity'] as int? ?? 1;
    orderTotal = args['orderTotal'] as double? ?? 0.0;
    spinEligible = args['spin_eligible'] as bool? ?? true;
    fetchPrizes();
  }

  Future<void> fetchPrizes() async {
    isLoading.value = true;
    try {
      final response = await dio_pkg.Dio().get('$_baseUrl/get_spins.php');
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final data = response.data['data'] as List;
          final prizeList = data
              .map((item) => item['prize_name'].toString())
              .toList();
          prizes.assignAll(prizeList);
        }
      }
    } catch (e) {
      print('Prize fetch error: $e');
      // Fallback to default prizes (matching the ones config'd)
      prizes.assignAll(['₹5', '₹10', '₹15', '₹20', '₹25', '₹30', '₹35', '₹40', '₹45', '₹50']);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    wheelController.close();
    super.onClose();
  }

  void spin() async {
    if (isSpinning.value) return;

    isSpinning.value = true;
    spinCompleted.value = false;
    
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource('audio/tick.ogg'));

    // Randomize winning index
    final winningIndex = DateTime.now().millisecondsSinceEpoch % prizes.length;
    winningPrize.value = prizes[winningIndex];

    wheelController.add(winningIndex);
  }

  void onSpinEnd() {
    audioPlayer.stop();
    isSpinning.value = false;
    spinCompleted.value = true;
  }

  double getDiscountAmount() {
    final prizeStr = winningPrize.value;
    final numericStr = prizeStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericStr) ?? 0.0;
  }

  void continueToWinnerDetails() {
    if (!spinCompleted.value) return;

    final discount = getDiscountAmount();
    final netAmount = (orderTotal - discount).clamp(0.0, double.infinity);

    Get.offNamed('/photo-capture', arguments: {
      'salesman': salesman,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'product': product,
      'price': price,
      'quantity': quantity,
      'orderTotal': orderTotal,
      'prize': winningPrize.value,
      'discount_applied': discount,
      'net_amount': netAmount,
      'spin_eligible': true,
    });
  }
}
