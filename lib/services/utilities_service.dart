import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilitiesService {
  
  // --- ĐÃ XÓA CHỨC NĂNG XUẤT EXCEL ---

  // --- 2. CÁC CHỨC NĂNG KHÁC (GIỮ LẠI ĐỂ APP KHÔNG BỊ LỖI) ---
  
  // Hàm chia sẻ ứng dụng
  static Future<void> shareApp() async {
    // Bạn có thể thay link bên dưới bằng link App Store/CH Play thực tế của bạn sau này
    const String appLink = "https://play.google.com/store/apps/details?id=com.yourapp.smartmanager"; 
    await Share.share(
      "Quản lý chi tiêu hiệu quả với Smart Manager. Tải ngay: $appLink",
      subject: "Mời tải App Smart Manager"
    );
  }

  // Hàm liên hệ hỗ trợ (Mở Zalo/Web)
  static Future<void> contactSupport() async {
    final Uri supportUrl = Uri.parse('https://zalo.me/0372148778'); 
    try {
      if (!await launchUrl(supportUrl, mode: LaunchMode.externalApplication)) {
        throw 'Không thể mở ứng dụng hỗ trợ.';
      }
    } catch (e) {
      throw 'Lỗi kết nối: $e';
    }
  }
}