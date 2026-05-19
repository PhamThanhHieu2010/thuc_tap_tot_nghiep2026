import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'home_tab.dart';
import 'stats_tab.dart';       
import 'ai_chat_screen.dart';  
import 'settings_tab.dart';     
import 'add_transaction_modal.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key}); 
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _idx = 0;

  final List<Widget> _tabs = [
    const HomeTab(),        
    const StatsTab(),       
    const AIChatScreen(),   
    const SettingsTab(),    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Giữ giao diện trong suốt đẹp mắt
      backgroundColor: AppTheme.background, 
      
      // --- FIX QUAN TRỌNG ---
      // false: Giữ thanh điều hướng nằm im ở dưới đáy khi bàn phím hiện lên.
      // Giúp khung chat không bị thanh điều hướng che mất hoặc gây lỗi overflow.
      resizeToAvoidBottomInset: false, 

      // BODY
      body: IndexedStack(
        index: _idx,
        children: _tabs,
      ),
      
      // NÚT FAB (Floating Action Button)
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30), // Căn chỉnh vị trí nút cho khớp hõm
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4), 
              blurRadius: 15, 
              offset: const Offset(0, 5)
            )
          ], 
        ),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context, 
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddTransactionModal()
            );
          },
          backgroundColor: AppTheme.primary, // Dùng màu gốc của Theme
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // NAVBAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero, // Reset padding mặc định
          
          // --- FIX LỖI CHỮ ĐỎ (OVERFLOW) ---
          // Tăng chiều cao từ 60 lên 80 để đủ chỗ cho Icon + Text khi được chọn
          height: 80, 
          
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, "Trang chủ"),
                _navItem(1, Icons.pie_chart_rounded, "Thống kê"),
                const SizedBox(width: 40), // Khoảng trống cho FAB
                _navItem(2, Icons.smart_toy_rounded, "Trợ lý AI"),
                _navItem(3, Icons.settings_rounded, "Cài đặt"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isSelected = _idx == index;
    // Dùng màu Primary từ Theme (tránh lỗi nếu không có AppTheme.iosBlue)
    Color activeColor = AppTheme.primary; 
    
    return InkWell(
      onTap: () => setState(() => _idx = index),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected 
            ? BoxDecoration(
                color: activeColor.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(20),
              ) 
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Quan trọng: Chỉ chiếm diện tích cần thiết
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? activeColor : Colors.grey, 
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              // Flexible giúp Text không bị tràn nếu không gian quá hẹp
              Flexible( 
                child: Text(
                  label, 
                  style: TextStyle(
                    color: activeColor, 
                    fontSize: 11, // Giảm font size một chút cho gọn
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}