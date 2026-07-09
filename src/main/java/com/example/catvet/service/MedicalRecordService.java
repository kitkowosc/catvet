package com.example.catvet.service;

import com.example.catvet.entity.MedicalRecord;
import com.example.catvet.entity.Patient;
import com.example.catvet.repository.MedicalRecordRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicalRecordService {
    private final MedicalRecordRepository medicalRecordRepository;
    private final PatientService patientService;

    public MedicalRecordService(MedicalRecordRepository medicalRecordRepository, PatientService patientService) {
        this.medicalRecordRepository = medicalRecordRepository;
        this.patientService = patientService;
    }

    public MedicalRecord addRecord(Long patientId, MedicalRecord record){
        Patient patient = patientService.findById(patientId);
        record.setPatient(patient);
        return medicalRecordRepository.save(record);
    }

    public List<MedicalRecord> getRecords(Long patientId) {
        return medicalRecordRepository.findByPatientId(patientId);
    }
}
