package com.example.catvet.service;

import java.util.Optional;

import com.example.catvet.entity.Patient;
import com.example.catvet.exception.PatientNotFoundException;
import com.example.catvet.repository.PatientRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PatientServiceTest {

    @Mock
    PatientRepository repository;     // a fake repository, no real database

    @InjectMocks
    PatientService service;           // the real service, with the mock injected

    @Test
    void findById_returnsPatient_whenItExists() {
        // Arrange: tell the mock what to return
        Patient ryszard = new Patient("Ryszard Łobuz", "cat");
        when(repository.findById(1L)).thenReturn(Optional.of(ryszard));

        // Act
        Patient found = service.findById(1L);

        // Assert
        assertThat(found.getName()).isEqualTo("Ryszard Łobuz");
    }

    @Test
    void findById_throwsNotFound_whenMissing() {
        // Arrange: the mock returns "nothing found"
        when(repository.findById(999L)).thenReturn(Optional.empty());

        // Act + Assert: the service must translate that into a 404-mapped exception
        assertThatThrownBy(() -> service.findById(999L))
                .isInstanceOf(PatientNotFoundException.class);
    }
}
