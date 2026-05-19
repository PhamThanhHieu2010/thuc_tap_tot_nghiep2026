import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme.dart';
import '../../../models/bill.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/auth_provider.dart';
// Lưu ý: Nếu CustomTextField/BouncyButton không dùng nữa trong UI mới, có thể bỏ import hoặc giữ lại nếu logic cần.
// Ở đây tôi sẽ dùng UI native hơn để chuẩn iOS.

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final uid = Provider.of<AuthProvider>(context, listen: false).userId;
        Provider.of<AppProvider>(context, listen: false).fetchBills(uid);
      }
    });
  }

  // --- LOGIC: THÊM HÓA ĐƠN (Giao diện BottomSheet) ---
  void _showAddSheet() {
    final titleCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text("Hóa đơn mới", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // Input Style iOS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description_outlined, color: Colors.grey),
                  hintText: "Tên dịch vụ (VD: Điện, Internet...)",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    final app = Provider.of<AppProvider>(context, listen: false);
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    final newBill = BillModel(id: "", title: titleCtrl.text, amount: 0, date: DateTime.now(), isPaid: false);
                    app.addBill(auth.userId, newBill);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Tạo Hóa Đơn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- LOGIC: THANH TOÁN (Giao diện BottomSheet) ---
  void _showPaySheet(BillModel bill) {
    final amountCtrl = TextEditingController(text: bill.amount > 0 ? bill.amount.toStringAsFixed(0) : "");
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Thanh toán: ${bill.title}", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Nhập số tiền thực tế kỳ này:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            // Input tiền lớn
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.iosGreen),
              decoration: const InputDecoration(
                hintText: "0",
                suffixText: "đ",
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.iosGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: AppTheme.iosGreen.withOpacity(0.4),
                ),
                onPressed: () {
                  double amount = double.tryParse(amountCtrl.text.replaceAll(',', '').replaceAll('.', '')) ?? 0;
                  if (amount > 0) {
                    final app = Provider.of<AppProvider>(context, listen: false);
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    app.payBillRecuring(auth.userId, auth.familyId, bill, amount);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thanh toán thành công!")));
                  }
                },
                child: const Text("XÁC NHẬN THANH TOÁN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background, // Nền xám iOS
      appBar: AppBar(
        title: Text("Hóa đơn định kỳ", style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          // Nút Add chuẩn iOS
          IconButton(
            onPressed: _showAddSheet,
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: AppTheme.textDark, size: 20),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: app.bills.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: app.bills.length,
            itemBuilder: (ctx, i) {
              final bill = app.bills[i];
              return _buildBillItem(bill, app, auth);
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("Chưa có hóa đơn nào", style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 16)),
          TextButton(onPressed: _showAddSheet, child: const Text("Thêm ngay"))
        ],
      ),
    );
  }

  Widget _buildBillItem(BillModel bill, AppProvider app, AuthProvider auth) {
    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Xác nhận xóa"),
            content: Text("Bạn có chắc muốn xóa hóa đơn '${bill.title}'?"),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Hủy")),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        app.deleteBill(auth.userId, bill.id);
      },
      child: GestureDetector(
        onLongPress: () => app.deleteBill(auth.userId, bill.id), // Giữ backup long press
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              // 1. Icon Box
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: bill.isPaid ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getBillIcon(bill.title), 
                  color: bill.isPaid ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              
              // 2. Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title, 
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bill.isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: Text(
                        bill.isPaid 
                          ? "Đã thanh toán ${DateFormat('dd/MM').format(bill.date)}" 
                          : "Chưa thanh toán",
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: bill.isPaid ? Colors.green : Colors.red
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // 3. Action Button
              if (!bill.isPaid)
                InkWell(
                  onTap: () => _showPaySheet(bill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.textDark, // Nút đen sang trọng
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Pay", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                  ),
                )
              else
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28)
            ],
          ),
        ),
      ),
    );
  }

  // Hàm chọn icon dựa trên tên (đơn giản hóa)
  IconData _getBillIcon(String title) {
    title = title.toLowerCase();
    if (title.contains("điện")) return Icons.electric_bolt_rounded;
    if (title.contains("nước")) return Icons.water_drop_rounded;
    if (title.contains("net") || title.contains("wifi")) return Icons.wifi_rounded;
    if (title.contains("nhà")) return Icons.home_rounded;
    return Icons.receipt_long_rounded;
  }
}