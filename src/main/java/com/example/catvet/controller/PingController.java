package com.example.catvet.controller;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class PingController {

    @RequestMapping("/ping")
    String pingPong() {
        return "Pong!";
    }
}
