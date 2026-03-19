# 📚 DOCUMENTACIÓN TÉCNICA - BASE DE DATOS EQUIVALENCIAS ACADÉMICAS

**Proyecto:** Evolve Solutions - Sistema de Gestión de Equivalencias Académicas  
**Universidad:** San Carlos de Guatemala - CUNOC  
**Base de Datos:** PostgreSQL 13+   
**Última Actualización:** 19 de marzo de 2026

---

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Arquitectura de BD](#arquitectura-de-bd)
3. [Tablas y Entidades](#tablas-y-entidades)
4. [Relaciones y Foreign Keys](#relaciones-y-foreign-keys)
5. [Índices y Optimización](#índices-y-optimización)
6. [Vistas y Triggers](#vistas-y-triggers)
7. [Seguridad y Auditoría](#seguridad-y-auditoría)
8. [Diccionario de Datos](#diccionario-de-datos)

---

## 1. Descripción General

### Propósito

Sistema de gestión de equivalencias académicas que permite:

- ✅ Estudiantes solicitar equivalencia de cursos entre planes de estudio
- ✅ Docentes subir programas de cursos y validar contenido
- ✅ Secretaría revisar y aprobar solicitudes
- ✅ Administrador gestionar usuarios, roles y permisos
- ✅ Auditoría completa de todas las operaciones

### Características Principales

- **Seguridad:** Autenticación JWT, hashing de contraseñas con bcrypt
- **Control de Acceso:** RBAC (Role-Based Access Control) con 4 roles
- **Auditoría:** Logs de actividad, historial de cambios de estado, error logs
- **Normalización:** 3FN completa, sin redundancia de datos
- **Performance:** 50+ índices estratégicos
- **Manejo de Errores:** Registro seguro sin exponer datos sensibles

---

## 2. Arquitectura de BD

### Diagrama de Módulos

```
┌─────────────────────────────────────────────────────────────┐
│                    EVOLVE SOLUTIONS BD                      │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │  AUTH    │          │ACADEMIC │          │REQUESTS │
   │ SEGMENT  │          │SEGMENT  │          │SEGMENT  │
   └────┬────┘          └────┬────┘          └────┬────┘
        │                     │                     │
   • users              • careers            • equivalence_
   • roles              • study_plans          requests
   • permissions        • courses            • equivalence_
   • role_permissions   • study_plan_         request_courses
   • user_roles           courses            • documents
   • sessions           • teacher_courses    • document_
   • error_logs         • course_programs      requirements
   • user_activity_log                       • notifications
                                             • request_
                                               statistics
```

### Características de Diseño

- **Modularidad:** Tres módulos independientes pero relacionados
- **Integridad Referencial:** Foreign keys en todas las relaciones
- **Escalabilidad:** Índices en todas las columnas frecuentemente consultadas
- **Mantenibilidad:** Nombres claros y convenciones consistentes

---

## 3. Tablas y Entidades

### 3.1 MÓDULO DE AUTENTICACIÓN Y CONTROL DE ACCESO

#### 👤 Tabla: `users`

**Propósito:** Almacena datos de usuarios con seguridad de tokens

| Columna               | Tipo         | Restricciones                 | Descripción                            |
| --------------------- | ------------ | ----------------------------- | -------------------------------------- |
| id                    | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                    |
| username              | VARCHAR(50)  | UNIQUE, NOT NULL              | Nombre de usuario                      |
| email                 | VARCHAR(120) | UNIQUE, NOT NULL              | Email único                            |
| password_hash         | VARCHAR(255) | NOT NULL                      | Hash bcrypt (nunca plaintext)          |
| first_name            | VARCHAR(120) | NOT NULL                      | Nombre                                 |
| last_name             | VARCHAR(120) | NOT NULL                      | Apellido                               |
| photo_url             | VARCHAR(500) | NULL                          | URL de foto de perfil                  |
| email_verified        | BOOLEAN      | NOT NULL, DEFAULT FALSE       | Estado de verificación                 |
| email_verified_at     | TIMESTAMP    | NULL                          | Fecha de verificación                  |
| enabled               | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Cuenta activa                          |
| locked                | BOOLEAN      | NOT NULL, DEFAULT FALSE       | Cuenta bloqueada por intentos fallidos |
| failed_login_attempts | INT          | DEFAULT 0                     | Contador de intentos fallidos          |
| locked_until          | TIMESTAMP    | NULL                          | Hasta cuándo está bloqueada            |
| last_login_at         | TIMESTAMP    | NULL                          | Última entrada                         |
| last_logout_at        | TIMESTAMP    | NULL                          | Último cierre de sesión                |
| created_at            | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                         |
| updated_at            | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Última modificación                    |
| deleted_at            | TIMESTAMP    | NULL                          | Eliminación lógica (soft delete)       |

**Índices:**

- `idx_users_email` - Búsqueda rápida por email
- `idx_users_username` - Búsqueda rápida por username
- `idx_users_enabled` - Filtro de usuarios activos
- `idx_users_created_at` - Auditoría temporal

**Validaciones Aplicadas:**

- Username y email únicos
- Email verificable antes de acceso completo
- Bloqueo automático tras N intentos fallidos
- Timestamps automáticos

---

#### 👥 Tabla: `roles`

**Propósito:** Define los 4 roles del sistema

| Columna       | Tipo        | Restricciones                 | Descripción                                       |
| ------------- | ----------- | ----------------------------- | ------------------------------------------------- |
| id            | UUID        | PK, DEFAULT gen_random_uuid() | Identificador único                               |
| code          | VARCHAR(30) | UNIQUE, NOT NULL              | Código único (STUDENT, TEACHER, SECRETARY, ADMIN) |
| name          | VARCHAR(80) | NOT NULL                      | Nombre legible                                    |
| description   | TEXT        | NULL                          | Descripción del rol                               |
| display_order | INT         | NOT NULL, DEFAULT 0           | Orden en UI                                       |
| enabled       | BOOLEAN     | NOT NULL, DEFAULT TRUE        | Rol activo                                        |
| created_at    | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Fecha creación                                    |
| updated_at    | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Última modificación                               |

**Roles Iniciales:**

```
1. STUDENT     - Estudiante que solicita equivalencias
2. TEACHER     - Docente que sube programas y valida
3. SECRETARY   - Secretaría que aprueba solicitudes
4. ADMIN       - Administrador del sistema
```

---

#### 🔐 Tabla: `permissions`

**Propósito:** Define permisos granulares por recurso y acción

| Columna     | Tipo         | Restricciones                 | Descripción                                   |
| ----------- | ------------ | ----------------------------- | --------------------------------------------- |
| id          | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                           |
| code        | VARCHAR(50)  | UNIQUE, NOT NULL              | Código único (STUDENT_VIEW_REQUESTS, etc)     |
| name        | VARCHAR(100) | NOT NULL                      | Nombre legible                                |
| resource    | VARCHAR(50)  | NOT NULL                      | Recurso (equivalence_requests, courses, etc)  |
| action      | VARCHAR(30)  | NOT NULL                      | Acción (VIEW, CREATE, UPDATE, DELETE, MANAGE) |
| description | TEXT         | NULL                          | Descripción del permiso                       |
| enabled     | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Permiso activo                                |
| created_at  | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                                |

**Permisos Iniciales (13 total):**

```
STUDENT PERMISOS:
- STUDENT_VIEW_REQUESTS
- STUDENT_CREATE_REQUESTS
- STUDENT_UPLOAD_DOCUMENTS

TEACHER PERMISOS:
- TEACHER_VIEW_COURSES
- TEACHER_UPLOAD_PROGRAMS
- TEACHER_VIEW_REQUESTS

SECRETARY PERMISOS:
- SECRETARY_VIEW_ALL_REQUESTS
- SECRETARY_APPROVE_REQUESTS
- SECRETARY_REJECT_REQUESTS
- SECRETARY_VIEW_REPORTS

ADMIN PERMISOS:
- ADMIN_MANAGE_USERS
- ADMIN_MANAGE_COURSES
- ADMIN_VIEW_LOGS
```

---

#### 🔗 Tabla: `role_permissions`

**Propósito:** Mapeo muchos-a-muchos de roles con permisos

| Columna       | Tipo      | Restricciones           | Descripción                  |
| ------------- | --------- | ----------------------- | ---------------------------- |
| role_id       | UUID      | FK, NOT NULL            | Referencia a roles(id)       |
| permission_id | UUID      | FK, NOT NULL            | Referencia a permissions(id) |
| created_at    | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha asignación             |

**Clave Primaria:** (role_id, permission_id)

---

#### 👨‍💼 Tabla: `user_roles`

**Propósito:** Asigna roles a usuarios (un usuario puede tener múltiples roles)

| Columna     | Tipo      | Restricciones           | Descripción            |
| ----------- | --------- | ----------------------- | ---------------------- |
| user_id     | UUID      | FK, NOT NULL            | Referencia a users(id) |
| role_id     | UUID      | FK, NOT NULL            | Referencia a roles(id) |
| assigned_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Fecha de asignación    |

**Clave Primaria:** (user_id, role_id)  
**Nota:** Un usuario puede ser simultáneamente STUDENT y TEACHER

---

#### 🎫 Tabla: `sessions`

**Propósito:** Administra sesiones activas y tokens JWT

| Columna                  | Tipo         | Restricciones                 | Descripción                    |
| ------------------------ | ------------ | ----------------------------- | ------------------------------ |
| id                       | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único            |
| user_id                  | UUID         | FK, NOT NULL                  | Referencia a users(id)         |
| session_token_hash       | VARCHAR(255) | UNIQUE, NOT NULL              | Hash del JWT (nunca plaintext) |
| refresh_token_hash       | VARCHAR(255) | UNIQUE, NULL                  | Hash del refresh token         |
| access_token_expires_at  | TIMESTAMP    | NOT NULL                      | Expiración del access token    |
| refresh_token_expires_at | TIMESTAMP    | NULL                          | Expiración del refresh token   |
| ip_address               | VARCHAR(45)  | NULL                          | IP de origen (IPv4/IPv6)       |
| user_agent               | TEXT         | NULL                          | User-Agent del cliente         |
| device_fingerprint       | VARCHAR(255) | NULL                          | Fingerprint del dispositivo    |
| is_active                | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Sesión activa                  |
| revoked_at               | TIMESTAMP    | NULL                          | Cuándo fue revocada            |
| revoked_reason           | VARCHAR(100) | NULL                          | Razón de revocación            |
| created_at               | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                 |
| updated_at               | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Última modificación            |

**Índices:**

- `idx_sessions_user` - Buscar sesiones de un usuario
- `idx_sessions_token` - Validar token rápidamente
- `idx_sessions_expires_at` - Limpiar sesiones expiradas
- `idx_sessions_active` - Filtrar sesiones activas
- `idx_sessions_created_at` - Auditoría temporal

**Flujo de Tokens:**

```
1. Usuario login → Genera access_token + refresh_token
2. Hashes guardados en sessions (NUNCA plaintext)
3. Tokens enviados al cliente
4. Cliente envía access_token en Authorization header
5. Servidor valida hash vs. session
6. Cuando expira access_token → client usa refresh_token
7. Genera nuevo access_token + refresh_token
```

---

### 3.2 MÓDULO ACADÉMICO

#### 🎓 Tabla: `careers`

**Propósito:** Carreras académicas (Ingeniería, Administración, etc.)

| Columna     | Tipo         | Restricciones                 | Descripción                     |
| ----------- | ------------ | ----------------------------- | ------------------------------- |
| id          | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único             |
| code        | VARCHAR(30)  | UNIQUE, NOT NULL              | Código carrera (ING, ADM, etc)  |
| name        | VARCHAR(120) | NOT NULL                      | Nombre (Ingeniería en Sistemas) |
| description | TEXT         | NULL                          | Descripción                     |
| enabled     | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Carrera activa                  |
| created_at  | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                  |
| updated_at  | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Última modificación             |

---

#### 📚 Tabla: `study_plans`

**Propósito:** Planes de estudio (versiones de carreras/ Pensum)

| Columna           | Tipo         | Restricciones                 | Descripción               |
| ----------------- | ------------ | ----------------------------- | ------------------------- |
| id                | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único       |
| career_id         | UUID         | FK, NOT NULL                  | Referencia a careers(id)  |
| code              | VARCHAR(50)  | NOT NULL                      | Código del plan           |
| version           | VARCHAR(20)  | NOT NULL                      | Versión (2020, 2023, etc) |
| name              | VARCHAR(120) | NOT NULL                      | Nombre descriptivo        |
| description       | TEXT         | NULL                          | Descripción               |
| effective_date    | DATE         | NOT NULL                      | Fecha inicio vigencia     |
| obsolescence_date | DATE         | NULL                          | Fecha fin vigencia        |
| enabled           | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Plan activo               |
| created_at        | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación            |
| updated_at        | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Última modificación       |

**Índices:**

- `idx_study_plans_career` - Planes por carrera
- `idx_study_plans_code` - Buscar por código
- `idx_study_plans_enabled` - Filtrar planes activos

**Restricción Única:** (career_id, code, version)

---

#### 📖 Tabla: `courses`

**Propósito:** Catálogo de cursos académicos

| Columna        | Tipo         | Restricciones                 | Descripción                           |
| -------------- | ------------ | ----------------------------- | ------------------------------------- |
| id             | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                   |
| code           | VARCHAR(30)  | UNIQUE, NOT NULL              | Código curso (MAT101, ENG202, etc)    |
| name           | VARCHAR(120) | NOT NULL                      | Nombre (Cálculo I, English II)        |
| description    | TEXT         | NULL                          | Descripción del contenido             |
| credits        | INT          | NOT NULL, CHECK > 0           | Créditos académicos                   |
| hours_theory   | INT          | NOT NULL, CHECK >= 0          | Horas teóricas                        |
| hours_practice | INT          | NOT NULL, CHECK >= 0          | Horas prácticas                       |
| course_level   | VARCHAR(30)  | NULL                          | Nivel (BASIC, INTERMEDIATE, ADVANCED) |
| course_type    | VARCHAR(50)  | NULL                          | Tipo (MANDATORY, ELECTIVE, SEMINAR)   |
| enabled        | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Curso activo                          |
| created_at     | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                        |
| updated_at     | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Última modificación                   |

**Índices:**

- `idx_courses_code` - Búsqueda por código
- `idx_courses_name` - Búsqueda por nombre
- `idx_courses_enabled` - Filtrar cursos activos

---

#### 📋 Tabla: `study_plan_courses`

**Propósito:** Cursos dentro de cada plan(**pensum**) de estudio con sus relaciones

| Columna                | Tipo      | Restricciones                 | Descripción                  |
| ---------------------- | --------- | ----------------------------- | ---------------------------- |
| id                     | UUID      | PK, DEFAULT gen_random_uuid() | Identificador único          |
| study_plan_id          | UUID      | FK, NOT NULL                  | Referencia a study_plans(id) |
| course_id              | UUID      | FK, NOT NULL                  | Referencia a courses(id)     |
| semester               | INT       | NOT NULL, CHECK 1-12          | Semestre del plan            |
| is_mandatory           | BOOLEAN   | NOT NULL, DEFAULT TRUE        | Es curso obligatorio         |
| prerequisite_course_id | UUID      | FK, NULL                      | Curso requisito previo       |
| corequisite_course_id  | UUID      | FK, NULL                      | Curso corequisito            |
| created_at             | TIMESTAMP | NOT NULL, DEFAULT NOW()       | Fecha creación               |

**Restricción Única:** (study_plan_id, course_id)

**Ejemplo:**

```
Plan: ING-2023
├─ Semestre 1: MAT101 (obligatorio, sin requisitos)
├─ Semestre 2: MAT102 (obligatorio, prerequisito MAT101)
└─ Semestre 3: FIS201 (obligatorio, prerequisito MAT101, corequisito MAT102)
```

---

#### 👨‍🎓 Tabla: `student_profiles`

**Propósito:** Información académica de estudiantes

| Columna               | Tipo        | Restricciones                 | Descripción                            |
| --------------------- | ----------- | ----------------------------- | -------------------------------------- |
| id                    | UUID        | PK, DEFAULT gen_random_uuid() | Identificador único                    |
| user_id               | UUID        | FK UNIQUE, NOT NULL           | Referencia a users(id)                 |
| career_id             | UUID        | FK, NOT NULL                  | Carrera del estudiante                 |
| current_study_plan_id | UUID        | FK, NOT NULL                  | Plan de estudio actual                 |
| cui                   | VARCHAR(13) | UNIQUE, NOT NULL              | Carné de estudiante                    |
| student_code          | VARCHAR(20) | UNIQUE, NOT NULL              | Código interno                         |
| phone                 | VARCHAR(20) | NULL                          | Teléfono                               |
| current_semester      | INT         | NOT NULL, DEFAULT 1           | Semestre actual (1-12)                 |
| academic_status       | VARCHAR(30) | NOT NULL, DEFAULT 'ACTIVE'    | ACTIVE, INACTIVE, GRADUATED, SUSPENDED |
| enrollment_date       | DATE        | NOT NULL, DEFAULT TODAY       | Fecha inscripción                      |
| created_at            | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Fecha creación                         |
| updated_at            | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Última modificación                    |

**Índices:**

- `idx_student_profiles_user` - Buscar por usuario
- `idx_student_profiles_career` - Estudiantes por carrera
- `idx_student_profiles_academic_status` - Filtrar por estado

---

#### 👨‍🏫 Tabla: `teacher_profiles`

**Propósito:** Información profesional de docentes

| Columna             | Tipo         | Restricciones                 | Descripción                    |
| ------------------- | ------------ | ----------------------------- | ------------------------------ |
| id                  | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único            |
| user_id             | UUID         | FK UNIQUE, NOT NULL           | Referencia a users(id)         |
| colegio_profesional | VARCHAR(50)  | NULL                          | Colegiación profesional        |
| specializations     | TEXT         | NULL                          | Especializaciones (JSON array) |
| phone               | VARCHAR(20)  | NULL                          | Teléfono contacto              |
| office_location     | VARCHAR(200) | NULL                          | Ubicación oficina              |
| status              | VARCHAR(30)  | NOT NULL, DEFAULT 'ACTIVE'    | ACTIVE, INACTIVE, ON_LEAVE     |
| hire_date           | DATE         | NULL                          | Fecha de contratación          |
| created_at          | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                 |
| updated_at          | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Última modificación            |

---

#### 👨‍🏫📚 Tabla: `teacher_courses`

**Propósito:** Cursos impartidos por docentes (HU-21: Registro Curso BE)

| Columna           | Tipo        | Restricciones                 | Descripción                       |
| ----------------- | ----------- | ----------------------------- | --------------------------------- |
| id                | UUID        | PK, DEFAULT gen_random_uuid() | Identificador único               |
| teacher_id        | UUID        | FK, NOT NULL                  | Referencia a teacher_profiles(id) |
| course_id         | UUID        | FK, NOT NULL                  | Referencia a courses(id)          |
| study_plan_id     | UUID        | FK, NOT NULL                  | Plan de estudio donde enseña      |
| year_teaching     | INT         | NOT NULL                      | Año académico                     |
| semester          | INT         | NOT NULL, CHECK 1-2           | Semestre (1 o 2)                  |
| section           | VARCHAR(5)  | NULL                          | Sección (A, B, C)                 |
| capacity          | INT         | DEFAULT 40                    | Capacidad máxima                  |
| enrolled_students | INT         | DEFAULT 0                     | Estudiantes inscritos             |
| status            | VARCHAR(30) | NOT NULL, DEFAULT 'ACTIVE'    | ACTIVE, INACTIVE, CANCELLED       |
| created_at        | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Fecha creación                    |
| updated_at        | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Última modificación               |

**Restricción Única:** (teacher_id, course_id, study_plan_id, year_teaching, semester)

---

#### 📑 Tabla: `course_programs`

**Propósito:** Programas de cursos (documentos firmados por docentes)

| Columna           | Tipo         | Restricciones                 | Descripción                         |
| ----------------- | ------------ | ----------------------------- | ----------------------------------- |
| id                | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                 |
| teacher_course_id | UUID         | FK, NOT NULL                  | Referencia a teacher_courses(id)    |
| document_url      | VARCHAR(500) | NOT NULL                      | URL del documento en storage        |
| document_key      | VARCHAR(255) | UNIQUE, NOT NULL              | Clave única para storage            |
| file_size         | INT          | NOT NULL                      | Tamaño en bytes                     |
| mime_type         | VARCHAR(50)  | NULL                          | Tipo MIME                           |
| uploaded_by       | UUID         | FK, NOT NULL                  | Usuario que subió                   |
| upload_date       | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha upload                        |
| is_signed         | BOOLEAN      | NOT NULL, DEFAULT FALSE       | Está firmado digitalmente           |
| signature_date    | TIMESTAMP    | NULL                          | Fecha de firma                      |
| signed_by         | UUID         | FK, NULL                      | Usuario que firmó                   |
| status            | VARCHAR(30)  | NOT NULL, DEFAULT 'PENDING'   | PENDING, APPROVED, REJECTED, SIGNED |
| rejection_reason  | TEXT         | NULL                          | Razón si fue rechazado              |
| created_at        | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                      |
| updated_at        | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Última modificación                 |

---

### 3.3 MÓDULO DE SOLICITUDES DE EQUIVALENCIA

#### 📝 Tabla: `equivalence_requests`

**Propósito:** Solicitudes de equivalencia de cursos (HU-16: Dashboard limitado por rol)

| Columna                   | Tipo        | Restricciones                 | Descripción                              |
| ------------------------- | ----------- | ----------------------------- | ---------------------------------------- |
| id                        | UUID        | PK, DEFAULT gen_random_uuid() | Identificador único                      |
| student_id                | UUID        | FK, NOT NULL                  | Referencia a student_profiles(id)        |
| origin_study_plan_id      | UUID        | FK, NOT NULL                  | Plan de origen                           |
| destination_study_plan_id | UUID        | FK, NOT NULL                  | Plan de destino                          |
| status                    | VARCHAR(30) | NOT NULL, DEFAULT 'SUBMITTED' | SUBMITTED, IN_REVIEW, APPROVED, REJECTED |
| submission_date           | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Fecha de presentación                    |
| review_start_date         | TIMESTAMP   | NULL                          | Cuándo inició revisión                   |
| decision_date             | TIMESTAMP   | NULL                          | Fecha de decisión                        |
| decided_by                | UUID        | FK, NULL                      | Usuario que decidió                      |
| observations              | TEXT        | NULL                          | Observaciones                            |
| rejection_reason          | TEXT        | NULL                          | Razón de rechazo si aplica               |
| created_at                | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Fecha creación                           |
| updated_at                | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Última modificación                      |

**Flujo de Estados:**

```
SUBMITTED → IN_REVIEW → APPROVED ✓
                     ↘ REJECTED ✗
```

**Índices:**

- `idx_equivalence_requests_student` - Solicitudes del estudiante
- `idx_equivalence_requests_status` - Filtrar por estado
- `idx_equivalence_requests_submission_date` - Auditoría temporal

---

#### 📚 Tabla: `equivalence_request_courses`

**Propósito:** Cursos individuales dentro de una solicitud de equivalencia

| Columna                    | Tipo        | Restricciones                 | Descripción                           |
| -------------------------- | ----------- | ----------------------------- | ------------------------------------- |
| id                         | UUID        | PK, DEFAULT gen_random_uuid() | Identificador único                   |
| equivalence_request_id     | UUID        | FK, NOT NULL                  | Referencia a equivalence_requests(id) |
| origin_course_id           | UUID        | FK, NOT NULL                  | Curso de origen                       |
| destination_course_id      | UUID        | FK, NOT NULL                  | Curso destino                         |
| origin_course_grade        | VARCHAR(3)  | NULL                          | Calificación en origen (A, B, C, D)   |
| origin_course_credits      | INT         | NOT NULL                      | Créditos en origen                    |
| destination_course_credits | INT         | NOT NULL                      | Créditos en destino                   |
| status                     | VARCHAR(30) | NOT NULL, DEFAULT 'PENDING'   | PENDING, APPROVED, REJECTED           |
| created_at                 | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Fecha creación                        |

**Restricción Única:** (equivalence_request_id, origin_course_id)

**Ejemplo:**

```
Solicitud: {MAT101 (origen) → MAT102 (destino)} ✓ APPROVED
Solicitud: {FIS201 (origen) → FIS202 (destino)} ✗ REJECTED (diferentes créditos)
```

---

#### 📄 Tabla: `documents`

**Propósito:** Documentos adjuntos en solicitudes (expediente académico, etc.)

| Columna                | Tipo         | Restricciones                 | Descripción                            |
| ---------------------- | ------------ | ----------------------------- | -------------------------------------- |
| id                     | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                    |
| equivalence_request_id | UUID         | FK, NOT NULL                  | Solicitud asociada                     |
| document_type          | VARCHAR(50)  | NOT NULL                      | TRANSCRIPT, SYLLABUS, CERTIFICATE, etc |
| document_name          | VARCHAR(255) | NOT NULL                      | Nombre legible                         |
| document_url           | VARCHAR(500) | NOT NULL                      | URL en storage                         |
| document_key           | VARCHAR(255) | UNIQUE, NOT NULL              | Clave única para storage               |
| file_size              | INT          | NOT NULL                      | Tamaño en bytes                        |
| mime_type              | VARCHAR(50)  | NOT NULL                      | Tipo MIME (application/pdf, etc)       |
| uploaded_by            | UUID         | FK, NOT NULL                  | Usuario que subió                      |
| upload_date            | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha upload                           |
| validation_status      | VARCHAR(30)  | NOT NULL, DEFAULT 'PENDING'   | PENDING, VALID, INVALID                |
| validation_error       | TEXT         | NULL                          | Error si no es válido                  |
| validated_by           | UUID         | FK, NULL                      | Usuario que validó                     |
| validation_date        | TIMESTAMP    | NULL                          | Fecha de validación                    |
| created_at             | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                         |

**Índices:**

- `idx_documents_request` - Documentos por solicitud
- `idx_documents_validation_status` - Filtrar por validación
- `idx_documents_type` - Documentos por tipo

---

#### 📋 Tabla: `document_requirements`

**Propósito:** Catálogo de requisitos de documentos

| Columna         | Tipo         | Restricciones                 | Descripción                     |
| --------------- | ------------ | ----------------------------- | ------------------------------- |
| id              | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único             |
| name            | VARCHAR(100) | NOT NULL                      | Nombre (Récord Académico)       |
| code            | VARCHAR(30)  | UNIQUE, NOT NULL              | Código                          |
| description     | TEXT         | NULL                          | Descripción del requisito       |
| required        | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Es obligatorio                  |
| allowed_formats | VARCHAR(100) | NULL                          | Formatos permitidos (pdf, docx) |
| max_file_size   | INT          | NULL                          | Tamaño máximo en bytes          |
| enabled         | BOOLEAN      | NOT NULL, DEFAULT TRUE        | Requisito activo                |
| created_at      | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                  |

---

### 3.4 MÓDULO DE SEGURIDAD Y AUDITORÍA

#### 🔔 Tabla: `notifications`

**Propósito:** Notificaciones enviadas a usuarios (HU-08: Mensaje de error seguro)

| Columna                | Tipo         | Restricciones                 | Descripción                                                  |
| ---------------------- | ------------ | ----------------------------- | ------------------------------------------------------------ |
| id                     | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                                          |
| recipient_user_id      | UUID         | FK, NOT NULL                  | Usuario destinatario                                         |
| equivalence_request_id | UUID         | FK, NULL                      | Solicitud relacionada                                        |
| notification_type      | VARCHAR(50)  | NOT NULL                      | REQUEST_SUBMITTED, REQUEST_APPROVED, REQUEST_REJECTED, ERROR |
| title                  | VARCHAR(255) | NOT NULL                      | Título de la notificación                                    |
| message                | TEXT         | NOT NULL                      | Mensaje (sin datos sensibles)                                |
| email_status           | VARCHAR(30)  | NOT NULL, DEFAULT 'PENDING'   | PENDING, SENT, FAILED, BOUNCED                               |
| sent_at                | TIMESTAMP    | NULL                          | Cuándo se envió                                              |
| read_at                | TIMESTAMP    | NULL                          | Cuándo se leyó                                               |
| last_retry_at          | TIMESTAMP    | NULL                          | Último reintento de envío                                    |
| retry_count            | INT          | NOT NULL, DEFAULT 0           | Número de reintentos                                         |
| error_message          | TEXT         | NULL                          | Mensaje de error si falló                                    |
| created_at             | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                                               |

**Índices:**

- `idx_notifications_user` - Notificaciones del usuario
- `idx_notifications_email_status` - Filtrar por estado envío
- `idx_notifications_request` - Notificaciones por solicitud

---

#### ❌ Tabla: `error_logs`

**Propósito:** Registro seguro de errores sin datos sensibles (HU-08)

| Columna       | Tipo         | Restricciones                 | Descripción                                        |
| ------------- | ------------ | ----------------------------- | -------------------------------------------------- |
| id            | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                                |
| user_id       | UUID         | FK, NULL                      | Usuario afectado (puede ser NULL)                  |
| error_code    | VARCHAR(20)  | NOT NULL                      | Código (AUTH_001, VALIDATION_002, etc)             |
| error_message | TEXT         | NOT NULL                      | Mensaje de error (sanitizado)                      |
| error_details | JSONB        | NULL                          | Detalles técnicos (sin passwords, tokens)          |
| resource_type | VARCHAR(50)  | NULL                          | Tipo de recurso (equivalence_request, course, etc) |
| resource_id   | UUID         | NULL                          | ID del recurso afectado                            |
| action        | VARCHAR(50)  | NULL                          | Acción (CREATE, UPDATE, DELETE, VIEW)              |
| http_method   | VARCHAR(10)  | NULL                          | GET, POST, PUT, DELETE, PATCH                      |
| url_path      | VARCHAR(500) | NULL                          | Path del endpoint (sin query strings sensibles)    |
| ip_address    | VARCHAR(45)  | NULL                          | IP del cliente                                     |
| user_agent    | TEXT         | NULL                          | User-Agent                                         |
| severity      | VARCHAR(20)  | NOT NULL, DEFAULT 'INFO'      | INFO, WARNING, ERROR, CRITICAL                     |
| created_at    | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha creación                                     |

**Índices:**

- `idx_error_logs_user` - Errores del usuario
- `idx_error_logs_code` - Filtrar por código de error
- `idx_error_logs_severity` - Filtrar por severidad
- `idx_error_logs_created_at` - Auditoría temporal

**Ejemplo de Registro Seguro:**

```json
❌ MAL (No guardar):
{
  "error": "Invalid password 'mySecretPass123'",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

✅ BIEN (Guardar así):
{
  "error_code": "AUTH_001",
  "error_message": "Invalid credentials",
  "resource_type": "user",
  "resource_id": "uuid-123",
  "severity": "WARNING"
}
```

---

#### 📊 Tabla: `equivalence_request_status_history`

**Propósito:** Historial completo de cambios de estado (Auditoría)

| Columna                | Tipo        | Restricciones                 | Descripción             |
| ---------------------- | ----------- | ----------------------------- | ----------------------- |
| id                     | UUID        | PK, DEFAULT gen_random_uuid() | Identificador único     |
| equivalence_request_id | UUID        | FK, NOT NULL                  | Solicitud               |
| from_status            | VARCHAR(30) | NOT NULL                      | Estado anterior         |
| to_status              | VARCHAR(30) | NOT NULL                      | Estado nuevo            |
| changed_by             | UUID        | FK, NOT NULL                  | Usuario que hizo cambio |
| change_reason          | TEXT        | NULL                          | Razón del cambio        |
| created_at             | TIMESTAMP   | NOT NULL, DEFAULT NOW()       | Cuándo se cambió        |

**Auditoría Completa:**

```
2026-03-19 10:00 - SUBMITTED → IN_REVIEW (changed_by: secretary_user)
2026-03-19 14:30 - IN_REVIEW → APPROVED (changed_by: secretary_user, reason: "Cumple requisitos")
```

---

#### 📝 Tabla: `user_activity_log`

**Propósito:** Log de todas las actividades del usuario

| Columna       | Tipo         | Restricciones                 | Descripción                                          |
| ------------- | ------------ | ----------------------------- | ---------------------------------------------------- |
| id            | UUID         | PK, DEFAULT gen_random_uuid() | Identificador único                                  |
| user_id       | UUID         | FK, NOT NULL                  | Usuario                                              |
| action        | VARCHAR(100) | NOT NULL                      | ACTION_NAME (LOGIN, CREATE_REQUEST, APPROVE_REQUEST) |
| resource_type | VARCHAR(50)  | NOT NULL                      | Tipo recurso (user, equivalence_request, course)     |
| resource_id   | UUID         | NULL                          | ID del recurso                                       |
| details       | JSONB        | NULL                          | Detalles adicionales                                 |
| ip_address    | VARCHAR(45)  | NULL                          | IP origen                                            |
| user_agent    | TEXT         | NULL                          | User-Agent                                           |
| created_at    | TIMESTAMP    | NOT NULL, DEFAULT NOW()       | Fecha acción                                         |

**Auditoría de Actividades:**

```
LOGIN - User 'juan@example.com' - 192.168.1.1
CREATE_EQUIVALENCE_REQUEST - equivalence_request_id: uuid-456
UPLOAD_DOCUMENT - resource: document_id: uuid-789
APPROVE_REQUEST - equivalence_request_id: uuid-456 - reason: "Cumple"
```

---

#### 📈 Tabla: `request_statistics`

**Propósito:** Estadísticas de solicitudes para reportes

| Columna                     | Tipo          | Restricciones                 | Descripción                            |
| --------------------------- | ------------- | ----------------------------- | -------------------------------------- |
| id                          | UUID          | PK, DEFAULT gen_random_uuid() | Identificador único                    |
| equivalence_request_id      | UUID          | FK UNIQUE, NOT NULL           | Solicitud                              |
| days_to_resolution          | INT           | NULL                          | Días desde presentación hasta decisión |
| documents_count             | INT           | NOT NULL, DEFAULT 0           | Documentos adjuntos                    |
| courses_count               | INT           | NOT NULL, DEFAULT 0           | Cursos en solicitud                    |
| average_response_time_hours | NUMERIC(10,2) | NULL                          | Horas promedio de respuesta            |
| created_at                  | TIMESTAMP     | NOT NULL, DEFAULT NOW()       | Fecha creación                         |
| updated_at                  | TIMESTAMP     | NOT NULL, DEFAULT NOW()       | Última actualización                   |

---

## 4. Relaciones y Foreign Keys

### Mapa de Relaciones

```
users (1) ─────┬─────→ (N) user_roles ─────→ (N) roles
              │                                   ↓
              │                          role_permissions
              ├─────→ (N) sessions                ↓
              │                            permissions
              ├─────→ (1) student_profiles
              │            ↓
              │       current_study_plan_id → study_plans
              │            ↓
              │       career_id → careers
              │
              ├─────→ (1) teacher_profiles
              │
              ├─────→ (N) user_activity_log
              │
              ├─────→ (N) equivalence_request_status_history (changed_by)
              │
              ├─────→ (N) course_programs (uploaded_by, signed_by)
              │
              ├─────→ (N) documents (uploaded_by, validated_by)
              │
              └─────→ (N) error_logs

study_plans (1) ─────→ (N) study_plan_courses ─→ (N) courses
                ↓
          careers

teacher_profiles (1) ──→ (N) teacher_courses ──→ (N) courses
                     ↓
              study_plans

equivalence_requests (1) ─→ (N) equivalence_request_courses ─→ courses
                        ↓
                  student_profiles

equivalence_requests (1) ─→ (N) documents
                        ↓
                  (N) notifications
```

### Restricciones de Integridad Referencial

| FK  | Tabla                              | Columna                   | Referencia              | ON DELETE |
| --- | ---------------------------------- | ------------------------- | ----------------------- | --------- |
| 1   | user_roles                         | user_id                   | users.id                | CASCADE   |
| 2   | user_roles                         | role_id                   | roles.id                | RESTRICT  |
| 3   | role_permissions                   | role_id                   | roles.id                | CASCADE   |
| 4   | role_permissions                   | permission_id             | permissions.id          | CASCADE   |
| 5   | sessions                           | user_id                   | users.id                | CASCADE   |
| 6   | student_profiles                   | user_id                   | users.id                | CASCADE   |
| 7   | student_profiles                   | career_id                 | careers.id              | RESTRICT  |
| 8   | student_profiles                   | current_study_plan_id     | study_plans.id          | RESTRICT  |
| 9   | teacher_profiles                   | user_id                   | users.id                | CASCADE   |
| 10  | study_plans                        | career_id                 | careers.id              | RESTRICT  |
| 11  | study_plan_courses                 | study_plan_id             | study_plans.id          | CASCADE   |
| 12  | study_plan_courses                 | course_id                 | courses.id              | RESTRICT  |
| 13  | study_plan_courses                 | prerequisite_course_id    | courses.id              | SET NULL  |
| 14  | study_plan_courses                 | corequisite_course_id     | courses.id              | SET NULL  |
| 15  | teacher_courses                    | teacher_id                | teacher_profiles.id     | CASCADE   |
| 16  | teacher_courses                    | course_id                 | courses.id              | RESTRICT  |
| 17  | teacher_courses                    | study_plan_id             | study_plans.id          | RESTRICT  |
| 18  | course_programs                    | teacher_course_id         | teacher_courses.id      | CASCADE   |
| 19  | course_programs                    | uploaded_by               | users.id                | RESTRICT  |
| 20  | course_programs                    | signed_by                 | users.id                | SET NULL  |
| 21  | equivalence_requests               | student_id                | student_profiles.id     | CASCADE   |
| 22  | equivalence_requests               | origin_study_plan_id      | study_plans.id          | RESTRICT  |
| 23  | equivalence_requests               | destination_study_plan_id | study_plans.id          | RESTRICT  |
| 24  | equivalence_request_courses        | equivalence_request_id    | equivalence_requests.id | CASCADE   |
| 25  | equivalence_request_courses        | origin_course_id          | courses.id              | RESTRICT  |
| 26  | equivalence_request_courses        | destination_course_id     | courses.id              | RESTRICT  |
| 27  | documents                          | equivalence_request_id    | equivalence_requests.id | CASCADE   |
| 28  | documents                          | uploaded_by               | users.id                | RESTRICT  |
| 29  | documents                          | validated_by              | users.id                | SET NULL  |
| 30  | notifications                      | recipient_user_id         | users.id                | CASCADE   |
| 31  | notifications                      | equivalence_request_id    | equivalence_requests.id | SET NULL  |
| 32  | equivalence_request_status_history | equivalence_request_id    | equivalence_requests.id | CASCADE   |
| 33  | equivalence_request_status_history | changed_by                | users.id                | RESTRICT  |
| 34  | user_activity_log                  | user_id                   | users.id                | CASCADE   |
| 35  | request_statistics                 | equivalence_request_id    | equivalence_requests.id | CASCADE   |

---

## 5. Índices y Optimización

### Estrategia de Indexación

Total: **50+ índices** estratégicamente colocados para:

- Búsquedas rápidas (email, código, status)
- Filtros frecuentes (enabled, active)
- Joins (foreign keys)
- Auditoría temporal (created_at)

### Lista Completa de Índices

```sql
-- TABLA: users (4 índices)
idx_users_email            → Búsqueda de login
idx_users_username         → Búsqueda alternativa
idx_users_enabled          → Filtrar activos
idx_users_created_at       → Auditoría

-- TABLA: roles (2 índices)
idx_roles_code             → Búsqueda rápida
idx_roles_enabled          → Filtrar activos

-- TABLA: permissions (2 índices)
idx_permissions_code       → Búsqueda rápida
idx_permissions_resource   → Listar por recurso

-- TABLA: role_permissions (1 índice)
idx_role_permissions_role  → FK

-- TABLA: user_roles (2 índices)
idx_user_roles_user        → Roles del usuario
idx_user_roles_role        → Usuarios con rol

-- TABLA: sessions (5 índices)
idx_sessions_user          → Sesiones del usuario
idx_sessions_token         → Validar token
idx_sessions_expires_at    → Limpiar expiradas
idx_sessions_active        → Filtrar activas
idx_sessions_created_at    → Auditoría

-- TABLA: error_logs (4 índices)
idx_error_logs_user        → Errores del usuario
idx_error_logs_code        → Filtrar por código
idx_error_logs_severity    → Filtrar por severidad
idx_error_logs_created_at  → Auditoría

-- TABLA: careers (2 índices)
idx_careers_code           → Búsqueda rápida
idx_careers_enabled        → Filtrar activas

-- TABLA: study_plans (3 índices)
idx_study_plans_career     → Planes por carrera
idx_study_plans_code       → Búsqueda
idx_study_plans_enabled    → Filtrar activos

-- TABLA: courses (3 índices)
idx_courses_code           → Búsqueda rápida
idx_courses_name           → Búsqueda por nombre
idx_courses_enabled        → Filtrar activos

-- TABLA: study_plan_courses (3 índices)
idx_study_plan_courses_study_plan  → FK
idx_study_plan_courses_course      → FK
idx_study_plan_courses_semester    → Filtrar por semestre

-- TABLA: student_profiles (3 índices)
idx_student_profiles_user          → FK
idx_student_profiles_career        → FK
idx_student_profiles_academic_status → Filtrar por estado

-- TABLA: teacher_profiles (2 índices)
idx_teacher_profiles_user          → FK
idx_teacher_profiles_status        → Filtrar activos

-- TABLA: teacher_courses (2 índices)
idx_teacher_courses_teacher        → FK
idx_teacher_courses_year_semester  → Filtrar por período

-- TABLA: course_programs (3 índices)
idx_course_programs_teacher_course → FK
idx_course_programs_status         → Filtrar por estado
idx_course_programs_upload_date    → Auditoría

-- TABLA: equivalence_requests (3 índices)
idx_equivalence_requests_student        → FK
idx_equivalence_requests_status         → Filtrar por estado
idx_equivalence_requests_submission_date → Auditoría

-- TABLA: equivalence_request_courses (2 índices)
idx_equivalence_request_courses_request → FK
idx_equivalence_request_courses_courses → Búsqueda de relación

-- TABLA: documents (3 índices)
idx_documents_request          → FK
idx_documents_validation_status → Filtrar
idx_documents_type             → Filtrar por tipo

-- TABLA: document_requirements (2 índices)
idx_document_requirements_code    → Búsqueda
idx_document_requirements_required → Filtrar obligatorios

-- TABLA: notifications (4 índices)
idx_notifications_user              → Notificaciones del usuario
idx_notifications_email_status      → Filtrar por estado envío
idx_notifications_request           → FK
idx_notifications_created_at        → Auditoría

-- TABLA: equivalence_request_status_history (2 índices)
idx_status_history_request  → FK
idx_status_history_changed_by → Auditoría

-- TABLA: user_activity_log (3 índices)
idx_user_activity_log_user     → FK
idx_user_activity_log_created_at → Auditoría
idx_user_activity_log_action     → Filtrar por acción

-- TABLA: request_statistics (1 índice)
idx_request_statistics_request → FK
```

### Performance Estimado

```
Consultas típicas sin índice → ~500-1000ms
Consultas típicas con índice → ~10-50ms

Mejora: 10-100x más rápido
```

---

## 6. Vistas y Triggers

### Vistas Creadas

Las vistas fueron desplazadas al archivo `inserts_iniciales.sql` pero están disponibles:

1. **`student_dashboard_view`** - Dashboard para estudiantes
2. **`teacher_dashboard_view`** - Dashboard para docentes
3. **`secretary_dashboard_view`** - Dashboard para secretaría

### Triggers Creados

Los triggers están implementados en el archivo principal para auditoría automática:

1. **`tr_users_update_timestamp`** - Auto-actualizar updated_at
2. **`tr_sessions_update_timestamp`** - Auto-actualizar updated_at
3. **`tr_audit_equivalence_status`** - Registrar cambios de estado automáticamente

---

## 7. Seguridad y Auditoría

### Principios de Seguridad Implementados

#### 🔐 Autenticación y Autorización

- ✅ **JWT Tokens**: Almacenados como hash (nunca plaintext)
- ✅ **Refresh Tokens**: Para renovar sesiones sin re-login
- ✅ **Password Hashing**: bcrypt con pgcrypto
- ✅ **Session Management**: Control de IP, User-Agent, dispositivos
- ✅ **Account Lockout**: Bloqueo automático tras N intentos fallidos
- ✅ **RBAC**: 4 roles + 13 permisos granulares

#### 📝 Auditoría

- ✅ **Historial de Estado**: Cada cambio registrado
- ✅ **Activity Logs**: Todas las acciones de usuarios
- ✅ **Error Logs**: Errores sin datos sensibles
- ✅ **Timestamps**: Creación y modificación automáticas

#### 🛡️ Manejo Seguro de Datos

- ✅ **No Plaintext Passwords**: Siempre hashed
- ✅ **No Plaintext Tokens**: Siempre hashed en BD
- ✅ **Sanitized Error Messages**: Sin información técnica en notificaciones
- ✅ **Soft Delete**: Datos no eliminados, marcados como deleted_at

#### 🔒 Restricciones Referencial

- ✅ **Foreign Keys**: 35+ relaciones protegidas
- ✅ **Constraints**: CHECK en números, UNIQUE en códigos
- ✅ **ON DELETE**: CASCADE para eliminar relacionados, RESTRICT para proteger

### Auditoría Completa

```
Nivel 1: user_activity_log
└─ Todas las acciones de usuarios (login, crear solicitud, etc)

Nivel 2: equivalence_request_status_history
└─ Cambios de estado de solicitudes

Nivel 3: error_logs
└─ Errores del sistema (sanitizados)

Nivel 4: sessions
└─ Intentos de autenticación y duración de sesiones

Nivel 5: timestamps (created_at, updated_at)
└─ Cuándo se crea y modifica cada registro
```

---

## 8. Diccionario de Datos

### Estados de Solicitud

```
SUBMITTED   → Presentada, esperando revisión
IN_REVIEW   → En revisión por secretaría
APPROVED    → Aprobada ✓
REJECTED    → Rechazada ✗
```

### Estados de Curso

```
ACTIVE      → Curso en oferta
INACTIVE    → Curso no ofrecido
CANCELLED   → Curso cancelado
```

### Estados de Documento

```
PENDING     → Esperando validación
VALID       → Validado correctamente
INVALID     → No cumple requisitos
```

### Estados de Email/Notificación

```
PENDING     → Esperando envío
SENT        → Enviado exitosamente
FAILED      → Error en envío
BOUNCED     → Email rechazado
```

### Severidad de Errores

```
INFO        → Información general
WARNING     → Advertencia (posible problema)
ERROR       → Error (operación falló)
CRITICAL    → Error crítico (requiere atención inmediata)
```

### Statuses de Usuario

```
ACTIVE      → Activo
INACTIVE    → Inactivo
GRADUATED   → Graduado
SUSPENDED   → Suspendido
ON_LEAVE    → En licencia
```
