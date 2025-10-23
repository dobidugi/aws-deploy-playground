package com.example.asgdeploytest.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController {

    @GetMapping("/health")
    ResponseEntity<Map<String, String>> health() {
        Map<String, String> map = new HashMap<>();
        map.put("status", "UP");
        return ResponseEntity.status(HttpStatus.OK).body(map);
    }
}
