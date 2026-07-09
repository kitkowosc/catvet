package com.example.catvet.controller;

import com.example.catvet.entity.MedicalRecord;
import com.example.catvet.service.MedicalRecordService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

        import java.util.List;

@RestController
class MedicalRecordController {

    private final MedicalRecordService service;

    MedicalRecordController(MedicalRecordService service) {
        this.service = service;
    }

    @GetMapping("/patients/{id}/records")
    List<MedicalRecord> all(@PathVariable Long id) {
        return service.getRecords(id);
    }

    @PostMapping("/patients/{id}/records")
    @ResponseStatus(HttpStatus.CREATED)
    MedicalRecord newRecord(@PathVariable Long id, @RequestBody MedicalRecord record) {
        return service.addRecord(id, record);
    }
}