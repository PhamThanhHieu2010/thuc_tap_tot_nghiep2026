import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import '../models/bill.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<TransactionModel> _transactions = [];
  List<SavingsGoalModel> _savings = [];
  List<BillModel> _bills = [];
  List<NotificationModel> _notifications = []; // Danh sách thông báo (đã đồng bộ Server)
  
  bool _isLoading = false;
  bool _isFamilyMode = false;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<SavingsGoalModel> get savings => _savings;
  List<BillModel> get bills => _bills;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isFamilyMode => _isFamilyMode;

  // Tính toán dòng tiền
  double get totalIncome => _transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpense => _transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);
  double get totalBalance => totalIncome - totalExpense;

  bool hasEnoughBalance(double amount) => totalBalance >= amount;

  // --- 1. LOAD DATA (TỰ ĐỘNG XÓA DEMO & TẢI THÔNG BÁO) ---
  Future<void> loadAllUserData(String userId, String? familyId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // A. Dọn dẹp dữ liệu Demo cũ (nếu có)
      await _apiService.cleanupDemoData(userId);
      
      // B. Tải dữ liệu thật từ Server
      await Future.wait([
        fetchTransactions(userId, familyId),
        fetchSavings(userId),
        fetchBills(userId),
        fetchNotifications(userId), // <--- Tải thông báo về
      ]);
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _transactions = []; 
    _savings = []; 
    _bills = []; 
    _notifications = []; // Xóa sạch khi logout
    _isFamilyMode = false; 
    notifyListeners();
  }

  // --- 2. QUẢN LÝ THÔNG BÁO (NOTIFICATION LOGIC) ---
  
  // Tải từ Server
  Future<void> fetchNotifications(String userId) async {
    _notifications = await _apiService.fetchNotifications(userId);
    notifyListeners();
  }

  // Hàm ghi thông báo (Vừa lưu Server, vừa hiện Popup)
  Future<void> logNotification({
    required String userId,
    required String title,
    required String body,
    IconData icon = Icons.notifications,
    Color color = Colors.blue,
  }) async {
    // 1. Tạo Model (Chuyển Icon/Color sang int để lưu DB)
    final newNotif = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      time: DateTime.now(),
      iconCode: icon.codePoint, 
      colorValue: color.value,
      isRead: false,
    );

    // 2. Lưu lên Server (Chạy ngầm)
    _apiService.addNotification(userId, newNotif);

    // 3. Cập nhật UI List
    _notifications.insert(0, newNotif);
    
    // 4. Hiện Popup hệ thống (Local Notification)
    NotificationService.showNotification(title, body);
    
    notifyListeners();
  }

  // --- 3. LOGIC DÒNG TIỀN NÂNG CAO (LIÊN KẾT GIAO DỊCH & THÔNG BÁO) ---

  // A. Nạp tiền vào ví
  Future<void> depositToWallet(String userId, String? familyId, double amount, String source) async {
    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      title: "Nạp tiền từ $source", 
      amount: amount, 
      date: DateTime.now(), 
      type: 'income', 
      category: "Nạp tiền", 
      isDemo: false
    );
    
    await addTransaction(userId, familyId, tx);
    
    await logNotification(
      userId: userId,
      title: "Nạp tiền thành công",
      body: "Đã nạp +${amount.toStringAsFixed(0)}đ vào ví.",
      icon: Icons.account_balance_wallet,
      color: Colors.green
    );
  }

  // B. Chuyển tiền (Thanh toán)
  Future<bool> makeTransfer(String userId, String? familyId, TransactionModel tx) async {
    if (!hasEnoughBalance(tx.amount)) return false; 
    
    String targetId = (_isFamilyMode && familyId != null) ? familyId : userId;
    await _apiService.addTransactionByMode(targetId, tx, _isFamilyMode);
    await fetchTransactions(userId, familyId);
    
    await logNotification(
      userId: userId,
      title: "Chuyển tiền thành công",
      body: "Đã chuyển -${tx.amount.toStringAsFixed(0)}đ",
      icon: Icons.send,
      color: Colors.blue
    );
    return true;
  }

  // C. Xử lý Tiết kiệm (Nạp/Rút)
  Future<bool> processSavingsTransaction(String userId, String? familyId, SavingsGoalModel goal, double amount, String type) async {
    if (type == 'deposit' && !hasEnoughBalance(amount)) return false;
    
    double newAmount = goal.currentAmount;
    TransactionModel tx;
    
    // Logic cập nhật số tiền
    if (type == 'deposit') {
      newAmount += amount;
      tx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        title: "Nạp tiết kiệm: ${goal.title}", 
        amount: amount, 
        date: DateTime.now(), 
        type: 'expense', 
        category: "Tiết kiệm", 
        isDemo: false
      );
      // Thông báo nạp
      await logNotification(
        userId: userId,
        title: "Tích lũy thành công",
        body: "Đã chuyển ${amount.toStringAsFixed(0)}đ vào quỹ ${goal.title}",
        icon: Icons.savings,
        color: Colors.orange
      );
    } else {
      newAmount -= amount;
      if (newAmount < 0) newAmount = 0;
      tx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        title: "Rút tiết kiệm: ${goal.title}", 
        amount: amount, 
        date: DateTime.now(), 
        type: 'income', 
        category: "Hoàn tiết kiệm", 
        isDemo: false
      );
      // Thông báo rút
      await logNotification(
        userId: userId,
        title: "Rút tiết kiệm",
        body: "Đã hoàn ${amount.toStringAsFixed(0)}đ về ví chính.",
        icon: Icons.savings_outlined,
        color: Colors.grey
      );
    }

    // Cập nhật API
    await _apiService.updateSavingsAmount(userId, goal.id, newAmount);
    
    // Tạo giao dịch tương ứng
    String targetId = (_isFamilyMode && familyId != null) ? familyId : userId;
    await _apiService.addTransactionByMode(targetId, tx, _isFamilyMode);
    
    // Refresh dữ liệu
    await fetchSavings(userId);
    await fetchTransactions(userId, familyId);
    
    return true;
  }

  // D. Thanh toán Hóa đơn định kỳ
  Future<bool> payBillRecuring(String userId, String? familyId, BillModel bill, double amountPaid) async {
    if (!hasEnoughBalance(amountPaid)) return false;
    
    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      title: "Thanh toán: ${bill.title}", 
      amount: amountPaid, 
      date: DateTime.now(), 
      type: 'expense', 
      category: "Hóa đơn", 
      isDemo: false
    );

    String targetId = (_isFamilyMode && familyId != null) ? familyId : userId;
    await _apiService.addTransactionByMode(targetId, tx, _isFamilyMode);
    
    // Cập nhật trạng thái hóa đơn
    await _apiService.updateBill(userId, bill.id, {
      'date': DateTime.now().toIso8601String(), // Cập nhật ngày thanh toán
      'amount': amountPaid, 
      'isPaid': true
    });
    
    await fetchBills(userId);
    await fetchTransactions(userId, familyId);
    
    await logNotification(
      userId: userId,
      title: "Thanh toán hóa đơn",
      body: "Đã trả ${bill.title}: -${amountPaid.toStringAsFixed(0)}đ",
      icon: Icons.receipt_long,
      color: Colors.redAccent
    );
    
    return true;
  }

  // --- 4. CÁC HÀM CRUD CƠ BẢN (GIỮ NGUYÊN) ---
  void toggleFamilyMode(bool isFamily, String userId, String? familyId) { 
    if (isFamily && (familyId == null || familyId.isEmpty)) return; 
    _isFamilyMode = isFamily; 
    fetchTransactions(userId, familyId); 
    notifyListeners(); 
  }
  
  Future<void> fetchTransactions(String userId, String? familyId) async { 
    if (_transactions.isEmpty) { _isLoading = true; notifyListeners(); } 
    try { 
      String targetId = (_isFamilyMode && familyId != null) ? familyId : userId; 
      _transactions = await _apiService.fetchTransactionsByMode(targetId, _isFamilyMode); 
    } catch (e) { print(e); } 
    finally { _isLoading = false; notifyListeners(); } 
  }
  
  Future<void> addTransaction(String userId, String? familyId, TransactionModel tx) async { 
    String targetId = (_isFamilyMode && familyId != null) ? familyId : userId; 
    await _apiService.addTransactionByMode(targetId, tx, _isFamilyMode); 
    await fetchTransactions(userId, familyId); 
  }
  
  Future<void> deleteTransaction(String userId, String txId) async { 
    await _apiService.deleteTransaction(userId, txId); 
    _transactions.removeWhere((t) => t.id == txId); 
    notifyListeners(); 
  }
  
  Future<void> fetchSavings(String userId) async { _savings = await _apiService.fetchSavings(userId); notifyListeners(); }
  Future<void> addSavings(String userId, SavingsGoalModel goal) async { await _apiService.addSavings(userId, goal); await fetchSavings(userId); }
  Future<void> deleteSavings(String userId, String goalId) async { await _apiService.deleteSavings(userId, goalId); _savings.removeWhere((s) => s.id == goalId); notifyListeners(); }
  
  Future<void> fetchBills(String userId) async { _bills = await _apiService.fetchBills(userId); notifyListeners(); }
  Future<void> addBill(String userId, BillModel bill) async { await _apiService.addBill(userId, bill); await fetchBills(userId); }
  Future<void> deleteBill(String userId, String billId) async { await _apiService.deleteBill(userId, billId); _bills.removeWhere((b) => b.id == billId); notifyListeners(); }
  
  Future<double> getRate(String from, String to) async => await _apiService.getExchangeRate(from, to);
}