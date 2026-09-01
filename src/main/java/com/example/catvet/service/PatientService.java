package com.example.catvet.service;

import java.util.List;

import com.example.catvet.entity.Patient;
import com.example.catvet.exception.PatientNotFoundException;
import com.example.catvet.repository.PatientRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class PatientService {

    private static final Logger log = LoggerFactory.getLogger(PatientService.class);

    private final PatientRepository repository;

    public PatientService(PatientRepository repository) {
        this.repository = repository;
    }

    public List<Patient> findAll() {
        return repository.findAll();
    }

    public Patient findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new PatientNotFoundException(id));
    }

    public Patient create(Patient patient) {
        Patient saved = repository.save(patient);
        log.info("Registered patient {} ({})", saved.getId(), saved.getName());
        return saved;
    }

    public Patient replace(Long id, Patient newPatient) {
        return repository.findById(id)
                .map(patient -> {
                    patient.setName(newPatient.getName());
                    patient.setBreed(newPatient.getBreed());
                    return repository.save(patient);
                })
                .orElseGet(() -> repository.save(newPatient));
    }

    public void delete(Long id) {
        repository.deleteById(id);
        log.info("Deleted patient {}", id);
    }
}
