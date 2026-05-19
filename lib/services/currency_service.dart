// File: lib/services/currency_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class CurrencyService {
  /// Hàm chuyển đổi tiền tệ
  /// from: Loại tiền gốc (VD: USD)
  /// to: Loại tiền đích (VD: VND)
  /// amount: Số tiền cần đổi (VD: 100)
  Future<double?> convert(String from, String to, double amount) async {
    // URL chuẩn của ExchangeRate-API v6
    final url = Uri.parse(
      'https://v6.exchangerate-api.com/v6/${AppConstants.currencyApiKey}/pair/$from/$to/$amount'
    );

    try {
      print("Đang gọi API: $url"); // Log để kiểm tra
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Kiểm tra xem API trả về thành công không
        if (data['result'] == 'success') {
          // Lấy kết quả quy đổi
          return double.parse(data['conversion_result'].toString());
        } else {
          print("Lỗi từ API: ${data['error-type']}");
        }
      } else {
        print("Lỗi HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }
    return null; // Trả về null nếu lỗi
  }
}