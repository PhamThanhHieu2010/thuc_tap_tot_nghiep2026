import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/utilities_service.dart'; // Import Service tiện ích

// Các màn hình chức năng
import 'interest_calc_screen.dart';
import 'calendar_stats_screen.dart';
import 'currency_converter_screen.dart';
import 'qr_gen_screen.dart';
import 'transfer_screen.dart';
import 'bills_screen.dart';
// Lưu ý: savings_screen nằm ở thư mục cha (more) nên cần ../ 
import '../savings_screen.dart';

// Import màn hình Quét Hóa Đơn (OCR)
import 'ocr_scan_screen.dart'; 

class MoreOptionsScreen extends StatefulWidget {
  const MoreOptionsScreen({super.key});

  @override
  State<MoreOptionsScreen> createState() => _MoreOptionsScreenState();
}

class _MoreOptionsScreenState extends State<MoreOptionsScreen> {
  
  // --- LOGIC XỬ LÝ ---

  // Xử lý tham gia gia đình
  void _showJoinFamilyDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Tham gia Gia đình"),
      content: TextField(
        controller: ctrl, 
        decoration: const InputDecoration(
          labelText: "Nhập Mã (VD: FAM123)", 
          border: OutlineInputBorder()
        )
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () {
            if (ctrl.text.isNotEmpty) {
              Provider.of<AuthProvider>(context, listen: false).joinFamily(ctrl.text);
              Navigator.pop(context);
              _showSnackBar("Đã gửi yêu cầu tham gia!", Colors.green);
            }
          }, 
          child: const Text("Tham gia")
        )
      ],
    ));
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2))
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background, // Nền xám sáng chuẩn iOS
      appBar: AppBar(
        title: Text(
          auth.t("Tiện ích"), 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 22)
        ),
        centerTitle: false, 
        elevation: 0,
        backgroundColor: AppTheme.background,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context) ? const BackButton(color: AppTheme.textDark) : null,
      ),
      // Đã xóa check _isLoading vì tính năng Excel đã bị loại bỏ
      body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- 1. KHỐI VÍ GIA ĐÌNH (iOS Widget Style) ---
                _sectionTitle(auth.t("Gia Đình")),
                Consumer<AppProvider>(
                  builder: (ctx, app, _) {
                    if (!auth.hasFamily) {
                      return _buildJoinFamilyCard(context, auth);
                    }
                    return _buildFamilyControlCard(context, auth, app);
                  }
                ),
                const SizedBox(height: 30),

                // --- 2. TÀI CHÍNH (Apple Home Tile Style) ---
                _sectionTitle(auth.t("Tài chính")),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, 
                  mainAxisSpacing: 16, 
                  crossAxisSpacing: 16, 
                  childAspectRatio: 1.5, // Hình chữ nhật ngang bo tròn
                  children: [
                    _featureCard(context, Icons.swap_horiz_rounded, auth.t("Chuyển tiền"), Colors.blue, const TransferScreen()),
                    _featureCard(context, Icons.savings_rounded, auth.t("Tiết kiệm"), Colors.orange, const SavingsScreen()),
                    _featureCard(context, Icons.calendar_today_rounded, auth.t("Lịch sử"), Colors.purple, const CalendarStatsScreen()),
                    _featureCard(context, Icons.receipt_long_rounded, auth.t("Hóa đơn"), Colors.redAccent, const BillsScreen()),
                  ],
                ),

                const SizedBox(height: 30),

                // --- 3. CÔNG CỤ & HỖ TRỢ (iOS Icon Grid) ---
                _sectionTitle(auth.t("Công cụ mở rộng")),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4, // 4 cột cho các công cụ nhỏ
                    mainAxisSpacing: 20, 
                    crossAxisSpacing: 15, 
                    childAspectRatio: 0.70, 
                    children: [
                      // Các tính năng cũ
                      _toolItem(
                        context, 
                        Icons.currency_exchange, 
                        auth.t("Tỷ giá"), 
                        Colors.green, 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyConverterScreen()))
                      ),
                      _toolItem(
                        context, 
                        Icons.calculate_rounded, 
                        auth.t("Lãi suất"), 
                        Colors.teal, 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InterestCalcScreen()))
                      ),
                      _toolItem(
                        context, 
                        Icons.qr_code_scanner_rounded, 
                        auth.t("Quét QR"), 
                        Colors.black87, 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRGenScreen()))
                      ),
                      
                      // --- [MỚI] TÍNH NĂNG QUÉT HÓA ĐƠN ---
                      _toolItem(
                        context, 
                        Icons.document_scanner_rounded, 
                        auth.t("Quét HĐ"), 
                        Colors.deepOrange, 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OCRScanScreen()))
                      ),

                      // --- CÁC TÍNH NĂNG KHÁC (Đã xóa Excel) ---
                      _toolItem(
                        context, 
                        Icons.ios_share_rounded, 
                        auth.t("Chia sẻ"), 
                        Colors.blueGrey, 
                        onTap: UtilitiesService.shareApp 
                      ),
                      _toolItem(
                        context, 
                        Icons.headset_mic_rounded, 
                        auth.t("Hỗ trợ"), 
                        Colors.pink, 
                        onTap: UtilitiesService.contactSupport 
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  // --- WIDGET CON ---

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title, 
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)
      ),
    );
  }

  // Card mời tham gia gia đình
  Widget _buildJoinFamilyCard(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () => _showJoinFamilyDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]), 
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.t("Kích hoạt Ví Gia Đình"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(auth.t("Quản lý chi tiêu chung cùng người thân"), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16)
          ],
        ),
      ),
    );
  }

  // Card quản lý gia đình
  Widget _buildFamilyControlCard(BuildContext context, AuthProvider auth, AppProvider app) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.home_filled, color: Colors.indigo, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ví Gia Đình", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                    Text("ID: ${auth.familyId}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch.adaptive(
                  value: app.isFamilyMode,
                  activeColor: AppTheme.iosGreen,
                  onChanged: (val) { app.toggleFamilyMode(val, auth.userId, auth.familyId); }
                ),
              )
            ],
          ),
          if (app.isFamilyMode) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(height: 1)),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.iosGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text("Đang xem & ghi chép vào Ví chung", style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.iosGreen, fontWeight: FontWeight.w500)))
              ],
            )
          ]
        ],
      ),
    );
  }

  // Card tính năng lớn
  Widget _featureCard(BuildContext context, IconData icon, String label, Color color, Widget? screen) {
    return GestureDetector(
      onTap: () { if (screen != null) Navigator.push(context, MaterialPageRoute(builder: (_) => screen)); },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  // Item công cụ nhỏ
  Widget _toolItem(BuildContext context, IconData icon, String label, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textDark), 
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}