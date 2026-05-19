// File: lib/screens/features/sub_screens/currency_converter_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:google_fonts/google_fonts.dart';

// Import các file cần thiết
import '../../../config/theme.dart';
import '../../../widgets/bouncy_button.dart'; 
import '../../../services/currency_service.dart'; // <-- Service vừa tạo

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountCtrl = TextEditingController();
  final CurrencyService _service = CurrencyService(); // Khởi tạo Service

  // Mặc định: 1 USD -> VND
  String _fromCurrency = "USD";
  String _toCurrency = "VND";
  String _resultText = "0"; 
  bool _isLoading = false;

  // Danh sách cờ và tiền tệ
  final Map<String, String> _flags = {
    "USD": "🇺🇸", "EUR": "🇪🇺", "JPY": "🇯🇵", "GBP": "🇬🇧",
    "KRW": "🇰🇷", "CNY": "🇨🇳", "VND": "🇻🇳", "THB": "🇹🇭", "SGD": "🇸🇬"
  };

  final List<String> _currencies = ["USD", "EUR", "JPY", "GBP", "KRW", "CNY", "VND", "THB", "SGD"];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ CHÍNH: GỌI API ---
  void _handleConvert() async {
    // 1. Ẩn bàn phím
    FocusScope.of(context).unfocus();

    // 2. Lấy dữ liệu người dùng nhập
    // Xóa dấu phẩy nếu người dùng nhập format kiểu 1,000
    String rawAmount = _amountCtrl.text.replaceAll(',', '').replaceAll('.', '');
    double amount = double.tryParse(rawAmount) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập số tiền lớn hơn 0"))
      );
      return;
    }

    // 3. Bắt đầu tải
    setState(() => _isLoading = true);

    // 4. Gọi Service lấy tỷ giá thật
    double? result = await _service.convert(_fromCurrency, _toCurrency, amount);

    // 5. Xử lý kết quả trả về
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          // Format kết quả cho đẹp (VD: 2,534,000)
          final formatter = NumberFormat("#,###.##", "vi_VN");
          _resultText = formatter.format(result);
        } else {
          _resultText = "Lỗi!";
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không lấy được tỷ giá. Kiểm tra mạng!"))
          );
        }
      });
    }
  }

  // Hàm đảo chiều tiền tệ
  void _swapCurrency() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _resultText = "0"; // Reset kết quả
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Đổi ngoại tệ (Live)", style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KHUNG HIỂN THỊ KẾT QUẢ ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient, // Gradient xanh của app
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  Text(
                    "$_toCurrency nhận được", 
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : FittedBox( // Giúp chữ tự nhỏ lại nếu số quá dài
                          child: Text(
                            _resultText,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // --- Ô NHẬP SỐ TIỀN ---
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: "Nhập số tiền cần đổi",
                  border: InputBorder.none,
                  icon: Icon(Icons.monetization_on_outlined, color: AppTheme.iosBlue),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- HÀNG CHỌN TIỀN TỆ ---
            Row(
              children: [
                Expanded(
                  child: _buildDropdown("Từ", _fromCurrency, (val) => setState(() => _fromCurrency = val!))
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    onPressed: _swapCurrency,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 32, color: AppTheme.iosBlue),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ),
                
                Expanded(
                  child: _buildDropdown("Sang", _toCurrency, (val) => setState(() => _toCurrency = val!))
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- NÚT BẤM ---
            BouncyButton(
              text: "CHUYỂN ĐỔI NGAY",
              onPressed: _handleConvert,
              color: AppTheme.iosBlue,
              isLoading: _isLoading,
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, size: 14, color: Colors.green),
                SizedBox(width: 5),
                Text("Tỷ giá cập nhật từ ExchangeRate-API", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget Dropdown chọn tiền (Style iOS)
  Widget _buildDropdown(String label, String currentVal, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currencies.contains(currentVal) ? currentVal : null,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 16),
              items: _currencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Text(_flags[value] ?? "", style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}