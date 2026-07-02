import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'api_client.dart';

const _uuid = Uuid();

class StorageService {
  static Future<void> saveClient(ClientModel client) async {
    await ApiClient.post('/clients', client.toJson());
  }

  static Future<void> updateClient(ClientModel client) async {
    await ApiClient.put('/clients/${client.id}', client.toJson());
  }

  static Future<ClientModel?> getClient(String id) async {
    try {
      final json = await ApiClient.get('/clients/$id');
      return ClientModel.fromJson(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<List<ClientSummary>> getClientSummaries() async {
    final list = await ApiClient.get('/clients') as List;
    return list
        .map((c) => ClientSummary(
              id: c['id'],
              name: c['name'],
              phone: c['phone'],
              lastVisit: c['lastVisit'],
            ))
        .toList();
  }

  static ClientModel getMockClient(String id) => ClientModel(
        id: id,
        name: 'Maria Silva',
        phone: '(11) 98765-4321',
        email: 'maria.silva@email.com',
        birthDate: '1985-05-15',
        date: '2026-03-25',
        health: HealthInfo(
          allergies: 'Nenhuma alergia conhecida',
          medications: 'Não faz uso de medicamentos contínuos',
          skinConditions: 'Pele sensível',
        ),
        procedures: ProcedureInfo(
          hasSmoothing: 'Sim',
          smoothingType: 'Progressiva sem formol',
          smoothingDate: 'Há 3 meses',
          hasColoring: 'Sim',
          coloringType: 'Castanho',
          coloringDate: 'Há 1 mês',
          todayDesire: 'Gostaria de fazer uma hidratação profunda e cortar as pontas',
          hasInspirationPhoto: 'Não',
          willingToCut: 'Sim',
          preTreatment: 'Sim',
          postTreatment: 'Sim',
          professionalAdvice: 'Sim',
        ),
        observations:
            'Cliente prefere produtos veganos. Sensibilidade a fragrâncias fortes. Solicita corte de pontas a cada visita.',
      );

  // Appointments
  static Future<List<AppointmentModel>> getAppointments(String clientId) async {
    final list = await ApiClient.get('/clients/$clientId/appointments') as List;
    return list.map((a) => AppointmentModel.fromJson(a)).toList();
  }

  static Future<void> saveAppointment(String clientId, AppointmentModel appointment) async {
    final body = appointment.toJson();
    try {
      // O id só existe no backend se este atendimento já foi criado antes.
      await ApiClient.put('/clients/$clientId/appointments/${appointment.id}', body);
    } on ApiException catch (e) {
      if (e.statusCode != 404) rethrow;
      await ApiClient.post('/clients/$clientId/appointments', body);
    }
  }

  static Future<void> deleteAppointment(String clientId, String appointmentId) async {
    await ApiClient.delete('/clients/$clientId/appointments/$appointmentId');
  }

  static String generateId() => _uuid.v4().substring(0, 8);
}
