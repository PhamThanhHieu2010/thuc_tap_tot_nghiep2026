import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/transaction.dart'; 
// import '../../../widgets/custom_textfield.dart'; // Không cần dùng widget này ở đây nữa để tránh lỗi style

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _tkCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isLoading = false;

  void _onTransfer() async {
    // Ẩn bàn phím khi bấm nút
    FocusScope.of(context).unfocus();

    // Làm sạch chuỗi số tiền (bỏ dấu phẩy/chấm nếu có)
    String cleanAmount = _amountCtrl.text.replaceAll(',', '').replaceAll('.', '');
    double? amount = double.tryParse(cleanAmount);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Số tiền không hợp lệ!")));
      return;
    }
    if (_tkCtrl.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập người nhận!")));
       return;
    }

    setState(() => _isLoading = true);

    final app = Provider.of<AppProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Tạo giao dịch Expense để trừ tiền
    final tx = TransactionModel(
      id: "", 
      title: "Chuyển đến: ${_tkCtrl.text} (${_noteCtrl.text})",
      amount: amount,
      date: DateTime.now(),
      type: 'expense', 
      category: "Chuyển tiền",
    );

    // Gọi hàm makeTransfer
    await app.makeTransfer(auth.userId, auth.familyId, tx);

    if(mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chuyển tiền thành công! Đã trừ vào ví.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Chạm ra ngoài tắt phím
      child: Scaffold(
        backgroundColor: AppTheme.background, // Nền xám sáng
        appBar: AppBar(
          title: const Text("Chuyển tiền", style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
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
              // 1. INPUT CARD (NGƯỜI NHẬN)
              Text("NGƯỜI NHẬN", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow
                ),
                child: TextField(
                  controller: _tkCtrl,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Nhập STK hoặc Tên",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.iosBlue),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.contacts_rounded, color: AppTheme.textGrey),
                      onPressed: () {}, 
                    )
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 2. AMOUNT CARD (SỐ TIỀN - HERO SECTION)
              Center(child: Text("SỐ TIỀN CHUYỂN", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow
                ),
                child: Column(
                  children: [
                    // SỬA LỖI Ở ĐÂY: Thay CustomTextField bằng TextField chuẩn để tùy biến style
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center, // Căn giữa
                      style: GoogleFonts.outfit(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textDark
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const Text("VNĐ", style: TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 3. NOTE CARD (NỘI DUNG)
              Text("NỘI DUNG", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGrey)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow
                ),
                child: TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "Nhập nội dung chuyển tiền...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.create_rounded, color: AppTheme.iosBlue),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 4. INFO BOX (CẢNH BÁO NHẸ)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.iosBlue.withOpacity(0.1), // Nền xanh rất nhạt
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.iosBlue.withOpacity(0.2))
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                     Icon(Icons.info_outline_rounded, color: AppTheme.iosBlue, size: 20),
                     SizedBox(width: 10),
                     Expanded(
                       child: Text(
                         "Giao dịch này sẽ được ghi nhận là một khoản CHI TIÊU và trừ trực tiếp vào tổng số dư ví.",
                         style: TextStyle(color: AppTheme.iosBlue, fontSize: 13, height: 1.4)
                       )
                     )
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // 5. ACTION BUTTON
              if (_isLoading) 
                const Center(child: CircularProgressIndicator())
              else 
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
                    onPressed: _onTransfer, 
                    child: const Text("XÁC NHẬN CHUYỂN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}