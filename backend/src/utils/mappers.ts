export function clientRowToJson(row: any) {
  return {
    id: row.id,
    name: row.name,
    phone: row.phone,
    email: row.email,
    birthDate: row.birth_date,
    date: row.date,
    health: {
      allergies: row.health_allergies,
      medications: row.health_medications,
      skinConditions: row.health_skin_conditions,
    },
    procedures: {
      hasSmoothing: row.proc_has_smoothing,
      smoothingType: row.proc_smoothing_type,
      smoothingDate: row.proc_smoothing_date,
      hasColoring: row.proc_has_coloring,
      coloringType: row.proc_coloring_type,
      coloringDate: row.proc_coloring_date,
      todayDesire: row.proc_today_desire,
      hasInspirationPhoto: row.proc_has_inspiration_photo,
      willingToCut: row.proc_willing_to_cut,
      preTreatment: row.proc_pre_treatment,
      postTreatment: row.proc_post_treatment,
      professionalAdvice: row.proc_professional_advice,
      lastStrandTestDate: row.proc_last_strand_test_date,
    },
    observations: row.observations,
  };
}

export function clientSummaryRowToJson(row: any) {
  return {
    id: row.id,
    name: row.name,
    phone: row.phone,
    lastVisit: row.date,
  };
}

export function appointmentRowToJson(row: any) {
  return {
    id: row.id,
    clientId: row.client_id,
    date: row.date,
    services: row.services,
    products: row.products,
    notes: row.notes,
    professional: row.professional,
  };
}
