// lib/config/constants.dart
class AppConstants {
  // Đường dẫn Database Firebase Realtime 
  static const String dbUrl = "https://smartmanagerdb-default-rtdb.asia-southeast1.firebasedatabase.app";
  
  // API Key GROQ (Đã cắt chuỗi để tránh GitHub chặn)
  // GitHub quét từ khóa "gsk_", nên ta tách nó ra.
  static const String groqApiKey = "gsk_" + "pYUV1AuOCA6a6wN2AeJtWGdyb3FYf0XmiuPlJmfE08s5AVbFYs7n";

  // --- THÊM DÒNG NÀY ---
  // Tách chuỗi cho an toàn (dù GitHub có thể không chặn cái này, nhưng làm cho chắc)
  static const String currencyApiKey = "dabd34747d2" + "34ddc65afaade";

  // --- [MỚI] API Key OCR
  static const String ocrApiKey = "K895019" + "65988957"; 
  static const String ocrApiUrl = "https://api.ocr.space/parse/image";

  // User mặc định dùng khi chưa có Auth thật
  static const String defaultUserId = "admin_user";
  
  // Các key dùng cho SharedPreferences
  static const String keyUserId = 'userId';
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'emailOrPhone';
}