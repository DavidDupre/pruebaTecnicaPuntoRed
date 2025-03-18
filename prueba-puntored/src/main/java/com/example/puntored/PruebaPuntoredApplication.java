package com.example.puntored;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class PruebaPuntoredApplication {

    public static void main(String[] args) {
        SpringApplication.run(PruebaPuntoredApplication.class, args);
    }
}