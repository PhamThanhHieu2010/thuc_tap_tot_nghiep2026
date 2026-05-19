import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../config/theme.dart';

class InterestCalcScreen extends StatefulWidget {
  const InterestCalcScreen({super.key});
  @override
  State<InterestCalcScreen> createState() => _InterestCalcScreenState();
}

class _InterestCalcScreenState extends State<InterestCalcScreen> {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  
  String _formattedInterest = "0";
  String _formattedTotal = "0";

  // --- LOGIC TÍNH TOÁN (GIỮ NGUYÊN) ---
  void _calc() {
    FocusScope.of(context).unfocus(); // Ẩn phím
    
    // Xử lý chuỗi input (loại bỏ dấu phẩy nếu có)
    double p = double.tryParse(_amountCtrl.text.replaceAll(',', '').replaceAll('.', '')) ?? 0;
    double r = double.tryParse(_rateCtrl.text.replaceAll(',', '.')) ?? 0; // Hỗ trợ cả dấu phẩy cho số thập phân
    double t = double.tryParse(_monthCtrl.text) ?? 0;

    if (p <= 0 || t <= 0) return;

    // Công thức lãi kép: A = P(1 + r/n)^(nt)
    // Ở đây tính theo tháng: A = P * (1 + r/12)^t
    // Lưu ý: r nhập vào là % năm => r/100
    
    double finalAmount = p * pow((1 + (r / 100) / 12), t);
    double interest = finalAmount - p;

    final formatter = NumberFormat("#,###", "vi_VN");
    setState(() {
      _formattedInterest = "${formatter.format(interest)} đ";
      _formattedTotal = "${formatter.format(finalAmount)} đ";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.background, // Nền xám sáng
        appBar: AppBar(
          title: Text("Tính Lãi Kép", style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.background,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.textDark),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. INPUT SECTION (iOS Form Style)
              Text("THÔNG TIN GỬI", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    _buildIOSInput(_amountCtrl, "Tiền gửi ban đầu", "VNĐ", Icons.monetization_on_outlined, isFirst: true),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Colors.black12),
                    _buildIOSInput(_rateCtrl, "Lãi suất năm", "%", Icons.percent_rounded),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Colors.black12),
                    _buildIOSInput(_monthCtrl, "Kỳ hạn gửi", "Tháng", Icons.calendar_month_outlined, isLast: true),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. ACTION BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.iosBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: AppTheme.iosBlue.withOpacity(0.4),
                  ),
                  onPressed: _calc,
                  child: const Text("TÍNH TOÁN NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 30),
              
              // 3. RESULT SECTION
              if (_formattedTotal != "0") ...[
                Text("KẾT QUẢ DỰ TÍNH", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow
                  ),
                  child: Column(
                    children: [
                      _buildResultRow("Tiền lãi nhận được", _formattedInterest, color: AppTheme.iosGreen),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                      _buildResultRow("Tổng tiền thu về", _formattedTotal, isTotal: true),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Widget con: Row nhập liệu kiểu iOS
  Widget _buildIOSInput(TextEditingController controller, String label, String unit, IconData icon, {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.iosBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppTheme.iosBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8), // Padding top nhẹ cho input
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Text(unit, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  // Widget con: Row hiển thị kết quả
  Widget _buildResultRow(String title, String value, {Color color = AppTheme.textDark, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isTotal) 
               Text("Gốc + Lãi", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            Text(
              value, 
              style: GoogleFonts.outfit(
                fontSize: isTotal ? 22 : 18, 
                fontWeight: FontWeight.bold, 
                color: color
              )
            ),
          ],
        )
      ],
    );
  }
}