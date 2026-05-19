import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
// import '../../../widgets/bouncy_button.dart'; // Bỏ dòng này vì chuyển sang dùng ElevatedButton chuẩn
import '../../../widgets/custom_textfield.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/transaction.dart';

class TopUpModal extends StatefulWidget {
  const TopUpModal({super.key});

  @override
  State<TopUpModal> createState() => _TopUpModalState();
}

class _TopUpModalState extends State<TopUpModal> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  
  // Danh sách nguồn tiền giả lập
  final List<String> _accounts = ['Techcombank', 'Vietcombank', 'MB Bank', 'Momo'];
  String _selectedAccount = 'Techcombank';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _handleTopUp() async {
    // 1. Validate dữ liệu
    String rawAmount = _amountCtrl.text.replaceAll(',', '');
    double amount = double.tryParse(rawAmount) ?? 0;

    if (amount <= 0) {
      _showToast("Vui lòng nhập số tiền hợp lệ", AppTheme.iosRed);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final app = Provider.of<AppProvider>(context, listen: false);

      // 2. Tạo nội dung giao dịch
      String finalNote = _noteCtrl.text.trim().isEmpty 
          ? "Nạp tiền vào $_selectedAccount" 
          : _noteCtrl.text.trim();

      final newTx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: finalNote,
        amount: amount,
        date: DateTime.now(),
        type: 'income', // Là khoản thu
        category: 'Nạp tiền',
      );

      // 3. Gọi Provider để lưu
      await app.addTransaction(auth.userId, auth.familyId, newTx);

      if (mounted) {
        Navigator.pop(context); // Đóng Modal
        _showToast("Nạp tiền thành công!", AppTheme.iosGreen);
      }
    } catch (e) {
      if (mounted) _showToast("Lỗi: $e", AppTheme.iosRed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: color, 
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao bàn phím
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 20, 
        bottom: keyboardHeight + 20 
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header gạch ngang
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          
          const Text("Nạp thêm tiền", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 25),

          // 1. Chọn tài khoản
          const Text("Chọn tài khoản nhận", style: TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppTheme.background, 
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAccount,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                dropdownColor: Colors.white,
                items: _accounts.map((acc) => DropdownMenuItem(
                  value: acc,
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.iosBlue, size: 20),
                      const SizedBox(width: 10),
                      Text(acc, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setState(() => _selectedAccount = val!),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Nhập số tiền (ĐÃ SỬA: Xóa keyboardType để tránh lỗi)
          CustomTextField(
            label: "Số tiền nạp",
            controller: _amountCtrl,
            icon: Icons.attach_money,
            isCurrency: true, 
          ),

          const SizedBox(height: 15),

          // 3. Nội dung
          CustomTextField(
            label: "Nội dung (Tùy chọn)",
            controller: _noteCtrl,
            icon: Icons.edit_note,
          ),

          const SizedBox(height: 30),

          // Button Xác nhận (ĐÃ SỬA: Dùng ElevatedButton chuẩn)
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.iosGreen))
          else
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.iosGreen, // Màu nền chuẩn
                  foregroundColor: Colors.white, // Màu chữ
                  elevation: 5,
                  shadowColor: AppTheme.iosGreen.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "XÁC NHẬN NẠP TIỀN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}