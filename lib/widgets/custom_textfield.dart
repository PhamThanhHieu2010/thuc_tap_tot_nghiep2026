import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../config/theme.dart';
import '../providers/auth_provider.dart'; // 2. Import AuthProvider

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;
  final bool isCurrency;
  final TextInputType? inputType;

  const CustomTextField({super.key, required this.label, required this.controller, required this.icon, this.isPassword = false, this.isCurrency = false, this.inputType});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // 3. Lấy AuthProvider để dùng hàm dịch t()
    final auth = Provider.of<AuthProvider>(context);
    
    TextInputType type = widget.inputType ?? TextInputType.text;
    if (widget.isCurrency) type = TextInputType.number;

    // 4. Xử lý Logic Hint Text Đa Ngôn Ngữ
    // auth.t('Nhập') -> Trả về "Nhập" (Vi) hoặc "Enter" (En)
    // auth.t(widget.label) -> Dịch nhãn (VD: "Mật khẩu" -> "Password")
    // Kết quả En: "Enter password..."
    String translatedLabel = auth.t(widget.label);
    String hint = "${auth.t('Nhập')} ${translatedLabel.toLowerCase()}...";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          // 5. Hiển thị Label đã dịch
          child: Text(translatedLabel, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7), // Nền input xám nhạt
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: type,
            style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500),
            cursorColor: AppTheme.iosBlue,
            decoration: InputDecoration(
              hintText: hint, // 6. Sử dụng Hint đã xử lý
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(widget.icon, color: AppTheme.iosBlue),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : (widget.isCurrency
                      ? const Padding(padding: EdgeInsets.all(15), child: Text("VNĐ", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.iosGreen)))
                      : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}