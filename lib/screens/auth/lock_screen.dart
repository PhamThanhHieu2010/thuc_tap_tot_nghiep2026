import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../dashboard/main_layout.dart';

// Định nghĩa Enum LockMode (Đây là cái mà trình biên dịch đang báo thiếu)
enum LockMode { create, verify }

class LockScreen extends StatefulWidget {
  final LockMode mode;
  // Bỏ const ở constructor để tránh xung đột
  const LockScreen({super.key, required this.mode});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = "";
  String _title = "Nhập mã PIN";
  
  @override
  void initState() {
    super.initState();
    if (widget.mode == LockMode.create) {
      setState(() => _title = "Tạo mã PIN mới (4 số)");
    }
  }

  void _onNumTap(String num) async {
    if (_pin.length < 4) {
      setState(() => _pin += num);
      
      if (_pin.length == 4) {
        await Future.delayed(const Duration(milliseconds: 200));
        _handleFinish();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _handleFinish() async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.mode == LockMode.create) {
      // Lưu PIN mới
      await prefs.setString('user_pin', _pin);
      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã bật bảo mật PIN")));
      }
    } else {
      // Xác thực PIN cũ
      String? savedPin = prefs.getString('user_pin');
      if (savedPin == _pin) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
        }
      } else {
        setState(() => _pin = "");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai mã PIN"), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.lock, size: 50, color: Colors.white),
            const SizedBox(height: 20),
            Text(_title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 15, height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length ? Colors.white : Colors.white24,
                  ),
                );
              }),
            ),
            
            const Spacer(),
            
            Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  _row(['1', '2', '3']),
                  _row(['4', '5', '6']),
                  _row(['7', '8', '9']),
                  _row(['', '0', 'del']),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _row(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((k) {
          if (k == '') return const SizedBox(width: 70, height: 70);
          return InkWell(
            onTap: k == 'del' ? _onDelete : () => _onNumTap(k),
            borderRadius: BorderRadius.circular(35),
            child: Container(
              width: 70, height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white24)
              ),
              child: k == 'del' 
                ? const Icon(Icons.backspace_outlined, color: Colors.white)
                : Text(k, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          );
        }).toList(),
      ),
    );
  }
}