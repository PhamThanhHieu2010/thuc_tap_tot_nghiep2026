import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart'; // 1. Import AuthProvider để dịch

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Lấy AuthProvider để dùng hàm dịch t()
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);
    
    // Lấy danh sách thông báo từ AppProvider (đã được tải từ Server)
    final notifs = app.notifications; 

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        // Dịch tiêu đề
        title: Text(
          auth.t("Thông báo"), 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textDark)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textDark),
      ),
      body: notifs.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text(
                  auth.t("Chưa có thông báo nào"), // Dịch text rỗng
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16)
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifs.length,
            itemBuilder: (ctx, i) {
              final item = notifs[i];
              
              // Format thời gian: Ngày/Tháng Giờ:Phút (VD: 25/12 14:30)
              String timeDisplay = DateFormat('dd/MM HH:mm').format(item.time);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(20), 
                  boxShadow: AppTheme.softShadow // Dùng shadow chuẩn của Theme
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1), // Nền nhạt theo màu icon
                      shape: BoxShape.circle
                    ),
                    // item.icon và item.color lấy từ getter trong Model
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  title: Text(
                    item.title, 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      item.body, 
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600], height: 1.4)
                    ),
                  ),
                  trailing: Text(
                    timeDisplay, 
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500)
                  ),
                ),
              );
            },
          ),
    );
  }
}