package com.example.asgdeploytest.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class TestController {

    @GetMapping("/test")
    ResponseEntity<Map<String, String>> test() {
        Map<String, String> map = new HashMap<>();
        map.put("version", "1");
        map.put("status:", "up");

        return ResponseEntity.status(HttpStatus.OK).body(map);

    }
}
