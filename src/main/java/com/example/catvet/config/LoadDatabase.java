package com.example.catvet.config;

import com.example.catvet.entity.Patient;
import com.example.catvet.repository.PatientRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LoadDatabase {
    private static final Logger log = LoggerFactory.getLogger(LoadDatabase.class);

    @Bean
    CommandLineRunner initDatabase(PatientRepository repository) {
        return args -> {
            log.info("Preloading {}", repository.save(new Patient("Ryszard Łobuz", "cat")));
            log.info("Preloading {}", repository.save(new Patient("Nelka Kitkoska", "kotka")));
        };

    }
}