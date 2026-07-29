package com.example.catvet.service;

import java.time.LocalDate;

import com.example.catvet.entity.MedicalRecord;
import com.example.catvet.entity.Patient;
import com.example.catvet.entity.VisitType;
import com.example.catvet.exception.PatientNotFoundException;
import com.example.catvet.repository.MedicalRecordRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MedicalRecordServiceTest {

    @Mock
    MedicalRecordRepository medicalRecordRepository;   // fake DB access

    @Mock
    PatientService patientService;                     // fake collaborator

    @InjectMocks
    MedicalRecordService service;                      // real service under test

    @Test
    void addRecord_attachesPatientAndSaves() {
        // Arrange
        Patient ryszard = new Patient("Ryszard Łobuz", "cat");
        when(patientService.findById(1L)).thenReturn(ryszard);
        MedicalRecord record = new MedicalRecord(
                LocalDate.of(2026, 7, 29), VisitType.NEW_EVENT, "checkup", null);
        when(medicalRecordRepository.save(record)).thenReturn(record);

        // Act
        MedicalRecord saved = service.addRecord(1L, record);

        // Assert: the service looked the patient up and attached it before saving
        assertThat(saved.getPatient()).isEqualTo(ryszard);
        verify(medicalRecordRepository).save(record);
    }

    @Test
    void addRecord_unknownPatient_throwsAndSavesNothing() {
        // Arrange: the patient lookup fails
        when(patientService.findById(999L)).thenThrow(new PatientNotFoundException(999L));
        MedicalRecord record = new MedicalRecord(
                LocalDate.of(2026, 7, 29), VisitType.NEW_EVENT, "checkup", null);

        // Act + Assert: the exception propagates...
        assertThatThrownBy(() -> service.addRecord(999L, record))
                .isInstanceOf(PatientNotFoundException.class);

        // ...and crucially, nothing was written to the database
        verify(medicalRecordRepository, never()).save(any());
    }
}
