package com.example.catvet.service;

import com.example.catvet.entity.MedicalRecord;
import com.example.catvet.entity.Patient;
import com.example.catvet.repository.MedicalRecordRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicalRecordService {

    private static final Logger log = LoggerFactory.getLogger(MedicalRecordService.class);

    private final MedicalRecordRepository medicalRecordRepository;
    private final PatientService patientService;

    public MedicalRecordService(MedicalRecordRepository medicalRecordRepository, PatientService patientService) {
        this.medicalRecordRepository = medicalRecordRepository;
        this.patientService = patientService;
    }

    public MedicalRecord addRecord(Long patientId, MedicalRecord record){
        Patient patient = patientService.findById(patientId);
        record.setPatient(patient);
        MedicalRecord saved = medicalRecordRepository.save(record);
        log.info("Added {} record {} for patient {}", saved.getType(), saved.getId(), patientId);
        return saved;
    }

    public List<MedicalRecord> getRecords(Long patientId) {
        return medicalRecordRepository.findByPatientId(patientId);
    }
}
