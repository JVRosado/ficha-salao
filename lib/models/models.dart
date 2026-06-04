class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String birthDate;
  final String date;
  final HealthInfo health;
  final ProcedureInfo procedures;
  final String observations;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.birthDate,
    required this.date,
    required this.health,
    required this.procedures,
    required this.observations,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'birthDate': birthDate,
        'date': date,
        'health': health.toJson(),
        'procedures': procedures.toJson(),
        'observations': observations,
      };

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        birthDate: json['birthDate'] ?? '',
        date: json['date'] ?? '',
        health: HealthInfo.fromJson(json['health'] ?? {}),
        procedures: ProcedureInfo.fromJson(json['procedures'] ?? {}),
        observations: json['observations'] ?? '',
      );
}

class HealthInfo {
  final String allergies;
  final String medications;
  final String skinConditions;

  HealthInfo({
    required this.allergies,
    required this.medications,
    required this.skinConditions,
  });

  Map<String, dynamic> toJson() => {
        'allergies': allergies,
        'medications': medications,
        'skinConditions': skinConditions,
      };

  factory HealthInfo.fromJson(Map<String, dynamic> json) => HealthInfo(
        allergies: json['allergies'] ?? '',
        medications: json['medications'] ?? '',
        skinConditions: json['skinConditions'] ?? '',
      );
}

class ProcedureInfo {
  final String hasSmoothing;
  final String smoothingType;
  final String smoothingDate;
  final String hasColoring;
  final String coloringType;
  final String coloringDate;
  final String todayDesire;
  final String hasInspirationPhoto;
  final String willingToCut;
  final String preTreatment;
  final String postTreatment;
  final String professionalAdvice;
  final String lastStrandTestDate;

  ProcedureInfo({
    this.hasSmoothing = '',
    this.smoothingType = '',
    this.smoothingDate = '',
    this.hasColoring = '',
    this.coloringType = '',
    this.coloringDate = '',
    this.todayDesire = '',
    this.hasInspirationPhoto = '',
    this.willingToCut = '',
    this.preTreatment = '',
    this.postTreatment = '',
    this.professionalAdvice = '',
    this.lastStrandTestDate = '',
  });

  Map<String, dynamic> toJson() => {
        'hasSmoothing': hasSmoothing,
        'smoothingType': smoothingType,
        'smoothingDate': smoothingDate,
        'hasColoring': hasColoring,
        'coloringType': coloringType,
        'coloringDate': coloringDate,
        'todayDesire': todayDesire,
        'hasInspirationPhoto': hasInspirationPhoto,
        'willingToCut': willingToCut,
        'preTreatment': preTreatment,
        'postTreatment': postTreatment,
        'professionalAdvice': professionalAdvice,
        'lastStrandTestDate': lastStrandTestDate,
      };

  factory ProcedureInfo.fromJson(Map<String, dynamic> json) => ProcedureInfo(
        hasSmoothing: json['hasSmoothing'] ?? '',
        smoothingType: json['smoothingType'] ?? '',
        smoothingDate: json['smoothingDate'] ?? '',
        hasColoring: json['hasColoring'] ?? '',
        coloringType: json['coloringType'] ?? '',
        coloringDate: json['coloringDate'] ?? '',
        todayDesire: json['todayDesire'] ?? '',
        hasInspirationPhoto: json['hasInspirationPhoto'] ?? '',
        willingToCut: json['willingToCut'] ?? '',
        preTreatment: json['preTreatment'] ?? '',
        postTreatment: json['postTreatment'] ?? '',
        professionalAdvice: json['professionalAdvice'] ?? '',
        lastStrandTestDate: json['lastStrandTestDate'] ?? '',
      );
}

class AppointmentModel {
  final String id;
  final String clientId;
  final String date;
  final String services;
  final String products;
  final String notes;
  final String professional;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.date,
    required this.services,
    required this.products,
    required this.notes,
    required this.professional,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'date': date,
        'services': services,
        'products': products,
        'notes': notes,
        'professional': professional,
      };

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
        id: json['id'] ?? '',
        clientId: json['clientId'] ?? '',
        date: json['date'] ?? '',
        services: json['services'] ?? '',
        products: json['products'] ?? '',
        notes: json['notes'] ?? '',
        professional: json['professional'] ?? '',
      );
}

class ClientSummary {
  final String id;
  final String name;
  final String phone;
  final String lastVisit;

  ClientSummary({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastVisit,
  });
}
