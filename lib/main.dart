import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Để format ngày tháng tiếng Việt
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CÁC IMPORT CỦA DỰ ÁN ---
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'services/notification_service.dart';

// --- CÁC MÀN HÌNH ---
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/main_layout.dart';
import 'screens/auth/lock_screen.dart';

void main() async {
  // 1. Đảm bảo Flutter Binding được khởi tạo trước khi gọi code native
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Khởi tạo định dạng ngày tháng tiếng Việt (quan trọng cho AI đọc ngày)
  await initializeDateFormatting('vi_VN', null);
  
  // 3. Khởi tạo dịch vụ thông báo (Nếu có dùng)
  await NotificationService.init(); 

  // 4. Chạy App với MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider: Quản lý đăng nhập
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAutoLogin()),
        
        // AppProvider: Quản lý Ví, Giao dịch (AI sẽ đọc dữ liệu từ đây)
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Kiểm tra xem người dùng có bật tính năng khóa bảo mật không
  Future<bool> _checkSecurityEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_security_enabled') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Manager',
      debugShowCheckedModeBanner: false, // Tắt banner Debug
      
      // --- CẤU HÌNH THEME ---
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.background,
        primaryColor: AppTheme.primary,
        // Sử dụng Font Poppins hoặc Outfit tùy thiết kế của bạn
        textTheme: GoogleFonts.outfitTextTheme(), 
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
      ),

      // --- LOGIC ĐIỀU HƯỚNG MÀN HÌNH ---
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          // 1. Nếu chưa đăng nhập -> Về trang Login
          if (!auth.isAuthenticated) {
            return const LoginScreen();
          } 
          
          // 2. Nếu đã đăng nhập -> Kiểm tra khóa bảo mật
          else {
            return FutureBuilder<bool>(
              future: _checkSecurityEnabled(),
              builder: (context, snapshot) {
                // Đang tải trạng thái bảo mật...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  );
                }
                
                // Nếu có bật bảo mật -> Hiện màn hình khóa
                if (snapshot.data == true) {
                  return const LockScreen(mode: LockMode.verify);
                }
                
                // Cuối cùng -> Vào màn hình chính (Dashboard)
                return const MainLayout();
              },
            );
          }
        },
      ),
    );
  }
}