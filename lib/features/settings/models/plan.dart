import 'package:flutter/material.dart';

/// Modelo para los detalles de un plan
class PlanDetails {
  final int id;
  final String title;
  final String description;
  final String price;
  final int? days;
  final String? type;
  final String? typeDisplay;
  final bool? actually;

  PlanDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.days,
    this.type,
    this.typeDisplay,
    this.actually,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      days: json['days'],
      type: json['type'],
      typeDisplay: json['type_display']?.toString(),
      actually: json['actually'],
    );
  }
}

/// Modelo que representa un plan de suscripción actual del usuario
class Plan {
  final String id;  // Cambiado a String para soportar UUIDs
  final int? plan;  // Opcional ya que puede no venir
  final PlanDetails? plan_details;
  final String? status;
  final String? statusDisplay;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final bool? cancelAtPeriodEnd;
  final bool? isActive;
  final int? daysRemaining;
  final bool? isExpired;

  Plan({
    required this.id,
    this.plan,
    this.plan_details,
    this.status,
    this.statusDisplay,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd,
    this.isActive,
    this.daysRemaining,
    this.isExpired,
  });
  
  // Getters para acceder fácilmente a los datos de plan_details
  String get title => plan_details?.title ?? 'Plan Desconocido';
  String get description => plan_details?.description ?? '';
  String get price => plan_details?.price ?? '0.00';
  int get days => plan_details?.days ?? 30;
  String get type => plan_details?.type ?? 'Free';
  String get typeDisplay => plan_details?.typeDisplay ?? 'Free';
  bool get actually => plan_details?.actually ?? false;

  /// Crea una instancia de Plan desde un mapa JSON
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id']?.toString() ?? '',  // Convertir a String
      plan: json['plan'],
      plan_details: json['plan_details'] != null 
          ? PlanDetails.fromJson(json['plan_details']) 
          : null,
      status: json['status'],
      statusDisplay: json['status_display'],
      currentPeriodStart: json['current_period_start'],
      currentPeriodEnd: json['current_period_end'],
      cancelAtPeriodEnd: json['cancel_at_period_end'],
      isActive: json['is_active'],
      daysRemaining: json['days_remaining'],
      isExpired: json['is_expired'],
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
