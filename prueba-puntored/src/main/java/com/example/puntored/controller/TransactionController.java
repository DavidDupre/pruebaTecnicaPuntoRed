package com.example.puntored.controller;

import com.example.puntored.model.Proveedor;
import com.example.puntored.model.Transaction;
import com.example.puntored.repository.ProveedorRepository;
import com.example.puntored.repository.TransactionRepository;
import com.example.puntored.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/transacciones")
public class TransactionController {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private ProveedorRepository proveedorRepository;

    @Autowired
    private TransactionService transactionService;

    @PostMapping("/buy")
    public Transaction comprarRecarga(@RequestBody Map<String, Object> requestBody) {
        Transaction transaccion = transactionService.crearTransaccion(requestBody);
        return transaccion;
    }

    @GetMapping("/listar")
    public ResponseEntity<List<Transaction>> obtenerUsuarios() {
        List<Transaction> transaccion = transactionRepository.findByFechaEliminacionIsNull();
        return ResponseEntity.ok(transaccion);
    }

    @GetMapping("/{id}")
    public Transaction obtenerTransaccionPorId(@PathVariable Long id) {
        return transactionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transacción no encontrada"));
    }

    @PutMapping("/editar/{id}")
    public Transaction actualizarTransaccion(
            @PathVariable Long id,
            @RequestBody Map<String, Object> requestBody
    ) {
        Transaction transaccion = transactionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transacción no encontrada"));

        if (requestBody.containsKey("valor")) {
            transaccion.setValor(Double.valueOf(requestBody.get("valor").toString()));
        }
        if (requestBody.containsKey("numero")) {
            transaccion.setNumero(requestBody.get("numero").toString());
        }
        if (requestBody.containsKey("proveedorId")) {
            String proveedorId = requestBody.get("proveedorId").toString();
            Proveedor proveedor = proveedorRepository.findById(proveedorId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Proveedor no encontrado"));
            transaccion.setProveedor(proveedor);
        }

        return transactionRepository.save(transaccion);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Transaction> eliminarUsuario(@PathVariable Long id) {
        Transaction transaccion = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        transaccion.setFechaEliminacion(LocalDate.now());
        transactionRepository.save(transaccion);
        return ResponseEntity.ok(transaccion);
    }

    @GetMapping("/getSuppliers")
    public List<Proveedor> getSuppliers() {
        return proveedorRepository.findAll();
    }
    
    @GetMapping("/estado/{id}")
    public String obtenerEstadoTransaccion(@PathVariable Long id) {
        Transaction transaccion = transactionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transacción no encontrada"));
        return transaccion.getEstado();
    }
}