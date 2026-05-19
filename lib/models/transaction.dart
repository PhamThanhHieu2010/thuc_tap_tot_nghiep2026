class TransactionModel {
  final String id;
  final String title;     // Tên giao dịch
  final double amount;    // Số tiền
  final DateTime date;    // Ngày giờ
  final String type;      // 'income' (Thu) hoặc 'expense' (Chi)
  final String category;  // Danh mục (VD: Ăn uống, Lương...)
  final String walletId;  // ID ví
  final bool isDemo;      // Đánh dấu dữ liệu mẫu

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.walletId = 'default', // Mặc định nếu không có ví
    this.isDemo = false,       // Mặc định là false (dữ liệu thật)
  });

  // --- 1. TẠO OBJECT TỪ JSON (Khi đọc từ Firebase/Database) ---
  factory TransactionModel.fromJson(String id, Map<String, dynamic> json) {
    return TransactionModel(
      id: id,
      // Dùng ?? '' để tránh lỗi null nếu dữ liệu cũ thiếu trường title
      title: json['title'] ?? json['note'] ?? 'Không tên', 
      
      // Xử lý an toàn cho số (vì Firebase có thể trả về Int hoặc Double)
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0.0,
      
      // Xử lý ngày tháng (Hỗ trợ cả String ISO và Timestamp nếu cần)
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
          
      type: json['type'] ?? 'expense',
      category: json['category'] ?? 'Khác',
      walletId: json['walletId'] ?? 'default',
      
      // Đọc cờ demo, mặc định false
      isDemo: json['isDemo'] ?? false, 
    );
  }

  // --- 2. CHUYỂN OBJECT THÀNH JSON (Khi lưu xuống Firebase/Database) ---
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // Lưu dạng chuỗi chuẩn ISO 8601
      'type': type,
      'category': category,
      'walletId': walletId,
      'isDemo': isDemo,
    };
  }

  // --- 3. COPY WITH (Hỗ trợ sửa đổi 1 vài trường mà không cần tạo mới toàn bộ) ---
  TransactionModel copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? type,
    String? category,
    String? walletId,
    bool? isDemo,
  }) {
    return TransactionModel(
      id: this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      walletId: walletId ?? this.walletId,
      isDemo: isDemo ?? this.isDemo,
    );
  }
}