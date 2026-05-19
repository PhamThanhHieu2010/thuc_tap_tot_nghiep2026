import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")));
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu xác nhận không khớp!")));
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await auth.register(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công! Vui lòng đăng nhập.")));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thất bại. Email có thể đã tồn tại.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.darkBackgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark), onPressed: () => Navigator.pop(context))),
                const SizedBox(height: 20),
                Text("Tạo tài khoản", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                
                const SizedBox(height: 40),
                CustomTextField(label: "Họ và Tên", controller: _nameCtrl, icon: Icons.badge_outlined),
                const SizedBox(height: 15),
                CustomTextField(label: "Email hoặc SĐT", controller: _emailCtrl, icon: Icons.email_outlined),
                const SizedBox(height: 15),
                CustomTextField(label: "Mật khẩu", controller: _passCtrl, isPassword: true, icon: Icons.lock_outline),
                const SizedBox(height: 15),
                CustomTextField(label: "Nhập lại mật khẩu", controller: _confirmPassCtrl, isPassword: true, icon: Icons.lock_reset),
                
                const SizedBox(height: 40),
                if (_isLoading) const CircularProgressIndicator(color: AppTheme.primary)
                else BouncyButton(text: "ĐĂNG KÝ", onPressed: _register, color: AppTheme.secondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}