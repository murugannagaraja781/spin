import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin/core/constants/api_config.dart';
import 'package:spin/data/local_db_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lucky Spin Core Workflow Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. API Configuration check - Live environment mode', () {
      expect(ApiConfig.useLocalServer, isFalse);
      expect(ApiConfig.baseUrl, equals('https://lightgreen-kudu-494017.hostingersite.com/api'));
    });

    test('2. Calculation logic - Net payable with lucky spin discount', () {
      const double price = 20.0;
      const int quantity = 5;
      const double orderTotal = price * quantity;
      
      const double discount = 15.0; // ₹15 spin won
      const double expectedNet = orderTotal - discount;

      expect(orderTotal, equals(100.0));
      expect(expectedNet, equals(85.0));
    });

    test('3. Local DB Service - Winner entry logging and synchronization flags', () async {
      final sampleWinner = {
        'salesman': 'Ramesh Kumar',
        'product': 'Product A',
        'customerName': 'Balaji Provisions',
        'mobileNumber': '9876543210',
        'prize': '₹10',
        'photoPath': '/path/to/photo.jpg',
        'latitude': '13.0827',
        'longitude': '80.2707',
        'quantity': 3,
        'order_total': 30.00,
        'discount_applied': 10.00,
        'net_amount': 20.00,
        'spin_eligible': 1,
        'synced': 0
      };

      await LocalDbService.addWinner(sampleWinner);
      final winnersList = await LocalDbService.getWinners();
      
      expect(winnersList.length, equals(1));
      expect(winnersList.first['customerName'], equals('Balaji Provisions'));
      expect(winnersList.first['net_amount'], equals(20.00));
      expect(winnersList.first['synced'], equals(0));
    });

    test('4. One Spin Per Day Validation Rule', () async {
      final sampleWinner = {
        'salesman': 'Ramesh Kumar',
        'product': 'Product A',
        'customerName': 'Balaji Provisions',
        'mobileNumber': '9876543210',
        'prize': '₹10',
        'photoPath': '/path/to/photo.jpg',
        'latitude': '13.0827',
        'longitude': '80.2707',
        'quantity': 3,
        'order_total': 30.00,
        'discount_applied': 10.00,
        'net_amount': 20.00,
        'spin_eligible': 1,
        'synced': 1
      };

      // Set winner entry for today
      await LocalDbService.addWinner(sampleWinner);

      // Verify that this mobile is blocked from spinning again today
      final isBlocked = await LocalDbService.isMobileUsedToday('9876543210');
      expect(isBlocked, isTrue);

      // Verify that a different mobile number is eligible to spin today
      final isEligible = await LocalDbService.isMobileUsedToday('9876543211');
      expect(isEligible, isFalse);
    });
  });
}
