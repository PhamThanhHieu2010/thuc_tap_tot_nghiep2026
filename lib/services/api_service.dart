import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import '../models/bill.dart';
import '../models/notification_model.dart'; // <-- IMPORT MODEL MỚI

class ApiService {
  
  // --- 1. DỌN DẸP DỮ LIỆU DEMO (TÍNH NĂNG MỚI) ---
  // Hàm này sẽ xóa sạch các record có cờ isDemo = true
  Future<void> cleanupDemoData(String userId) async {
    await _cleanupPath(userId, 'transactions');
    await _cleanupPath(userId, 'savings_goals');
    await _cleanupPath(userId, 'bills');
  }

  Future<void> _cleanupPath(String userId, String path) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/$path.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> data = json.decode(response.body);
        data.forEach((key, value) async {
          if (value['isDemo'] == true) {
            final deleteUrl = Uri.parse('${AppConstants.dbUrl}/users/$userId/$path/$key.json');
            await http.delete(deleteUrl);
          }
        });
      }
    } catch (e) { print("Cleanup error: $e"); }
  }

  // --- 2. TỶ GIÁ (API MỚI ỔN ĐỊNH) ---
  Future<double> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;
    try {
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/$from');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && data['rates'][to] != null) {
          return (data['rates'][to]).toDouble();
        }
      }
    } catch (e) { print("Rate error: $e"); }
    return 0.0;
  }

  // --- 3. GIAO DỊCH (TRANSACTIONS) ---
  Future<List<TransactionModel>> fetchTransactionsByMode(String targetId, bool isFamilyMode) async {
    final path = isFamilyMode ? 'families' : 'users';
    final url = Uri.parse('${AppConstants.dbUrl}/$path/$targetId/transactions.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<TransactionModel> loaded = [];
        data.forEach((key, value) { loaded.add(TransactionModel.fromJson(key, value)); });
        loaded.sort((a, b) => b.date.compareTo(a.date));
        return loaded;
      }
      return [];
    } catch (e) { return []; }
  }

  Future<void> addTransactionByMode(String targetId, TransactionModel tx, bool isFamilyMode) async {
    final path = isFamilyMode ? 'families' : 'users';
    final url = Uri.parse('${AppConstants.dbUrl}/$path/$targetId/transactions.json');
    await http.post(url, body: json.encode(tx.toJson()));
  }

  Future<void> deleteTransaction(String userId, String txId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/transactions/$txId.json');
    await http.delete(url);
  }

  // --- 4. HÓA ĐƠN & TIẾT KIỆM (CÁC HÀM UPDATE) ---
  Future<List<BillModel>> fetchBills(String userId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/bills.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<BillModel> loaded = [];
        data.forEach((key, value) { loaded.add(BillModel.fromJson(key, value)); });
        loaded.sort((a, b) => a.isPaid ? 1 : -1);
        return loaded;
      }
      return [];
    } catch (e) { return []; }
  }
  Future<void> addBill(String userId, BillModel bill) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/bills.json');
    await http.post(url, body: json.encode(bill.toJson()));
  }
  Future<void> deleteBill(String userId, String billId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/bills/$billId.json');
    await http.delete(url);
  }
  Future<void> updateBillStatus(String userId, String billId, bool isPaid) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/bills/$billId.json');
    await http.patch(url, body: json.encode({'isPaid': isPaid}));
  }
  Future<void> updateBill(String userId, String billId, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/bills/$billId.json');
    await http.patch(url, body: json.encode(data));
  }

  Future<List<SavingsGoalModel>> fetchSavings(String userId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/savings_goals.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<SavingsGoalModel> loaded = [];
        data.forEach((key, value) { loaded.add(SavingsGoalModel.fromJson(key, value)); });
        return loaded;
      }
      return [];
    } catch (e) { return []; }
  }
  Future<void> addSavings(String userId, SavingsGoalModel goal) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/savings_goals.json');
    await http.post(url, body: json.encode(goal.toJson()));
  }
  Future<void> deleteSavings(String userId, String goalId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/savings_goals/$goalId.json');
    await http.delete(url);
  }
  Future<void> updateSavingsAmount(String userId, String goalId, double newAmount) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/savings_goals/$goalId.json');
    await http.patch(url, body: json.encode({'currentAmount': newAmount}));
  }

  // --- 5. USER (AUTH & PROFILE) ---
  Future<void> registerUser(String userId, Map<String, dynamic> userData) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/profile.json');
    await http.put(url, body: json.encode(userData));
  }
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/profile.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != "null") {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) { print(e); }
    return null;
  }
  Future<void> updatePassword(String userId, String newPass) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/profile.json');
    await http.patch(url, body: json.encode({'password': newPass}));
  }
  Future<void> updateLanguage(String userId, String langCode) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/profile.json');
    await http.patch(url, body: json.encode({'language': langCode}));
  }
  Future<void> updateFamilyId(String userId, String familyId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/profile.json');
    await http.patch(url, body: json.encode({'familyId': familyId}));
  }

  // --- 6. HỆ THỐNG THÔNG BÁO (TÍNH NĂNG MỚI: SỐ HÓA THÔNG BÁO) ---
  
  // A. Lấy danh sách thông báo về
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/notifications.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<NotificationModel> loaded = [];
        data.forEach((key, value) {
          loaded.add(NotificationModel.fromJson(key, value));
        });
        
        // Sắp xếp: Mới nhất lên đầu
        loaded.sort((a, b) => b.time.compareTo(a.time));
        return loaded;
      }
    } catch (e) {
      print("Lỗi tải thông báo: $e");
    }
    return [];
  }

  // B. Lưu thông báo mới lên Server
  Future<void> addNotification(String userId, NotificationModel notif) async {
    final url = Uri.parse('${AppConstants.dbUrl}/users/$userId/notifications/${notif.id}.json');
    try {
      // Dùng PUT để ghi đè theo ID (do NotificationModel đã tự sinh ID)
      await http.put(url, body: json.encode(notif.toJson()));
    } catch (e) {
      print("Lỗi lưu thông báo: $e");
    }
  }
}