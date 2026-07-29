package com.example.catvet.controller;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest              // starts the whole application context...
@AutoConfigureMockMvc        // ...and gives us a MockMvc to call real endpoints
class PatientControllerIntegrationTest {

    @Autowired
    MockMvc mockMvc;         // sends fake HTTP requests through the real controller->service->repo->H2

    @Test
    void postThenGet_roundTripsPatientThroughTheDatabase() throws Exception {
        // POST a new patient and capture the generated id from the response body
        String response = mockMvc.perform(post("/patients")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Mruczek\",\"breed\":\"pers\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name", is("Mruczek")))
                .andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(response, "$.id");   // pull the id back out

        // GET it back by that id — proves it was really stored and can be read
        mockMvc.perform(get("/patients/" + id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name", is("Mruczek")))
                .andExpect(jsonPath("$.breed", is("pers")));
    }

    @Test
    void getUnknownId_returns404() throws Exception {
        mockMvc.perform(get("/patients/999999"))
                .andExpect(status().isNotFound());
    }
}
