import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../config/theme.dart';

class QRGenScreen extends StatelessWidget {
  const QRGenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // String VietQR giả lập
    const String qrData = "00020101021138570010A00000072701270006970423011319036838389990208QRIBFTTA53037045802VN6304D81C";

    return Scaffold(
      backgroundColor: AppTheme.background, // Nền xám sáng chuẩn iOS
      appBar: AppBar(
        title: const Text("Nhận tiền", style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark), // Icon màu tối
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- MAIN QR CARD ---
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), 
                      blurRadius: 30, 
                      offset: const Offset(0, 15)
                    )
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Bank Header Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text("MB", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("MB Bank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Ngân hàng Quân Đội", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        )
                      ],
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // 2. QR Code
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 220.0,
                        // Tùy chỉnh mắt QR cho đẹp hơn (nếu thư viện hỗ trợ bản mới, nếu không nó sẽ ignore)
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.black),
                        backgroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 25),
                    
                    // 3. Info
                    const Text("HO TIEN BAO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: const Text(
                        "9999 9999 1311 04", 
                        style: TextStyle(
                          fontSize: 18, 
                          color: AppTheme.iosBlue, 
                          letterSpacing: 1.2, 
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier' // Font đơn cách giống thẻ ngân hàng
                        )
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Quét mã để chuyển tiền tự động", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- ACTION BUTTONS (Giả lập) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(Icons.share_rounded, "Chia sẻ"),
                  _actionButton(Icons.download_rounded, "Lưu ảnh"),
                  _actionButton(Icons.copy_rounded, "Sao chép"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppTheme.softShadow,
          ),
          child: Icon(icon, color: AppTheme.textDark, size: 22),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w500))
      ],
    );
  }
}