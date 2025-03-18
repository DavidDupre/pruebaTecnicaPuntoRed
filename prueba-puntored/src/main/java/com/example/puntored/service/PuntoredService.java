package com.example.puntored.service;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class PuntoredService {

    private static final String API_URL = "https://us-central1-puntored-dev.cloudfunctions.net/technicalTest-developer/api";
    private static final String API_KEY = "mtrQF6Q11eosqyQnkMY0JGFbGqcxVg5icvfVnX1ifIyWDvwGApJ8WUM8nHVrdSkN";

    private static final Map<String, String> tokenCache = new ConcurrentHashMap<>();

    public String autenticar(String user, String password) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.set("x-api-key", API_KEY);
        headers.setContentType(MediaType.APPLICATION_JSON);

        String requestBody = String.format("{\"user\": \"%s\", \"password\": \"%s\"}", user, password);
        HttpEntity<String> request = new HttpEntity<>(requestBody, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            API_URL + "/auth",
            HttpMethod.POST,
            request,
            Map.class
        );

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            String token = "Bearer e8797850-95bb-4ca1-ac52-c99dd3c3cbad";

            tokenCache.put(user, token);

            return token;
        } else {
            throw new RuntimeException("Error al autenticar: " + response.getStatusCode());
        }
    }

    public String realizarRecarga(String user, String proveedorId, String numero, double valor) {
        RestTemplate restTemplate = new RestTemplate();

        String token = tokenCache.get(user);
        if (token == null) {
            throw new RuntimeException("Usuario no autenticado o token expirado.");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        String requestBody = String.format(
            "{\"proveedorId\": \"%s\", \"numero\": \"%s\", \"valor\": %.2f}",
            proveedorId, numero, valor
        );

        HttpEntity<String> request = new HttpEntity<>(requestBody, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            API_URL + "/buy",
            HttpMethod.POST,
            request,
            Map.class
        );

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            return response.getBody().toString();
        } else {
            throw new RuntimeException("Error al realizar la recarga: " + response.getStatusCode());
        }
    }
}
