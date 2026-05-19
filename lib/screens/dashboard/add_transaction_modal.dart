import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_textfield.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});
  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  
  String _type = 'expense';
  String _cat = "Ăn uống";
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  final List<String> _cats = ["Ăn uống", "Shopping", "Di chuyển", "Điện/Nước", "Giải trí", "Lương", "Giáo dục", "Sức khỏe", "Khác"];

  // Logic giữ nguyên
  void _save() async {
    if (_titleCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    double amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    
    if (!mounted) return;
    final app = Provider.of<AppProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final newTx = TransactionModel(
      id: "", 
      title: _titleCtrl.text,
      amount: amount,
      date: _selectedDate,
      type: _type,
      category: _cat,
    );

    try {
      await app.addTransaction(auth.userId, auth.familyId, newTx);
      if(mounted) Navigator.pop(context);
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi kết nối!")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: _selectedDate, 
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _type == 'expense' ? AppTheme.iosRed : AppTheme.iosGreen, // Màu lịch theo loại
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    // Xác định màu chủ đạo dựa trên Type
    final activeColor = _type == 'expense' ? AppTheme.iosRed : AppTheme.iosGreen;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Handle Bar (Thanh gạch ngang đặc trưng iOS)
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const Center(child: Text("Thêm Giao Dịch", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark))),
          const SizedBox(height: 25),

          // 2. Type Switcher (Nút bấm modern)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16)
            ),
            child: Row(children: [
              Expanded(child: _typeBtn("Chi tiêu", 'expense', AppTheme.iosRed)),
              Expanded(child: _typeBtn("Thu nhập", 'income', AppTheme.iosGreen)),
            ]),
          ),
          const SizedBox(height: 25),

          // 3. Inputs (Clean Style)
          CustomTextField(label: "Tiêu đề", controller: _titleCtrl, icon: Icons.description_outlined),
          const SizedBox(height: 15),
          CustomTextField(label: "Số tiền", controller: _amountCtrl, icon: Icons.attach_money, isCurrency: true),
          
          const SizedBox(height: 15),
          
          // 4. Dropdown & Date Row
          Row(
            children: [
              // Category Dropdown
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.background, // Nền xám nhạt
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: _cat,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textGrey),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: "Danh mục",
                        labelStyle: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                        contentPadding: EdgeInsets.symmetric(vertical: 4)
                      ),
                      items: _cats.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (v) => setState(() => _cat = v.toString()),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Date Picker
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.1), // Nền màu nhạt theo loại
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: activeColor.withOpacity(0.2))
                    ),
                    child: Column(
                      children: [
                        Text("Ngày", style: TextStyle(fontSize: 10, color: activeColor)),
                        const SizedBox(height: 4),
                        Text(DateFormat('dd/MM').format(_selectedDate), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: activeColor)),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 30),

          // 5. Submit Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor, // Màu nền nút thay đổi theo loại
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: activeColor.withOpacity(0.4),
                ),
                onPressed: _save, 
                child: const Text("LƯU LẠI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Widget con: Nút chọn loại (Animated)
  Widget _typeBtn(String label, String val, Color color) {
    bool isActive = _type == val;
    return GestureDetector(
      onTap: () => setState(() => _type = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))] : []
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive) ...[
              Icon(val == 'expense' ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 16),
              const SizedBox(width: 6)
            ],
            Text(label, style: TextStyle(color: isActive ? color : AppTheme.textGrey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}