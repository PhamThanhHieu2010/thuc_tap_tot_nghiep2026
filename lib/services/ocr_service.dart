// File: lib/services/ocr_service.dart

import 'dart:convert';
import 'dart:typed_data'; // Để dùng Uint8List
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Để định dạng file ảnh
import '../config/constants.dart';

class OCRService {
  
  /// Hàm gửi ảnh lên Server OCR để lấy chữ
  Future<String?> scanTextFromImage(Uint8List imageBytes, String filename) async {
    try {
      print("📷 Đang gửi ảnh lên OCR.space...");
      
      var request = http.MultipartRequest('POST', Uri.parse(AppConstants.ocrApiUrl));
      
      // 1. Cấu hình Key và Ngôn ngữ
      request.fields['apikey'] = AppConstants.ocrApiKey;
      request.fields['language'] = 'eng'; // Hóa đơn tiếng Việt vẫn đọc số tốt bằng 'eng'
      request.fields['isOverlayRequired'] = 'false';
      request.fields['detectOrientation'] = 'true';

      // 2. Đính kèm file ảnh (Dạng bytes để chạy được trên Web)
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename.isEmpty ? 'receipt.jpg' : filename,
        contentType: MediaType('image', 'jpeg'), // Giả định là ảnh jpg/png
      ));

      // 3. Gửi Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status Code OCR: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Kiểm tra lỗi từ API
        if (data['IsErroredOnProcessing'] == true) {
          print("❌ Lỗi từ OCR API: ${data['ErrorMessage']}");
          return null;
        }

        // Lấy kết quả text
        if (data['ParsedResults'] != null && (data['ParsedResults'] as List).isNotEmpty) {
          String text = data['ParsedResults'][0]['ParsedText'];
          print("✅ Kết quả OCR thô:\n$text");
          return text; 
        }
      }
      return null;
    } catch (e) {
      print("⚠️ Lỗi kết nối OCR: $e");
      return null;
    }
  }

  /// Hàm lọc lấy Số Tiền lớn nhất trong hóa đơn
  double? extractAmount(String text) {
    // Tách từng dòng văn bản
    List<String> lines = text.split('\r\n'); // API này thường trả về \r\n
    double maxAmount = 0.0;

    // Regex tìm chuỗi số (VD: 100.000, 50,000, 20000)
    RegExp regExp = RegExp(r'[0-9]+[.,]?[0-9]*'); 

    for (var line in lines) {
      // Bỏ qua dòng ngày tháng (có chứa / hoặc -)
      if (line.contains('/') || line.contains('-')) continue;

      Iterable<Match> matches = regExp.allMatches(line);
      for (var m in matches) {
        // Xóa dấu phẩy và chấm để parse thành số (VD: 100,000 -> 100000)
        String numStr = m.group(0)!.replaceAll(',', '').replaceAll('.', '');
        
        // Fix lỗi OCR đôi khi đọc nhầm chữ 'o' thành số 0
        numStr = numStr.replaceAll(RegExp(r'[^0-9]'), '');

        if (numStr.isEmpty) continue;

        double? val = double.tryParse(numStr);
        
        // Logic: Số tiền tổng thường là số lớn nhất trong hóa đơn
        // Và phải lớn hơn 1000đ (để tránh lấy nhầm số lượng)
        if (val != null && val > maxAmount && val > 1000) {
          maxAmount = val;
        }
      }
    }
    
    return maxAmount > 0 ? maxAmount : null;
  }
}