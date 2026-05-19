import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';

// --- SỬA LỖI DÒNG 12: Cập nhật đường dẫn đúng vào thư mục sub_screens ---
import 'sub_screens/top_up_modal.dart'; 

import 'sub_screens/transfer_screen.dart';
import 'sub_screens/bills_screen.dart';
import 'sub_screens/more_options_screen.dart';
import 'notification_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final app = Provider.of<AppProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        app.loadAllUserData(auth.userId, auth.familyId);
      }
    });
  }

  // --- HÀM GỌI MODAL NẠP TIỀN ---
  void _openTopUpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => const TopUpModal(), // Class này giờ đã được import đúng
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);
    final currency = NumberFormat("#,###", "vi_VN");

    final balance = app.totalBalance;
    final income = app.totalIncome;
    final expense = app.totalExpense;
    
    final recentTxs = List.from(app.transactions);
    recentTxs.sort((a, b) => b.date.compareTo(a.date));
    final displayTxs = recentTxs.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.background, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.t("Xin chào,"), style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 14)),
                    Text(auth.userName, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.iconShadow 
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),

            // 2. CARD SỐ DƯ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: AppTheme.iosBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.t("Số dư khả dụng"), style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 5),
                  Text("${currency.format(balance)} đ", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      _miniStat(Icons.arrow_downward, auth.t("Thu nhập"), income, Colors.white),
                      const SizedBox(width: 40),
                      _miniStat(Icons.arrow_upward, auth.t("Chi tiêu"), expense, Colors.white),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. TIỆN ÍCH
            Text(auth.t("Tiện ích nhanh"), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- SỬA LỖI DÒNG 47 (Xấp xỉ): Gọi hàm _openTopUpModal ---
                _actionButton(context, Icons.add_card, auth.t("Nạp tiền"), AppTheme.iosGreen, onTap: _openTopUpModal),
                
                _actionButton(context, Icons.send_rounded, auth.t("Chuyển tiền"), AppTheme.iosBlue, screen: const TransferScreen()),
                _actionButton(context, Icons.receipt_long, auth.t("Hóa đơn"), AppTheme.iosRed, screen: const BillsScreen()),
                _actionButton(context, Icons.grid_view, auth.t("Xem thêm"), AppTheme.iosPurple, screen: const MoreOptionsScreen()),
              ],
            ),

            const SizedBox(height: 30),

            // 4. GIAO DỊCH GẦN ĐÂY
            Text(auth.t("Giao dịch gần đây"), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 15),
            
            displayTxs.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Chưa có giao dịch", style: TextStyle(color: Colors.grey))))
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: displayTxs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final tx = displayTxs[i];
                  final props = AppTheme.categoryProps(tx.category);
                  bool isExpense = tx.type == 'expense';
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.softShadow 
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: props['bg'],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(props['icon'], color: props['color'], size: 22),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                              Text(DateFormat('dd/MM/yyyy').format(tx.date), style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          "${isExpense ? '-' : '+'}${currency.format(tx.amount)}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isExpense ? AppTheme.iosRed : AppTheme.iosGreen
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))
          ]
        ),
        const SizedBox(height: 4),
        Text(NumberFormat.compact().format(val), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color, {Widget? screen, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        if (screen != null) Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Column(
        children: [
          Container(
            height: 56, width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.softShadow,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w500))
        ],
      ),
    );
  }
}