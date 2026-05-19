import 'package:flutter/material.dart';

class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final int colorValue;
  final int iconCode;
  final bool isDemo; // <-- MỚI

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.colorValue,
    required this.iconCode,
    this.isDemo = false, // <-- MỚI
  });

  factory SavingsGoalModel.fromJson(String id, Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: id,
      title: json['title'] ?? 'Mục tiêu',
      targetAmount: double.parse((json['targetAmount'] ?? 0).toString()),
      currentAmount: double.parse((json['currentAmount'] ?? 0).toString()),
      colorValue: json['colorValue'] ?? 0xFF00B894,
      iconCode: json['iconCode'] ?? Icons.savings.codePoint,
      isDemo: json['isDemo'] ?? false, // <-- MỚI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'colorValue': colorValue,
      'iconCode': iconCode,
      'isDemo': isDemo, // <-- MỚI
    };
  }
}