import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final int iconCode;    // Lưu mã icon (VD: 58345) thay vì object IconData
  final int colorValue;  // Lưu mã màu (VD: 0xFF2196F3) thay vì object Color
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.iconCode,
    required this.colorValue,
    this.isRead = false,
  });

  // Getter tiện ích: Chuyển đổi ngược từ số sang Icon/Color để dùng trên UI
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // Chuyển từ JSON (Server) về Model
  factory NotificationModel.fromJson(String id, Map<String, dynamic> json) {
    return NotificationModel(
      id: id,
      title: json['title'] ?? 'Thông báo',
      body: json['body'] ?? '',
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      iconCode: json['iconCode'] ?? Icons.notifications.codePoint,
      colorValue: json['colorValue'] ?? 0xFF2196F3, // Mặc định màu xanh Blue
      isRead: json['isRead'] ?? false,
    );
  }

  // Chuyển từ Model sang JSON (Server)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'time': time.toIso8601String(),
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isRead': isRead,
    };
  }
}