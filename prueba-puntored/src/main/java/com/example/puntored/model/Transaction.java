package com.example.puntored.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "El número no puede ser nulo")
    @Size(min = 10, max = 15, message = "El número debe tener entre 10 y 15 caracteres")
    @Pattern(regexp = "^[0-9]+$", message = "El número solo puede contener dígitos")
    private String numero;

    @NotNull(message = "El valor no puede ser nulo")
    @Positive(message = "El valor debe ser mayor a 0")
    private double valor;

    private LocalDateTime fecha;

    @ManyToOne
    @JoinColumn(name = "proveedor_id")
    @NotNull(message = "El proveedor no puede ser nulo")
    private Proveedor proveedor;

    private String estado;

    @Column(name = "fecha_eliminacion")
    private LocalDate fechaEliminacion;

    // Getters y Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public double getValor() {
        return valor;
    }

    public void setValor(double valor) {
        this.valor = valor;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public Proveedor getProveedor() {
        return proveedor;
    }

    public void setProveedor(Proveedor proveedor) {
        this.proveedor = proveedor;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public LocalDate getFechaEliminacion() { 
        return fechaEliminacion; 
    }

    public void setFechaEliminacion(LocalDate fechaEliminacion) { 
        this.fechaEliminacion = fechaEliminacion; 
    }
}