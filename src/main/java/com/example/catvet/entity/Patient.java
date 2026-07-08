package com.example.catvet.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotBlank;


import java.util.Objects;

@Entity
public class Patient {
    @Id
    @GeneratedValue Long id;
    @NotBlank
    private String name;
    @NotBlank
    private String breed;

    protected Patient() {
    }
    public Patient(String name, String breed) {
        this.name = name;
        this.breed = breed;
    }

    public Long getId() {
        return this.id;

    }

    public String getName() {
        return this.name;
    }

    public String getBreed() {
        return this.breed;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setBreed(String breed) {
        this.breed = breed;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof Patient))
                return false;
        Patient patient = (Patient) o;
        return Objects.equals(this.id, patient.id) && Objects.equals(this.name, patient.name)
                    && Objects.equals(this.breed, patient.breed);
        }

        @Override
        public int hashCode() {
            return Objects.hash(this.id, this.name, this.breed);
        }

        @Override
        public String toString() {
            return "Patient{" + "id=" + this.id + ", name='" + this.name + '\'' + ", breed='" + this.breed + '\'' + '}';
        }
}
