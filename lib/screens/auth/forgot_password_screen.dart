import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../providers/auth_provider.dart';

// ---------------------------------------------------------
// MÀN HÌNH 1: NHẬP EMAIL ĐỂ XÁC MINH
// ---------------------------------------------------------
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  void _verifyEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- LOGIC GIẢ LẬP KIỂM TRA EMAIL ---
    await Future.delayed(const Duration(seconds: 1)); // Giả lập loading

    // Giả định email luôn đúng để test luồng
    bool isValidEmail = true; 

    setState(() => _isLoading = false);

    if (isValidEmail && mounted) {
      // Chuyển sang màn hình nhập mật khẩu mới
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: email)),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email không tồn tại"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.darkBackgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
          child: FadeInUp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Icon ổ khóa
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_rounded, size: 60, color: AppTheme.primary),
                ),
                
                const SizedBox(height: 30),
                Text("Xác thực Email", style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 10),
                const Text(
                  "Vui lòng nhập email tài khoản của bạn. Chúng tôi sẽ chuyển bạn đến màn hình đổi mật khẩu ngay lập tức.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textGrey),
                ),

                const SizedBox(height: 40),
                
                // --- ĐÃ SỬA LỖI Ở ĐÂY (Dòng ~108 cũ): Bỏ keyboardType ---
                CustomTextField(
                  label: "Nhập Email của bạn", 
                  controller: _emailCtrl, 
                  icon: Icons.mail_outline,
                ),
                
                const SizedBox(height: 30),
                
                if (_isLoading)
                  const CircularProgressIndicator(color: AppTheme.primary)
                else
                  BouncyButton(
                    text: "TIẾP TỤC", 
                    onPressed: _verifyEmail,
                    color: AppTheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// MÀN HÌNH 2: ĐẶT LẠI MẬT KHẨU MỚI
// ---------------------------------------------------------
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() async {
    final pass = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin"), backgroundColor: Colors.red));
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu xác nhận không khớp"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    // --- LOGIC GỌI PROVIDER ĐỂ ĐỔI PASS ---
    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay

    setState(() => _isLoading = false);

    if (mounted) {
      // Hiển thị thông báo thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Thành công"),
          content: const Text("Mật khẩu của bạn đã được thay đổi. Vui lòng đăng nhập lại."),
          actions: [
            TextButton(
              onPressed: () {
                // Quay về màn hình Login (xóa hết các màn hình trước đó)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Đăng nhập ngay", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
         height: double.infinity,
         decoration: const BoxDecoration(
           gradient: AppTheme.darkBackgroundGradient,
         ),
         child: SingleChildScrollView(
           padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
           child: FadeInUp(
             child: Column(
               children: [
                 Align(
                   alignment: Alignment.topLeft,
                   child: IconButton(
                     icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
                     onPressed: () => Navigator.pop(context),
                   ),
                 ),
                 const SizedBox(height: 20),
                 
                 Container(
                   padding: const EdgeInsets.all(25),
                   decoration: BoxDecoration(
                     color: AppTheme.iosGreen.withOpacity(0.1),
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.lock_reset_rounded, size: 60, color: AppTheme.iosGreen),
                 ),
                 
                 const SizedBox(height: 30),
                 Text("Mật khẩu mới", style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                 const SizedBox(height: 10),
                 Text(
                   "Đặt lại mật khẩu cho tài khoản:\n${widget.email}",
                   textAlign: TextAlign.center,
                   style: const TextStyle(color: AppTheme.textGrey),
                 ),

                 const SizedBox(height: 40),
                 
                 // Sửa: Dùng tham số mặc định hoặc obscureText nếu CustomTextField hỗ trợ
                 // Nếu dòng này vẫn lỗi, hãy xóa thuộc tính obscureText và kiểm tra CustomTextField của bạn
                 CustomTextField(
                   label: "Mật khẩu mới", 
                   controller: _passCtrl, 
                   icon: Icons.lock_outline, 
                   // obscureText: true, // Bỏ comment nếu CustomTextField có hỗ trợ
                 ),
                 
                 const SizedBox(height: 15),
                 
                 CustomTextField(
                   label: "Xác nhận mật khẩu", 
                   controller: _confirmPassCtrl, 
                   icon: Icons.lock_outline, 
                   // obscureText: true, // Bỏ comment nếu CustomTextField có hỗ trợ
                 ),
                 
                 const SizedBox(height: 30),
                 if (_isLoading)
                    const CircularProgressIndicator(color: AppTheme.primary)
                 else
                    BouncyButton(
                      text: "LƯU MẬT KHẨU", 
                      onPressed: _resetPassword,
                      color: AppTheme.primary,
                    ),
               ],
             ),
           ),
         ),
      ),
    );
  }
}