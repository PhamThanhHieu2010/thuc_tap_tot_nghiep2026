import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../dashboard/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _inputCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_inputCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")));
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await auth.login(_inputCtrl.text.trim(), _passCtrl.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Logo Icon Gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.iosBlue, AppTheme.iosTeal]),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: AppTheme.iconShadow,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 25),
                Text("Smart Manager", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Text("Quản lý tài chính thông minh", style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textGrey)),
                
                const SizedBox(height: 50),
                CustomTextField(label: "Tài khoản", controller: _inputCtrl, icon: Icons.person_outline),
                const SizedBox(height: 20),
                CustomTextField(label: "Mật khẩu", controller: _passCtrl, isPassword: true, icon: Icons.lock_outline),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text("Quên mật khẩu?", style: TextStyle(color: AppTheme.iosBlue, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 30),
                BouncyButton(text: "ĐĂNG NHẬP", onPressed: _login, color: AppTheme.iosBlue, isLoading: _isLoading),

                const SizedBox(height: 30),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Chưa có tài khoản? ", style: TextStyle(color: AppTheme.textGrey)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text("Đăng ký ngay", style: TextStyle(color: AppTheme.iosBlue, fontWeight: FontWeight.bold)),
                  )
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}