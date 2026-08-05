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
/*
!!!!!!!
💡 PROTIP — nazwy testów:
metoda_coRobi_wJakichWarunkach
findById_returnsPatient_whenItExists() :)))
 */
@ExtendWith(MockitoExtension.class)
class PatientServiceTest {

    @Mock
    PatientRepository repository;     // a fake repository, no real database
    //Nie startuje H2
    //Nie łączy się z postgresem
    //Nie leci żaden SQL
    //nie startuje nawet spring

    @InjectMocks
    PatientService service;// the real service, with the mock injected

    //Izolacja winy, jak test padnie, to wiadomo na czym i z jakiego serwisu
    //I nie dot. bazy, bo baza nie brała w tym udziału



    @Test
    void findById_returnsPatient_whenItExists() {
        // Arrange: tell the mock what to return, scena, co ma zwrócić mock
        Patient ryszard = new Patient("Ryszard Łobuz", "cat");
        when(repository.findById(1L)).thenReturn(Optional.of(ryszard));

        /*
        when(repository.findById(1L)).thenReturn(Optional.of(ryszard))
        czyta się jak zdanie: „kiedy ktoś zawoła findById(1L) na mocku
        to zwróć Optional z Ryszardem". To się nazywa stubbing — programowanie atrapy
         */


        // Act - wykonaj to co testujesz - czyli prawdziwą metodę serwisu
        Patient found = service.findById(1L);

        // Assert - sprawdź wynik - jeśli się nie zgadza, to test jest czerwony
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
