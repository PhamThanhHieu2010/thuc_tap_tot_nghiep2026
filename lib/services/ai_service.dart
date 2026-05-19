// File: lib/services/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config/constants.dart';
import '../models/transaction.dart';
import '../data/finance_data.dart'; // File dữ liệu offline

class AIService {
  // ✅ Dùng model mới nhất (như bạn đã test thành công)
  static const String _modelId = 'llama-3.3-70b-versatile'; 
  
  // URL chuẩn của Groq
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  /// Hàm Chat chính
  Future<String> chatWithData(String userQuestion, List<TransactionModel> txs) async {
    final formatter = NumberFormat("#,###", "vi_VN");
    
    // 1. Xử lý dữ liệu đầu vào (Context)
    double totalIncome = txs.where((t) => t.type == 'income').fold(0, (sum, t) => sum + t.amount);
    double totalExpense = txs.where((t) => t.type == 'expense').fold(0, (sum, t) => sum + t.amount);
    double balance = totalIncome - totalExpense;

    // Lấy 15 giao dịch gần nhất để gửi cho AI đọc
    var recentTxs = txs.take(15).map((t) {
      String date = DateFormat('dd/MM').format(t.date);
      String sign = t.type == 'income' ? '+' : '-';
      return "- $date: ${t.title} ($sign${formatter.format(t.amount)}đ)";
    }).join("\n");

    // Kịch bản (Prompt) cho AI
    String systemPrompt = """
    Bạn là trợ lý tài chính SmartManager. Hãy trả lời ngắn gọn, thân thiện bằng tiếng Việt.
    
    THÔNG TIN VÍ CỦA TÔI:
    - Tổng thu: ${formatter.format(totalIncome)} đ
    - Tổng chi: ${formatter.format(totalExpense)} đ
    - Số dư: ${formatter.format(balance)} đ
    
    GIAO DỊCH GẦN ĐÂY:
    $recentTxs
    
    Hãy dùng số liệu trên để trả lời câu hỏi của người dùng. Nếu họ hỏi lời khuyên, hãy gợi ý cách tiết kiệm.
    """;

    try {
      print("🚀 [Groq] Đang gửi request... Model: $_modelId");
      
      // 2. Gọi API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey.trim()}',
        },
        body: jsonEncode({
          "model": _modelId,
          "messages": [
            {"role": "system", "content": systemPrompt}, // Gửi ngữ cảnh
            {"role": "user", "content": userQuestion}    // Gửi câu hỏi
          ],
          "temperature": 0.6, // Độ sáng tạo (0.0 - 1.0)
          "max_tokens": 800,  // Giới hạn độ dài câu trả lời
        }),
      ).timeout(const Duration(seconds: 15)); // Timeout sau 15s

      // 3. Xử lý kết quả
      if (response.statusCode == 200) {
        // Decode UTF-8 để không lỗi font tiếng Việt
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String content = data['choices'][0]['message']['content'];
        print("✅ [Groq] Trả lời thành công!");
        return content;
      } else {
        print("❌ [Groq Error] Code: ${response.statusCode} - Body: ${response.body}");
        throw Exception("Lỗi API: ${response.statusCode}");
      }

    } catch (e) {
      // 4. Nếu lỗi mạng/API -> Chuyển sang Offline
      print("⚠️ [Fallback] Chuyển sang chế độ Offline. Lỗi: $e");
      return _getOfflineResponse(userQuestion, totalExpense, formatter);
    }
  }

  // --- Logic Chat Offline (Giữ nguyên) ---
  String _getOfflineResponse(String q, double expense, NumberFormat fmt) {
    q = q.toLowerCase();
    if (q.contains("chi") || q.contains("tiêu")) {
      return "📡 [Offline] Theo dữ liệu máy, tổng chi tiêu của bạn là ${fmt.format(expense)} đ.";
    }
    // Tra cứu FinanceData
    for (var item in FinanceData.knowledgeBase) {
      for (var k in item['keywords']) {
        if (q.contains(k.toLowerCase())) return "💡 [Kiến thức]: ${item['answer']}";
      }
    }
    return "⚠️ Tôi đang mất kết nối Internet nên chỉ trả lời được các câu hỏi cơ bản về số dư.";
  }
}