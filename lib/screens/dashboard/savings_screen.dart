import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/savings_goal.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/custom_textfield.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});
  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = Provider.of<AuthProvider>(context, listen: false).userId;
      Provider.of<AppProvider>(context, listen: false).fetchSavings(uid);
    });
  }

  void _showTransactionDialog(SavingsGoalModel goal, String type) {
    final amountCtrl = TextEditingController();
    final isDeposit = type == 'deposit';
    
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(isDeposit ? "Nạp thêm vào quỹ" : "Rút tiền về ví chính", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDeposit ? Colors.green : Colors.red)),
        const SizedBox(height: 10),
        Text("Mục tiêu: ${goal.title}", style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        CustomTextField(label: "Số tiền", controller: amountCtrl, isCurrency: true, icon: Icons.attach_money),
        const SizedBox(height: 20),
        BouncyButton(
          text: "XÁC NHẬN",
          color: isDeposit ? Colors.green : Colors.red,
          onPressed: () {
            double amount = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
            if (amount > 0) {
              final app = Provider.of<AppProvider>(context, listen: false);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              
              // Gọi hàm xử lý logic phức tạp (Cập nhật Goal + Tạo Transaction)
              app.processSavingsTransaction(auth.userId, auth.familyId, goal, amount, type);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isDeposit ? "Đã nạp tiền & Trừ ví chính!" : "Đã rút tiền về ví chính!")));
            }
          },
        )
      ]),
    ));
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final currentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Mục tiêu mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            CustomTextField(label: "Tên mục tiêu", controller: titleCtrl, icon: Icons.flag),
            const SizedBox(height: 10),
            CustomTextField(label: "Mục tiêu (VNĐ)", controller: targetCtrl, isCurrency: true, icon: Icons.flag_circle),
            const SizedBox(height: 10),
            CustomTextField(label: "Hiện có (VNĐ)", controller: currentCtrl, isCurrency: true, icon: Icons.savings),
            const SizedBox(height: 20),
            BouncyButton(
              text: "LƯU LẠI",
              color: AppTheme.primary,
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                final app = Provider.of<AppProvider>(context, listen: false);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                
                final newGoal = SavingsGoalModel(
                  id: "", title: titleCtrl.text,
                  targetAmount: double.tryParse(targetCtrl.text.replaceAll(',', '')) ?? 0,
                  currentAmount: double.tryParse(currentCtrl.text.replaceAll(',', '')) ?? 0,
                  colorValue: 0xFF00B894,
                  iconCode: Icons.savings_rounded.codePoint,
                );
                app.addSavings(auth.userId, newGoal);
                Navigator.pop(context);
              },
            )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currencyFormat = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      appBar: AppBar(title: const Text("Tiết kiệm"), backgroundColor: Colors.white),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, backgroundColor: AppTheme.primary, child: const Icon(Icons.add, color: Colors.white)),
      body: app.savings.isEmpty 
        ? const Center(child: Text("Chưa có mục tiêu nào"))
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: app.savings.length,
            itemBuilder: (ctx, i) {
              final goal = app.savings[i];
              double percent = goal.targetAmount == 0 ? 0 : (goal.currentAmount / goal.targetAmount);
              if (percent > 1) percent = 1;

              return Dismissible(
                key: ValueKey(goal.id),
                onDismissed: (_) => app.deleteSavings(auth.userId, goal.id),
                background: Container(color: Colors.red),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(children: [
                          // Nút Rút
                          IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => _showTransactionDialog(goal, 'withdraw')),
                          // Nút Nạp
                          IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => _showTransactionDialog(goal, 'deposit')),
                        ])
                      ]),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(value: percent, color: AppTheme.primary, backgroundColor: Colors.grey[200], minHeight: 8, borderRadius: BorderRadius.circular(5)),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                         Text("${currencyFormat.format(goal.currentAmount)} đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                         Text("${(percent*100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.grey)),
                      ])
                    ]),
                  ),
                ),
              );
            },
          ),
    );
  }
}