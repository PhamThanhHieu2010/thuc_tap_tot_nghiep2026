import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';
import '../../../models/transaction.dart';

class CalendarStatsScreen extends StatefulWidget {
  const CalendarStatsScreen({super.key});

  @override
  State<CalendarStatsScreen> createState() => _CalendarStatsScreenState();
}

class _CalendarStatsScreenState extends State<CalendarStatsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // --- LOGIC GIỮ NGUYÊN ---
  List<TransactionModel> _getEventsForDay(DateTime day, List<TransactionModel> allTx) {
    return allTx.where((tx) => 
      tx.date.year == day.year && 
      tx.date.month == day.month && 
      tx.date.day == day.day
    ).toList();
  }

  double _calculateDailyTotal(List<TransactionModel> txs) {
    double total = 0;
    for (var tx in txs) {
      if (tx.type == 'income') total += tx.amount;
      else total -= tx.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final allTx = app.transactions;
    final selectedTransactions = _getEventsForDay(_selectedDay!, allTx);
    final currency = NumberFormat("#,###", "vi_VN");
    
    // Tính tổng tiền trong ngày đang chọn
    double dailyTotal = _calculateDailyTotal(selectedTransactions);

    return Scaffold(
      backgroundColor: AppTheme.background, // Nền xám sáng iOS
      appBar: AppBar(
        title: Text("Lịch sử giao dịch", style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: Column(
        children: [
          // 1. CALENDAR SECTION
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.softShadow,
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) => _getEventsForDay(day, allTx),
              
              // Style header
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.textDark),
                rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.textDark),
              ),

              // Style Calendar Body
              calendarStyle: CalendarStyle(
                // Font chữ
                defaultTextStyle: GoogleFonts.outfit(color: AppTheme.textDark),
                weekendTextStyle: GoogleFonts.outfit(color: Colors.redAccent),
                
                // Ngày hiện tại
                todayDecoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                
                // Ngày đang chọn (Selected)
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.textDark, // Hoặc AppTheme.primary
                  shape: BoxShape.circle,
                ),
                
                // Marker (Dấu chấm dưới ngày có giao dịch)
                markerDecoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
              ),
            ),
          ),

          // 2. DAILY SUMMARY HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chi tiết ngày ${DateFormat('dd/MM').format(_selectedDay!)}", 
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])
                ),
                if (selectedTransactions.isNotEmpty)
                  Text(
                    "${dailyTotal >= 0 ? '+' : ''}${currency.format(dailyTotal)} đ",
                    style: GoogleFonts.outfit(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: dailyTotal >= 0 ? AppTheme.iosGreen : AppTheme.expense
                    ),
                  ),
              ],
            ),
          ),

          // 3. TRANSACTION LIST
          Expanded(
            child: selectedTransactions.isEmpty
            ? _buildEmptyState()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: selectedTransactions.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 60, color: Colors.black12),
                    itemBuilder: (ctx, i) {
                      final tx = selectedTransactions[i];
                      return _buildTransactionItem(tx, currency);
                    },
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }

  // Widget: Empty State (Khi không có dữ liệu)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(Icons.calendar_today_rounded, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 15),
          Text(
            "Không có giao dịch", 
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[500])
          ),
        ],
      ),
    );
  }

  // Widget: Single Transaction Item (Style iOS List)
  Widget _buildTransactionItem(TransactionModel tx, NumberFormat currency) {
    bool isExpense = tx.type == 'expense';
    Color color = isExpense ? AppTheme.expense : AppTheme.income;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12), // Squircle
            ),
            child: Icon(
              isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
              color: color, 
              size: 20
            ),
          ),
          const SizedBox(width: 15),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(tx.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          
          // Amount
          Text(
            "${isExpense ? '-' : '+'}${currency.format(tx.amount)}",
            style: GoogleFonts.outfit(
              color: isExpense ? Colors.black : AppTheme.iosGreen, // Số âm màu đen (chuẩn tài chính) hoặc đỏ tuỳ ý
              fontWeight: FontWeight.bold,
              fontSize: 15
            ),
          ),
        ],
      ),
    );
  }
}