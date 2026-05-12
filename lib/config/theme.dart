import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. NỀN & CƠ BẢN (LIGHT MODE)
  static const Color background = Color(0xFFF2F4F7); // Xám sáng (iOS System Gray)
  static const Color surface = Colors.white;         // Trắng sứ
  static const Color textDark = Color(0xFF1C1C1E);   // Đen iOS
  static const Color textGrey = Color(0xFF8E8E93);   // Xám chữ phụ

  // 2. MÀU IOS VIBRANT (Dùng cho Icon, Button)
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosGreen = Color(0xFF34C759);   // Thu nhập
  static const Color iosRed = Color(0xFFFF3B30);     // Chi tiêu
  static const Color iosOrange = Color(0xFFFF9500);  // Cảnh báo
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosTeal = Color(0xFF5AC8FA);
  static const Color iosYellow = Color(0xFFFFCC00);

  static const Color primary = iosBlue;
  static const Color secondary = iosPurple;
  
  static const Color income = iosGreen;
  static const Color expense = iosRed;

  static const Color neonCyan = iosBlue;
  static const Color neonPink = iosRed;
  static const Color neonLime = iosGreen;
  static const Color neonPurple = iosPurple;
  static const Color neonOrange = iosOrange;

  // 4. GRADIENTS
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)], // Xanh biển nhạt -> đậm
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF2F4F7)], // Trắng -> Xám nhạt
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 5. SHADOWS (BÓNG MỊN)
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    )
  ];
  
  static List<BoxShadow> iconShadow = [
    BoxShadow(
      color: iosBlue.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    )
  ];

  // 6. STYLE TEXT
  static TextTheme textTheme = GoogleFonts.outfitTextTheme().apply(
    bodyColor: textDark,
    displayColor: textDark,
  );

  // 7. ICON MAPPING
  static Map<String, dynamic> categoryProps(String category) {
    Color bg(Color c) => c.withOpacity(0.1);
    switch (category) {
      case 'Ăn uống': return {'icon': Icons.fastfood_rounded, 'color': iosOrange, 'bg': bg(iosOrange)};
      case 'Di chuyển': return {'icon': Icons.directions_car_rounded, 'color': iosBlue, 'bg': bg(iosBlue)};
      case 'Shopping': return {'icon': Icons.shopping_bag_rounded, 'color': iosPurple, 'bg': bg(iosPurple)};
      case 'Giải trí': return {'icon': Icons.gamepad_rounded, 'color': iosTeal, 'bg': bg(iosTeal)};
      case 'Điện/Nước': return {'icon': Icons.bolt_rounded, 'color': iosYellow, 'bg': bg(iosYellow)};
      case 'Lương': return {'icon': Icons.attach_money_rounded, 'color': iosGreen, 'bg': bg(iosGreen)};
      case 'Sức khỏe': return {'icon': Icons.medical_services_rounded, 'color': iosRed, 'bg': bg(iosRed)};
      default: return {'icon': Icons.category_rounded, 'color': textGrey, 'bg': Colors.grey.shade100};
    }
  }
}