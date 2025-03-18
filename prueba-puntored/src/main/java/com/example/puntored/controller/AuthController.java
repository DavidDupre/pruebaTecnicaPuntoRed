package com.example.puntored.controller;

import com.example.puntored.service.PuntoredService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private PuntoredService puntoredService;

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody Map<String, String> credentials) {
        try {
            String token = puntoredService.autenticar(credentials.get("user"), credentials.get("password"));
            System.out.println("Token generado: " + token);
            return ResponseEntity.ok(Map.of("token", token));
        } catch (Exception e) {
            return ResponseEntity.status(401).body(Map.of("error", "Autenticación fallida"));
        }
    }
}
