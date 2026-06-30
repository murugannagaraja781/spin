import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDbService {
  static const String _dbKey = 'lucky_spin_winners_db';

  static Future<List<Map<String, dynamic>>> getWinners() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_dbKey);
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> isMobileUsed(String mobileNumber, String product) async {
    final winners = await getWinners();
    return winners.any((w) => w['mobileNumber'] == mobileNumber && w['product'] == product);
  }

  static Future<bool> isMobileUsedToday(String mobileNumber, String product) async {
    final winners = await getWinners();
    final today = DateTime.now();
    return winners.any((w) {
      if (w['mobileNumber'] != mobileNumber) return false;
      if (w['product'] != product) return false;
      if (w['spin_eligible'] == 0 || w['spin_eligible'] == false) return false;
      
      try {
        final dt = DateTime.parse(w['created_at']);
        return dt.year == today.year && dt.month == today.month && dt.day == today.day;
      } catch (_) {
        return false;
      }
    });
  }

  static Future<void> addWinner(Map<String, dynamic> winnerData) async {
    final winners = await getWinners();
    winnerData['created_at'] = DateTime.now().toIso8601String();
    winners.add(winnerData);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dbKey, jsonEncode(winners));
  }

  static Future<void> saveWinners(List<Map<String, dynamic>> winnersList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dbKey, jsonEncode(winnersList));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dbKey);
  }
}
