import 'dart:math'; // Thêm thư viện để sinh OTP ngẫu nhiên
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'app_provider.dart'; 

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  String? _userId;
  String? _userName;
  String? _emailOrPhone; // Đổi tên biến để tổng quát hơn
  String? _familyId;
  String _language = "vi";

  bool get isAuthenticated => _userId != null;
  String get userId => _userId ?? "";
  String get userName => _userName ?? "Khách";
  String get emailOrPhone => _emailOrPhone ?? ""; // Getter mới
  String? get familyId => _familyId;
  bool get hasFamily => _familyId != null && _familyId!.isNotEmpty;
  String get language => _language;

  // --- TỪ ĐIỂN ĐA NGÔN NGỮ (FULL PROJECT COVERAGE) ---
  String t(String key) {
    if (_language == 'vi') return key;

    Map<String, String> dict = {
      // 1. CHUNG & NÚT BẤM (COMMON & BUTTONS)
      "Xin chào,": "Hello,",
      "Hủy": "Cancel",
      "Đồng ý": "Confirm",
      "Lưu lại": "Save",
      "Xác nhận": "Confirm",
      "Đóng": "Close",
      "Thành công": "Success",
      "Lỗi": "Error",
      "Vui lòng đợi...": "Please wait...",
      "Xem thêm": "More",
      "Xem tất cả": "See All",
      
      // 2. DASHBOARD & HOME
      "Số dư khả dụng": "Available Balance",
      "Thu nhập": "Income",
      "Chi tiêu": "Expense",
      "Tiện ích nhanh": "Quick Actions",
      "Giao dịch gần đây": "Recent Transactions",
      "Chưa có giao dịch nào": "No transactions yet",
      "Thông báo": "Notifications",
      "Chưa có thông báo nào": "No notifications yet",
      "Trang chủ": "Home",
      "Thống kê": "Stats",
      "Chat AI": "AI Chat",

      // 3. MENU & SETTINGS (CÀI ĐẶT)
      "Cài đặt": "Settings",
      "Tài khoản": "Account",
      "Hồ sơ người dùng": "User Profile",
      "Bảo mật": "Security",
      "Khóa ứng dụng (PIN)": "App Lock (PIN)",
      "Đổi mật khẩu": "Change Password",
      "Cài đặt chung": "General",
      "Ngôn ngữ": "Language",
      "Tiếng Việt": "Vietnamese",
      "English": "English",
      "Dữ liệu": "Data",
      "Xuất dữ liệu (Excel)": "Export Data (Excel)",
      "Tạo dữ liệu mẫu": "Generate Mock Data",
      "Xóa dữ liệu demo": "Clear Demo Data",
      "Thông tin": "About",
      "Về ứng dụng": "About App",
      "Liên hệ hỗ trợ": "Contact Support",
      "Phiên bản": "Version",
      "Đăng xuất": "Logout",
      "Bạn có chắc chắn muốn đăng xuất?": "Are you sure you want to logout?",
      "Đã tạo dữ liệu mẫu thành công": "Mock data generated successfully",
      "Đã xóa dữ liệu demo": "Demo data cleared",
      "Chưa có dữ liệu để xuất": "No data to export",

      // 4. INPUT FIELDS (FORM NHẬP LIỆU)
      "Nhập": "Enter", 
      "Tài khoản": "Username",
      "Mật khẩu": "Password",
      "Họ và Tên": "Full Name",
      "Email hoặc SĐT": "Email or Phone",
      "Xác nhận mật khẩu": "Confirm Password",
      "Mật khẩu mới": "New Password",
      "Nhập lại mật khẩu": "Re-enter Password",
      "Số tiền": "Amount",
      "Số tiền nạp": "Top-up Amount",
      "Nội dung": "Note",
      "Nội dung (Tùy chọn)": "Note (Optional)",
      "Tiêu đề (VD: Phở bò)": "Title (e.g. Lunch)",
      "Nhập số tiền": "Enter amount",
      "Mật khẩu cũ": "Old Password",

      // 5. CÁC TÍNH NĂNG (FEATURES)
      "Chuyển tiền": "Transfer",
      "Nạp tiền": "Top Up",
      "Tiết kiệm": "Savings",
      "Hóa đơn": "Bills",
      "Lịch chi tiêu": "Calendar",
      "Thống kê chi tiêu": "Expense Statistics",
      "Tổng chi tiêu": "Total Expense",
      "Không có dữ liệu": "No data available",
      "Tất cả tiện ích": "All Features",
      "Tài chính": "Finance",
      "Công cụ & Hỗ trợ": "Tools & Support",
      "Xuất Excel": "Export Excel",
      "Chia sẻ": "Share",
      "Hỗ trợ": "Support",
      "Tỷ giá": "Exchange Rate",
      "Lãi suất": "Interest Rate",
      "Quét QR": "Scan QR",
      "Bảo mật PIN": "Security PIN",
      "Nạp dữ liệu mẫu (Demo)": "Seed Mock Data",
      "Ví Gia Đình": "Family Wallet",
      "Kích hoạt Ví Gia Đình": "Activate Family Wallet",
      "Quản lý chi tiêu chung": "Manage Shared Expenses",

      // 6. MÀN HÌNH KHÓA (LOCK SCREEN)
      "Nhập mã PIN": "Enter PIN",
      "Tạo mã PIN mới (4 số)": "Create New PIN (4 digits)",
      "Xác nhận mã PIN": "Confirm PIN",
      "Mã PIN không khớp": "PIN does not match",
      "Nhập lại mã PIN": "Re-enter PIN",

      // 7. DANH MỤC (CATEGORIES - ĐỒNG BỘ DB)
      "Ăn uống": "Food",
      "Shopping": "Shopping",
      "Di chuyển": "Transport",
      "Điện/Nước": "Bills",
      "Giải trí": "Entertainment",
      "Lương": "Salary",
      "Giáo dục": "Education",
      "Sức khỏe": "Health",
      "Khác": "Other",
      "Thực phẩm": "Groceries",
      "Đi lại": "Travel",
      "Xăng xe": "Fuel",
      "Mua sắm": "Shopping",
      "Cafe": "Coffee",
      "Xem phim": "Movies",
      "Y tế": "Medical",
      "Học tập": "Study",

      // 8. AI CHAT
      "Chào bạn! Tôi là Smart Manager AI.": "Hello! I am Smart Manager AI.",
      "Tôi có thể giúp bạn phân tích chi tiêu hoặc tư vấn tài chính (Hỗ trợ cả Online & Offline).": "I can help you analyze expenses or provide financial advice.",
      "Hỏi về tiền, tiết kiệm, đầu tư...": "Ask about money, savings...",
      "Đang suy nghĩ...": "Thinking...",
      
      // 9. BÁO CÁO & EXCEL
      "Ngày giao dịch": "Date",
      "Loại": "Type",
      "Danh mục": "Category",
      "Ghi chú / Tiêu đề": "Note / Title",
      "Mời tải App Smart Manager": "Download Smart Manager App",
      
      // 10. SAVINGS & BILLS
      "Mục tiêu": "Goal",
      "Đã đạt": "Reached",
      "Thanh toán": "Pay",
      "Đã thanh toán": "Paid",
      "Chưa thanh toán": "Unpaid",
      "Rút tiền": "Withdraw",
      "Nạp thêm": "Deposit",
    };

    return dict[key] ?? key;
  }

  // --- LOGIC 1: TỰ ĐỘNG NHẬN DIỆN EMAIL HOẶC SĐT ---
  String _generateId(String input) {
    input = input.trim();
    if (input.contains('@')) {
      // Là Email -> Format chữ thường và thay ký tự đặc biệt
      return input.toLowerCase().replaceAll('.', '_').replaceAll('@', '_');
    } else {
      // Là Số điện thoại -> Chỉ lấy số
      return input.replaceAll(RegExp(r'\D'), ''); // Xóa mọi ký tự không phải số
    }
  }

  // --- LOGIC 2: GIẢ LẬP GỬI OTP (SMS/EMAIL) ---
  String generateOTP() {
    var rnd = Random();
    var next = rnd.nextInt(900000) + 100000; // Random 6 số (100000 -> 999999)
    return next.toString();
  }

  // LOGIN (Hỗ trợ cả Email & SĐT)
  Future<bool> login(String input, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay
    String id = _generateId(input);
    
    final profile = await _apiService.getUserProfile(id);
    
    if (profile != null && profile['password'] == password) {
      _userId = id;
      _userName = profile['name'];
      // Lấy email hoặc sđt từ profile (ưu tiên cái nào có dữ liệu thực)
      _emailOrPhone = profile['email'] ?? profile['phone'] ?? input;
      if (profile['language'] != null) _language = profile['language'];
      _familyId = profile['familyId']; 
      
      await _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  // REGISTER (Hỗ trợ cả Email & SĐT)
  Future<bool> register(String name, String input, String password) async {
    try {
      String id = _generateId(input);
      final existing = await _apiService.getUserProfile(id);
      if (existing != null) return false;

      // Xác định key lưu là email hay phone để lưu vào DB cho đúng nghĩa
      Map<String, dynamic> data = {
        'name': name,
        'password': password, 
        'joinedDate': DateTime.now().toIso8601String(),
        'language': 'vi', 
      };

      if (input.contains('@')) {
        data['email'] = input;
      } else {
        data['phone'] = input;
      }

      await _apiService.registerUser(id, data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CHECK ACCOUNT EXISTS (Dùng cho Quên mật khẩu)
  Future<bool> checkAccountExists(String input) async {
    String id = _generateId(input);
    final profile = await _apiService.getUserProfile(id);
    return profile != null;
  }

  // RESET PASSWORD
  Future<void> resetPassword(String input, String newPass) async {
    String id = _generateId(input);
    await _apiService.updatePassword(id, newPass);
  }

  // --- LOGOUT ---
  Future<void> logout(BuildContext context) async {
    _userId = null;
    _familyId = null;
    _userName = null;
    _emailOrPhone = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Xóa dữ liệu tạm thời trong AppProvider để tránh hiện data cũ của user trước
    // ignore: use_build_context_synchronously
    if (context.mounted) {
       Provider.of<AppProvider>(context, listen: false).clearData();
    }
    
    notifyListeners();
  }
  
  // FAMILY
  Future<void> joinFamily(String code) async {
    if (_userId != null) {
      _familyId = code;
      await _apiService.updateFamilyId(_userId!, code); // Lưu ý: Cần đảm bảo ApiService có hàm này hoặc dùng hàm tương đương
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> leaveFamily() async {
    if (_userId != null) {
      _familyId = null;
      await _apiService.updateFamilyId(_userId!, "");
      await _saveToPrefs();
      notifyListeners();
    }
  }

  // CHANGE PASSWORD (Đổi khi đang đăng nhập)
  Future<bool> changePassword(String currentPass, String newPass) async {
    if (_userId == null) return false;
    final profile = await _apiService.getUserProfile(_userId!);
    if (profile != null && profile['password'] == currentPass) {
      await _apiService.updatePassword(_userId!, newPass);
      return true;
    }
    return false;
  }

  // LANGUAGE
  Future<void> switchLanguage() async {
    _language = _language == 'vi' ? 'en' : 'vi';
    notifyListeners(); 
    if (_userId != null) {
      await _apiService.updateLanguage(_userId!, _language);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _language);
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) {
      await prefs.setString('userId', _userId!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('emailOrPhone', _emailOrPhone!); // Lưu key mới
      await prefs.setString('language', _language);
      if (_familyId != null) await prefs.setString('familyId', _familyId!);
    }
  }

  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userId')) {
      _userId = prefs.getString('userId');
      _userName = prefs.getString('userName');
      _emailOrPhone = prefs.getString('emailOrPhone'); // Load key mới
      _language = prefs.getString('language') ?? 'vi';
      _familyId = prefs.getString('familyId');
      notifyListeners();
    }
  }
}