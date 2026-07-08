package com.example.catvet.entity;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
public class MedicalRecord {

    private @Id
    @GeneratedValue Long id;
    private LocalDate date;

    @Enumerated(EnumType.STRING)
    private VisitType type;
    private String notes;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private Patient patient;

    MedicalRecord() {
    }

    public MedicalRecord(LocalDate date, VisitType type, String notes, Patient patient) {
        this.date = date;
        this.type = type;
        this.notes = notes;
        this.patient = patient;
    }

    public Long getId() {
        return this.id;
    }

    public LocalDate getDate() {
        return this.date;
    }

    public VisitType getType() {
        return this.type;
    }

    public String getNotes() {
        return this.notes;
    }

    public Patient getPatient() {
        return this.patient;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public void setType(VisitType type) {
        this.type = type;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }
}
