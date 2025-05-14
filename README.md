# PRUEBA TÉCNICA – DESARROLLADOR FLUTTER

## Descripción del Proyecto

Este proyecto es una aplicación móvil desarrollada en Flutter que permite realizar recargas móviles, consultar proveedores y almacenar información de transacciones. La aplicación consume la API de Puntored y se puede ampliar con un backend desarrollado en Spring Boot.

## Tecnologías Utilizadas

- **Frontend:** [Flutter](https://flutter.dev/) (versión 3.29.2)
- **Backend (Opcional):** [Spring Boot](https://spring.io/projects/spring-boot) con [Java](https://www.java.com/)
- **Base de Datos:** [MySQL](https://www.mysql.com/)
- **Manejador de estado:** [Riverpod](https://riverpod.dev/) (Nivel 3 obligatorio)

## Funcionalidades

### Nivel 0

- Autenticación con API de Puntored (obtener token Bearer).
- Listado de proveedores de recargas.
- Realización de compras de recargas.
- Visualización del ticket de la recarga.

### Nivel 1

- Almacenamiento de transacciones en una base de datos local (MySQL).
- Historial de transacciones con datos básicos.

### Nivel 2

- Interfaz gráfica atractiva e intuitiva.
- Validaciones en la UI para número de teléfono y valores de transacción.
- Resumen de compra y ticket de recarga.
- (Opcional) Implementación de un módulo de login para proteger el historial.

### Nivel 3 (Obligatorio)

- Uso de Riverpod para manejo de estados.
- Estructura de carpetas clara y modularizada.
- Manejo eficiente de estados complejos.

### Nivel Adicional (Backend en Spring Boot)

- API intermedia en **Spring Boot con Java** que consume Puntored y expone endpoints para la app Flutter.
- Validaciones y reglas de negocio en el backend.
- Almacenamiento de datos en MySQL.
- Implementación de servicios REST para gestionar transacciones.

## Instalación y Configuración

### Requisitos

- [Flutter 3.29.2](https://docs.flutter.dev/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) y [VS Code](https://code.visualstudio.com/)
- [MySQL](https://www.mysql.com/)
- (Opcional) [Java ](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)22 y [Maven](https://maven.apache.org/)

### Configuración del Proyecto Flutter

```sh
# Clonar el repositorio
git clone https://github.com/DavidDupre/pruebaTecnicaPuntoRed.git
cd <NOMBRE_DEL_PROYECTO>

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

### Configuración del Backend en Java Spring Boot

```sh
# Navegar al directorio del backend
cd backend

# Construir y ejecutar la aplicación Spring Boot
mvn spring-boot:run
```

### Configuración de la Base de Datos MySQL

1. Crear la base de datos en MySQL:

```sql
CREATE DATABASE puntored;
```

2. Configurar el archivo `application.properties` en Spring Boot:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/puntored
spring.datasource.username=root
spring.datasource.password=123456
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect

```

## Endpoints de la API (Opcional - Backend en Spring Boot)

### 1. Autenticación (POST)

`/auth` - Obtiene el token Bearer.

### 2. Obtener Proveedores (GET)

`/getSuppliers` - Devuelve una lista de proveedores.

### 3. Realizar Compra de Recarga (POST)

`/buy` - Permite realizar una transacción de recarga móvil.

### 4. Historial de Transacciones (Opcional)

- `GET /transactions`/listar - Lista todas las transacciones.
- `GET /transactions/{id}` - Obtiene una transacción por ID.
- `POST /transactions`/buy - Registra una nueva transacción.
- `PUT /transactions/editar/{id}` - Actualiza una transacción existente.
- `DELETE /auth/`login - Login a la aplicación.
- POST /transactions/editar/{id}

## Extras Opcionales

- Pruebas automatizadas en Flutter (unitarias e integración).
- Mejoras en la UI/UX para una mejor experiencia de usuario.

## Contacto

Para cualquier duda o comentario, puedes contactar al desarrollador en: [d.aldanadupre@gmail.com](mailto\:d.aldanadupre@gmail.com)

