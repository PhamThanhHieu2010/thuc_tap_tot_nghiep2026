import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../services/seed_data_service.dart'; 
import '../../services/utilities_service.dart';

// Import các màn hình con
import 'sub_screens/change_password_screen.dart';
import 'sub_screens/more_options_screen.dart';
import '../auth/lock_screen.dart';
import '../auth/login_screen.dart';
import 'savings_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notifEnabled = true;
  bool _securityEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Refresh lại thông tin user khi vào màn hình này
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserInfo();
    });
  }

  void _refreshUserInfo() {
      // Provider.of<AuthProvider>(context, listen: false).reloadUserData();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notifEnabled = prefs.getBool('is_notif_enabled') ?? true;
        _securityEnabled = prefs.getBool('is_security_enabled') ?? false;
      });
    }
  }

  void _toggleSecurity(bool value) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    
    if (value) {
      // Khi bật bảo mật -> Yêu cầu tạo mã PIN
      final result = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => const LockScreen(mode: LockMode.create))
      );
      
      if (result == true) {
        setState(() => _securityEnabled = true);
        await prefs.setBool('is_security_enabled', true);
        if(mounted) _showSnackBar(auth.t("Thành công"), AppTheme.iosGreen);
      }
    } else {
      // Tắt bảo mật
      setState(() => _securityEnabled = false);
      await prefs.setBool('is_security_enabled', false);
    }
  }

  // Đã xóa hàm _exportExcel

  void _seedData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final app = Provider.of<AppProvider>(context, listen: false);
      
      await SeedDataService.seed(auth.userId, auth.familyId);
      await app.loadAllUserData(auth.userId, auth.familyId);
      
      if (mounted) _showSnackBar(auth.t("Đã tạo dữ liệu mẫu thành công"), AppTheme.iosGreen);
    } catch (e) {
      if (mounted) _showSnackBar("${auth.t('Lỗi')}: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(auth.t("Đăng xuất"), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(auth.t("Bạn có chắc chắn muốn đăng xuất?")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text(auth.t("Hủy"), style: const TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              await auth.logout(context); 
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            }, 
            child: Text(auth.t("Đồng ý"), style: const TextStyle(color: AppTheme.iosRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2))
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final displayName = (auth.userName.isNotEmpty) ? auth.userName : auth.t("Khách");
    final displayEmail = (auth.emailOrPhone.isNotEmpty) ? auth.emailOrPhone : "---";

    return Scaffold(
      backgroundColor: AppTheme.background, 
      appBar: AppBar(
        title: Text(auth.t("Cài đặt"), style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow, 
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30, 
                        backgroundColor: AppTheme.iosBlue.withOpacity(0.1), 
                        child: const Icon(Icons.person, color: AppTheme.iosBlue, size: 30)
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            const SizedBox(height: 4),
                            Text(displayEmail, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // SECTION 1: TÍNH NĂNG (FEATURES)
                _section(auth.t("Tiện ích")), 
                _group([
                  _tile(Icons.savings, auth.t("Tiết kiệm"), AppTheme.iosRed, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()))),
                  _tile(Icons.grid_view, auth.t("Xem thêm"), AppTheme.iosPurple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoreOptionsScreen()))),
                ]),
                const SizedBox(height: 20),

                // SECTION 2: CÔNG CỤ (TOOLS) 
                _section(auth.t("Công cụ & Hỗ trợ")),
                _group([
                  // Đã xóa nút Xuất Excel ở đây
                  _tile(Icons.share, auth.t("Chia sẻ"), Colors.blueGrey, onTap: UtilitiesService.shareApp),
                  _tile(Icons.headset_mic, auth.t("Hỗ trợ"), Colors.pinkAccent, onTap: UtilitiesService.contactSupport),
                ]),
                const SizedBox(height: 20),

                // SECTION 3: HỆ THỐNG (SYSTEM)
                _section(auth.t("Hệ thống")),
                _group([
                  // Đổi mật khẩu
                  _tile(Icons.lock_outline, auth.t("Đổi mật khẩu"), AppTheme.iosOrange, onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                      if (result == true && mounted) {
                        _showSnackBar(auth.t("Thành công"), AppTheme.iosGreen);
                      }
                  }),
                  
                  // Bảo mật PIN
                  _switchTile(Icons.security, auth.t("Bảo mật PIN"), AppTheme.iosGreen, _securityEnabled, _toggleSecurity),
                  
                  // Thông báo
                  _switchTile(Icons.notifications_none, auth.t("Thông báo"), AppTheme.iosBlue, _notifEnabled, (v) => setState(() => _notifEnabled = v)),
                  
                  // Ngôn ngữ (Hiển thị rõ trạng thái)
                  _tile(
                    Icons.language, 
                    "${auth.t('Ngôn ngữ')}: ${auth.language == 'vi' ? 'Tiếng Việt' : 'English'}", 
                    Colors.indigo, 
                    onTap: () => auth.switchLanguage()
                  ),
                  
                  // Nạp dữ liệu mẫu
                  _tile(Icons.cloud_upload_outlined, auth.t("Nạp dữ liệu mẫu (Demo)"), AppTheme.iosTeal, onTap: _seedData),
                ]),
                
                const SizedBox(height: 30),
                
                // BUTTON ĐĂNG XUẤT
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: _logout, 
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.iosRed.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(auth.t("Đăng xuất"), style: const TextStyle(color: AppTheme.iosRed, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Text("${auth.t('Phiên bản')} 1.0.0", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 80),
              ],
            ),
          ),
    );
  }

  Widget _section(String title) => Align(
    alignment: Alignment.centerLeft, 
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10), 
      child: Text(title.toUpperCase(), style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w600, fontSize: 13))
    )
  );
  
  Widget _group(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppTheme.softShadow,
    ), 
    child: Column(children: children)
  );
  
  Widget _tile(IconData icon, String title, Color color, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8), 
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), 
        child: Icon(icon, color: color, size: 20)
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _switchTile(IconData icon, String title, Color color, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8), 
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), 
        child: Icon(icon, color: color, size: 20)
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500)),
      value: value,
      activeColor: AppTheme.iosBlue,
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      onChanged: onChanged,
    );
  }
}