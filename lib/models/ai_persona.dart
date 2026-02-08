import 'package:flutter/material.dart';

class AiPersona {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String systemInstruction;
  final bool isCustom;

  AiPersona({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.systemInstruction,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'systemInstruction': systemInstruction,
      'isCustom': isCustom,
    };
  }

  factory AiPersona.fromJson(Map<String, dynamic> json) {
    return AiPersona(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue']),
      systemInstruction: json['systemInstruction'],
      isCustom: json['isCustom'] ?? false,
    );
  }
}
