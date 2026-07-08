package com.example.catvet.controller;

import java.util.List;

import com.example.catvet.entity.Patient;
import com.example.catvet.service.PatientService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.hateoas.EntityModel;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;
import jakarta.validation.Valid;

@RestController
class PatientController {

    private final PatientService service;

    PatientController(PatientService service) {
        this.service = service;
    }

    @GetMapping("/patients")
    List<Patient> all() {
        return service.findAll();
    }

    @PostMapping("/patients")
    @ResponseStatus(HttpStatus.CREATED)
    Patient newPatient(@Valid @RequestBody Patient newPatient) {
        return service.create(newPatient);
    }

    @GetMapping("/patients/{id}")
    EntityModel<Patient> one(@PathVariable Long id) {
        Patient patient = service.findById(id);
        return EntityModel.of(patient,
                linkTo(methodOn(PatientController.class).one(id)).withSelfRel(),
                linkTo(methodOn(PatientController.class).all()).withRel("patients"));
    }

    @PutMapping("/patients/{id}")
    Patient replacePatient(@RequestBody Patient newPatient, @PathVariable Long id) {
        return service.replace(id, newPatient);
    }

    @DeleteMapping("/patients/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void deletePatient(@PathVariable Long id) {
        service.delete(id);
    }
}