package com.example.puntored.service;

import com.example.puntored.model.Proveedor;
import com.example.puntored.model.Transaction;
import com.example.puntored.repository.ProveedorRepository;
import com.example.puntored.repository.TransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import jakarta.validation.Valid;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Random;

@Service
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private ProveedorRepository proveedorRepository;

    public Transaction crearTransaccion(@Valid Map<String, Object> requestBody) {
        String proveedorId = (String) requestBody.get("proveedorId");
        String numero = (String) requestBody.get("numero");
        
        if (numero == null || !numero.matches("\\d{10,15}")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El número debe contener entre 10 y 15 dígitos y solo números.");
        }
        
        double valor;
        try {
            valor = Double.parseDouble(requestBody.get("valor").toString());
            if (valor <= 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El valor debe ser mayor a 0.");
            }
        } catch (NumberFormatException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El valor debe ser un número válido.");
        }

        // Buscar proveedor
        Proveedor proveedor = proveedorRepository.findById(proveedorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Proveedor no encontrado"));

        // Crear transacción
        Transaction transaccion = new Transaction();
        transaccion.setFecha(LocalDateTime.now());
        transaccion.setValor(valor);
        transaccion.setNumero(numero);
        transaccion.setProveedor(proveedor);
        transaccion.setEstado("Pendiente");

        Transaction savedTransaction = transactionRepository.save(transaccion);

        actualizarEstadoTransaccion(savedTransaction.getId());

        return savedTransaction;
    }
    
    public ResponseEntity<String> deleteUsuario(Long id) {
        if (transactionRepository.existsById(id)) {
        	Transaction transaccion = transactionRepository.findById(id).get();
        	transaccion.setFechaEliminacion(LocalDate.now());
            transactionRepository.save(transaccion);
            return ResponseEntity.ok("Usuario marcado como eliminado con éxito.");
        }
        return ResponseEntity.notFound().build();
    }


    public void actualizarEstadoTransaccion(Long id) {
        Transaction transaccion = transactionRepository.findById(id).orElse(null);

        if (transaccion == null) {
            return;
        }

        boolean consultaExitosa = new Random().nextBoolean();

        if (consultaExitosa) {
            transaccion.setEstado("Exitoso");
        } else {
            transaccion.setEstado("Rechazado");
        }

        transactionRepository.save(transaccion);
    }
}
