import 'package:flutter/material.dart';

/// Modelo que representa un plan de suscripción
class Plan {
  final int id;
  final String title;
  final String description;
  final String price;
  final int days;
  final String type;
  final String typeDisplay;
  final bool actually;

  Plan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.days,
    required this.type,
    required this.typeDisplay,
    required this.actually,
  });

  /// Crea una instancia de Plan desde un mapa JSON
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      days: json['days'] ?? 0,
      type: json['type'] ?? '',
      typeDisplay: json['type_display']?.toString() ?? '',
      actually: json['actually'] == true,
    );
  }
}

/// Respuesta de la API con la lista de planes
class PlansResponse {
  final List<Plan> plans;
  final int total;
  final int page;
  final int pages;

  PlansResponse({
    required this.plans,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory PlansResponse.fromJson(Map<String, dynamic> json) {
    return PlansResponse(
      plans: (json['data'] as List<dynamic>?)
          ?.map((plan) => Plan.fromJson(plan as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}
