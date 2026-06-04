import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

class StorageService {
  static Future<void> saveClient(ClientModel client) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('client_${client.id}', jsonEncode(client.toJson()));

    // Update client list
    final list = await getClientSummaries();
    final idx = list.indexWhere((c) => c.id == client.id);
    final summary = ClientSummary(
      id: client.id,
      name: client.name,
      phone: client.phone,
      lastVisit: client.date,
    );
    if (idx >= 0) {
      list[idx] = summary;
    } else {
      list.add(summary);
    }
    final summaryList = list
        .map((c) => {'id': c.id, 'name': c.name, 'phone': c.phone, 'lastVisit': c.lastVisit})
        .toList();
    await prefs.setString('client_list', jsonEncode(summaryList));
  }

  static Future<ClientModel?> getClient(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('client_$id');
    if (data == null) return null;
    return ClientModel.fromJson(jsonDecode(data));
  }

  static Future<List<ClientSummary>> getClientSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('client_list');
    if (data == null) return _mockClients();
    final list = jsonDecode(data) as List;
    return list
        .map((c) => ClientSummary(
              id: c['id'],
              name: c['name'],
              phone: c['phone'],
              lastVisit: c['lastVisit'],
            ))
        .toList();
  }

  static List<ClientSummary> _mockClients() => [
        ClientSummary(id: '1', name: 'Maria Silva', phone: '(11) 98765-4321', lastVisit: '2026-03-25'),
        ClientSummary(id: '2', name: 'Ana Costa', phone: '(11) 97654-3210', lastVisit: '2026-03-20'),
        ClientSummary(id: '3', name: 'Juliana Santos', phone: '(11) 96543-2109', lastVisit: '2026-03-15'),
        ClientSummary(id: '4', name: 'Carla Oliveira', phone: '(11) 95432-1098', lastVisit: '2026-03-10'),
        ClientSummary(id: '5', name: 'Fernanda Lima', phone: '(11) 94321-0987', lastVisit: '2026-03-05'),
      ];

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
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('appointments_$clientId');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((a) => AppointmentModel.fromJson(a)).toList();
  }

  static Future<void> saveAppointment(String clientId, AppointmentModel appointment) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAppointments(clientId);
    final idx = list.indexWhere((a) => a.id == appointment.id);
    if (idx >= 0) {
      list[idx] = appointment;
    } else {
      list.add(appointment);
    }
    await prefs.setString('appointments_$clientId', jsonEncode(list.map((a) => a.toJson()).toList()));
  }

  static Future<void> deleteAppointment(String clientId, String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAppointments(clientId);
    list.removeWhere((a) => a.id == appointmentId);
    await prefs.setString('appointments_$clientId', jsonEncode(list.map((a) => a.toJson()).toList()));
  }

  static String generateId() => _uuid.v4().substring(0, 8);
}
