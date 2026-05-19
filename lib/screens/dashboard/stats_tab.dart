import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _touchedIndex = -1;
  final _currencyFmt = NumberFormat("#,###", "vi_VN");

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context); // Lấy Auth để dịch

    // Lọc giao dịch chi tiêu
    final expenseTxs = appProvider.transactions
        .where((tx) => tx.type == 'expense') 
        .toList();

    double totalExpense = expenseTxs.fold(0, (sum, tx) => sum + tx.amount);

    // Gom nhóm theo danh mục
    Map<String, double> categoryMap = {};
    for (var tx in expenseTxs) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }

    // Sắp xếp giảm dần theo số tiền
    var sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        // Dịch tiêu đề: Thống kê chi tiêu -> Expense Statistics
        title: Text(authProvider.t("Thống kê chi tiêu"),
            style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==================================================
            // PHẦN 1: BIỂU ĐỒ TRÒN LỚN
            // ==================================================
            Text(authProvider.t("Tổng chi tiêu"), // Dùng từ khóa có trong từ điển
                style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 16)),
            const SizedBox(height: 20),
            
            Container(
              height: 320, 
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                // Viền xanh dương iOS
                border: Border.all(color: AppTheme.iosBlue.withOpacity(0.5), width: 2),
                boxShadow: AppTheme.softShadow,
              ),
              child: totalExpense == 0
                  // Dịch thông báo: Không có dữ liệu -> No data available
                  ? Center(child: Text(authProvider.t("Không có dữ liệu"), style: GoogleFonts.outfit(color: Colors.grey)))
                  : PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex =
                                  pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2, // Khoảng cách giữa các miếng
                        centerSpaceRadius: 60, // Lỗ tròn ở giữa
                        sections: _buildPieSections(sortedCategories, totalExpense),
                      ),
                    ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // PHẦN 2: DANH SÁCH CHI TIẾT
            // ==================================================
            Align(
                alignment: Alignment.centerLeft,
                // Dịch tiêu đề: Danh mục -> Category
                child: Text(authProvider.t("Danh mục"),
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark))),
            const SizedBox(height: 15),

            sortedCategories.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(authProvider.t("Không có dữ liệu"), style: const TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedCategories.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final entry = sortedCategories[i];
                      final categoryKey = entry.key; // Tên gốc trong DB (VD: "Ăn uống")
                      final amount = entry.value;
                      final percentage = totalExpense == 0 ? 0.0 : (amount / totalExpense);
                      
                      // Lấy thông tin UI dựa trên tên gốc
                      final uiInfo = _getCategoryUIInfo(categoryKey);

                      // Lấy tên hiển thị đã dịch (VD: "Ăn uống" -> "Food")
                      final displayName = authProvider.t(categoryKey);

                      return _buildDetailedCategoryItem(
                        name: displayName, // Hiển thị tên đã dịch
                        amount: amount,
                        percentage: percentage,
                        uiInfo: uiInfo,
                      );
                    },
                  ),
             const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  // =================================================================
  // CÁC HÀM HỖ TRỢ GIAO DIỆN
  // =================================================================

  Widget _buildDetailedCategoryItem({
    required String name,
    required double amount,
    required double percentage,
    required _CategoryUIInfo uiInfo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        // Màu nền pastel nhạt theo màu danh mục
        color: uiInfo.color.withOpacity(0.12), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(uiInfo.icon, color: uiInfo.color, size: 22),
          ),
          const SizedBox(width: 15),

          // Tên danh mục & Số tiền
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_currencyFmt.format(amount)} đ",
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Phần trăm
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12)
              ),
            child: Text(
              "${(percentage * 100).toStringAsFixed(1)}%",
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: uiInfo.color.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      List<MapEntry<String, double>> sortedCategories, double total) {
    return List.generate(sortedCategories.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 65.0 : 55.0;
      final entry = sortedCategories[i];
      final percentage = total == 0 ? 0.0 : (entry.value / total);
      
      final color = _getCategoryUIInfo(entry.key).color;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: percentage > 0.05 ? "${(percentage * 100).toStringAsFixed(0)}%" : "",
        radius: radius,
        titleStyle: GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [const Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }
  
  _CategoryUIInfo _getCategoryUIInfo(String categoryName) {
    // Map tên danh mục sang Icon và Màu sắc
    // Sử dụng tên gốc Tiếng Việt để map icon chính xác
    switch (categoryName.toLowerCase()) {
      case 'ăn uống': case 'thực phẩm': case 'food':
        return _CategoryUIInfo(Icons.restaurant_rounded, Colors.orange);
      case 'di chuyển': case 'đi lại': case 'xăng xe': case 'transport':
        return _CategoryUIInfo(Icons.directions_car_rounded, Colors.blue);
      case 'mua sắm': case 'shopping':
        return _CategoryUIInfo(Icons.shopping_bag_rounded, Colors.pink);
      case 'giải trí': case 'cafe': case 'xem phim': case 'entertainment':
        return _CategoryUIInfo(Icons.movie_filter_rounded, Colors.purple);
      case 'hóa đơn': case 'điện nước': case 'internet': case 'bills':
        return _CategoryUIInfo(Icons.receipt_long_rounded, Colors.redAccent);
      case 'sức khỏe': case 'y tế': case 'health':
        return _CategoryUIInfo(Icons.medical_services_rounded, Colors.teal);
      case 'giáo dục': case 'học tập': case 'education':
        return _CategoryUIInfo(Icons.school_rounded, Colors.indigo);
      default:
        // Hash code để tạo màu ngẫu nhiên cố định cho các danh mục lạ
        int hash = categoryName.hashCode;
        List<Color> defaultColors = [Colors.cyan, Colors.lime[700]!, Colors.amber[700]!, Colors.brown];
        return _CategoryUIInfo(
          Icons.category_rounded, 
          defaultColors[hash.abs() % defaultColors.length]
        );
    }
  }
}

class _CategoryUIInfo {
  final IconData icon;
  final Color color;
  _CategoryUIInfo(this.icon, this.color);
}