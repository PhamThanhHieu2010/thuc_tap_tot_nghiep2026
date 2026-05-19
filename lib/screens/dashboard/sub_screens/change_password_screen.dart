import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme.dart';
import '../../../providers/auth_provider.dart';

// Lưu ý: Không cần import CustomTextField hay BouncyButton nữa 
// vì ta sẽ custom trực tiếp ở đây để đạt chuẩn iOS Grouped Style.

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  
  // Quản lý trạng thái ẩn/hiện mật khẩu riêng cho từng ô
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  
  bool _isLoading = false;

  // --- LOGIC GIỮ NGUYÊN ---
  void _submit() async {
    // Ẩn bàn phím trước khi xử lý
    FocusScope.of(context).unfocus();

    if (_newPass.text != _confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu mới không khớp")));
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Gọi hàm đổi mật khẩu từ Provider
    bool ok = await auth.changePassword(_oldPass.text, _newPass.text);
    
    // Check mounted trước khi setState
    if (!mounted) return;

    setState(() => _isLoading = false);
    
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu cũ không đúng")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Màu nền xám chuẩn iOS Grouped Table View
    const Color iosBackground = Color(0xFFF2F2F7); 

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: iosBackground,
        appBar: AppBar(
          title: Text("Đổi mật khẩu", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: iosBackground, // AppBar trùng màu nền
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  "BẢO MẬT", 
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.bold)
                ),
              ),

              // --- FORM GROUP ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
                  ]
                ),
                child: Column(
                  children: [
                    _buildIOSInput(
                      controller: _oldPass, 
                      hint: "Mật khẩu hiện tại", 
                      isObscure: _obscureOld,
                      onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const Divider(height: 1, indent: 16, color: Colors.black12), // Đường kẻ phân cách
                    _buildIOSInput(
                      controller: _newPass, 
                      hint: "Mật khẩu mới", 
                      isObscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const Divider(height: 1, indent: 16, color: Colors.black12),
                    _buildIOSInput(
                      controller: _confirmPass, 
                      hint: "Nhập lại mật khẩu mới", 
                      isObscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      isLast: true
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  "Mật khẩu nên bao gồm chữ cái và số để tăng độ bảo mật.", 
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])
                ),
              ),

              const SizedBox(height: 40),
              
              // --- BUTTON ---
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary, // Hoặc Colors.blueAccent cho chuẩn iOS
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Lưu thay đổi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để tạo từng dòng nhập liệu chuẩn iOS
  Widget _buildIOSInput({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 10, top: 2, bottom: 2), // Căn chỉnh padding
      child: Row(
        children: [
          // Nếu muốn label bên trái cố định (kiểu Settings cũ), bỏ comment dòng dưới
          // SizedBox(width: 120, child: Text(hint, style: const TextStyle(fontWeight: FontWeight.w500))),
          
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isObscure,
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                border: InputBorder.none, // Xóa border mặc định
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
            ),
          ),
          
          // Nút ẩn/hiện mật khẩu
          IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[400],
              size: 20,
            ),
            onPressed: onToggle,
          )
        ],
      ),
    );
  }
}