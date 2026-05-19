import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // Thư viện OCR

class OCRScanScreen extends StatefulWidget {
  const OCRScanScreen({super.key});

  @override
  State<OCRScanScreen> createState() => _OCRScanScreenState();
}

class _OCRScanScreenState extends State<OCRScanScreen> {
  File? _imageFile;
  bool _isScanning = false;
  String _scannedText = "";
  final ImagePicker _picker = ImagePicker();
  
  // Khởi tạo bộ nhận diện văn bản (Script Latin hỗ trợ Tiếng Việt/Anh)
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void dispose() {
    // Quan trọng: Giải phóng bộ nhớ ML Kit khi thoát màn hình
    _textRecognizer.close();
    super.dispose();
  }

  // Xử lý chọn ảnh và quét
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _imageFile = File(pickedFile.path);
        _isScanning = true;
        _scannedText = "Đang phân tích...";
      });

      // --- BẮT ĐẦU QUÉT OCR ---
      final inputImage = InputImage.fromFile(_imageFile!);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      
      // Logic nhỏ: Tìm thử các con số có thể là tổng tiền (VD: chứa chữ 'đ', 'VND' hoặc số lớn)
      // Đây chỉ là logic cơ bản, bạn có thể dùng AI Gemini để phân tích kỹ hơn sau này
      String detectedAmount = _extractPotentialAmount(rawText);

      setState(() {
        _isScanning = false;
        if (rawText.isEmpty) {
          _scannedText = "Không tìm thấy chữ nào trong ảnh.";
        } else {
          _scannedText = "KẾT QUẢ PHÂN TÍCH:\n$detectedAmount\n\n--- NỘI DUNG GỐC ---\n$rawText";
        }
      });

    } catch (e) {
      setState(() {
        _isScanning = false;
        _scannedText = "Lỗi quét ảnh: $e";
      });
    }
  }

  // Hàm phụ: Cố gắng tìm số tiền trong văn bản (Logic đơn giản)
  String _extractPotentialAmount(String text) {
    // Tìm các dòng có chứa số và các từ khóa tiền tệ
    final lines = text.split('\n');
    String found = "";
    for (var line in lines) {
      if (line.toLowerCase().contains('tong') || 
          line.toLowerCase().contains('total') || 
          line.contains('đ') || 
          line.contains('VND')) {
         found += "$line\n";
      }
    }
    return found.isNotEmpty ? "Có thể là tổng tiền:\n$found" : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Quét Hóa Đơn (OCR)", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Vùng hiển thị ảnh
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: _imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("Chụp hoặc chọn ảnh hóa đơn", style: GoogleFonts.outfit(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Image.file(_imageFile!, fit: BoxFit.contain),
                    ),
            ),
          ),

          // 2. Vùng hiển thị kết quả text
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kết quả quét:", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                      if (_isScanning) 
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText( // Cho phép user copy text
                        _scannedText.isEmpty ? "Chưa có dữ liệu." : _scannedText,
                        style: GoogleFonts.roboto(fontSize: 15, color: Colors.black87, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Thanh nút bấm dưới cùng
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text("Thư viện"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                    label: const Text("Chụp ảnh", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2575FC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}