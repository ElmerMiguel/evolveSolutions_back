-- ============================================================================
-- EVOLVE SOLUTIONS - SISTEMA DE GESTIÓN DE EQUIVALENCIAS ACADÉMICAS
-- Universidad San Carlos de Guatemala - CUNOC
-- Arquitectura: PostgreSQL 13+
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Limpieza de tablas (Orden inverso para evitar errores de FK)
DROP TABLE IF EXISTS request_statistics CASCADE;
DROP TABLE IF EXISTS user_activity_log CASCADE;
DROP TABLE IF EXISTS equivalence_request_status_history CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS document_requirements CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS equivalence_request_courses CASCADE;
DROP TABLE IF EXISTS equivalence_requests CASCADE;
DROP TABLE IF EXISTS course_programs CASCADE;
DROP TABLE IF EXISTS teacher_courses CASCADE;
DROP TABLE IF EXISTS teacher_profiles CASCADE;
DROP TABLE IF EXISTS student_profiles CASCADE;
DROP TABLE IF EXISTS study_plan_courses CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS study_plans CASCADE;
DROP TABLE IF EXISTS careers CASCADE;
DROP TABLE IF EXISTS error_logs CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS role_permissions CASCADE;
DROP TABLE IF EXISTS permissions CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- HU-14: MANEJO DE TOKEN - TABLA USERS CON SEGURIDAD
-- ============================================================================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  
  first_name VARCHAR(120) NOT NULL,
  last_name VARCHAR(120) NOT NULL,
  photo_url VARCHAR(500),
  
  -- Campos para seguridad y manejo de tokens
  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  email_verified_at TIMESTAMP,
  
  -- Estado de cuenta
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  locked BOOLEAN NOT NULL DEFAULT FALSE,
  failed_login_attempts INT DEFAULT 0,
  locked_until TIMESTAMP,
  
  -- Para refresh tokens
  last_login_at TIMESTAMP,
  last_logout_at TIMESTAMP,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_enabled ON users(enabled);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================================================
-- HU-15: RESTRICCIÓN URLs - TABLA ROLES CON PERMISOS
-- ============================================================================

CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(80) NOT NULL,
  description TEXT,
  
  -- Para restringir URLs por rol
  display_order INT NOT NULL DEFAULT 0,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_roles_code ON roles(code);
CREATE INDEX idx_roles_enabled ON roles(enabled);

-- ============================================================================
-- HU-15: RESTRICCIÓN URLs - TABLA PERMISOS
-- ============================================================================

CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  resource VARCHAR(50) NOT NULL,
  action VARCHAR(30) NOT NULL,
  
  description TEXT,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_permissions_code ON permissions(code);
CREATE INDEX idx_permissions_resource ON permissions(resource);

-- ============================================================================
-- HU-15: RESTRICCIÓN URLs - TABLA ROLE_PERMISSIONS
-- ============================================================================

CREATE TABLE role_permissions (
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  
  PRIMARY KEY (role_id, permission_id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);

-- ============================================================================
-- TABLA USER_ROLES (Relación usuarios-roles)
-- ============================================================================

CREATE TABLE user_roles (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  
  PRIMARY KEY (user_id, role_id),
  assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);

-- ============================================================================
-- HU-14: MANEJO DE TOKEN - TABLA SESSIONS
-- ============================================================================

CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Token manejado en aplicación, hash almacenado aquí
  session_token_hash VARCHAR(255) NOT NULL UNIQUE,
  refresh_token_hash VARCHAR(255) UNIQUE,
  
  -- Tokens
  access_token_expires_at TIMESTAMP NOT NULL,
  refresh_token_expires_at TIMESTAMP,
  
  -- Información de seguridad
  ip_address VARCHAR(45),
  user_agent TEXT,
  device_fingerprint VARCHAR(255),
  
  -- Estado
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  revoked_at TIMESTAMP,
  revoked_reason VARCHAR(100),
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_token ON sessions(session_token_hash);
CREATE INDEX idx_sessions_expires_at ON sessions(access_token_expires_at);
CREATE INDEX idx_sessions_active ON sessions(is_active);
CREATE INDEX idx_sessions_created_at ON sessions(created_at);

-- ============================================================================
-- HU-08: MENSAJE DE ERROR SEGURO - TABLA ERROR LOGS
-- ============================================================================

CREATE TABLE error_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  
  error_code VARCHAR(20) NOT NULL,
  error_message TEXT NOT NULL,
  error_details JSONB,
  
  -- Contexto seguro (sin datos sensibles)
  resource_type VARCHAR(50),
  resource_id UUID,
  action VARCHAR(50),
  
  -- Información de request
  http_method VARCHAR(10),
  url_path VARCHAR(500),
  ip_address VARCHAR(45),
  user_agent TEXT,
  
  -- Severidad
  severity VARCHAR(20) NOT NULL DEFAULT 'INFO',
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_error_logs_user ON error_logs(user_id);
CREATE INDEX idx_error_logs_code ON error_logs(error_code);
CREATE INDEX idx_error_logs_severity ON error_logs(severity);
CREATE INDEX idx_error_logs_created_at ON error_logs(created_at);

-- ============================================================================
-- HU-18: TABLA BD PARA LA ENTIDAD "CURSO" - ESTRUCTURA ACADÉMICA
-- ============================================================================

CREATE TABLE careers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  description TEXT,
  
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_careers_code ON careers(code);
CREATE INDEX idx_careers_enabled ON careers(enabled);

-- ============================================================================
-- HU-18: PLANES DE ESTUDIO
-- ============================================================================

CREATE TABLE study_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  career_id UUID NOT NULL REFERENCES careers(id) ON DELETE RESTRICT,
  
  code VARCHAR(50) NOT NULL,
  version VARCHAR(20) NOT NULL,
  name VARCHAR(120) NOT NULL,
  description TEXT,
  
  effective_date DATE NOT NULL,
  obsolescence_date DATE,
  
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(career_id, code, version)
);

CREATE INDEX idx_study_plans_career ON study_plans(career_id);
CREATE INDEX idx_study_plans_code ON study_plans(code);
CREATE INDEX idx_study_plans_enabled ON study_plans(enabled);

-- ============================================================================
-- HU-18: TABLA CURSOS - ENTIDAD PRINCIPAL
-- ============================================================================

CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  description TEXT,
  
  -- Estructura académica
  credits INT NOT NULL CHECK (credits > 0),
  hours_theory INT NOT NULL CHECK (hours_theory >= 0),
  hours_practice INT NOT NULL CHECK (hours_practice >= 0),
  
  -- Clasificación
  course_level VARCHAR(30),
  course_type VARCHAR(50),
  
  -- Estado
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_courses_code ON courses(code);
CREATE INDEX idx_courses_name ON courses(name);
CREATE INDEX idx_courses_enabled ON courses(enabled);

-- ============================================================================
-- HU-18: RELACIÓN PLAN-CURSOS (Cursos por Plan de Estudio)
-- ============================================================================

CREATE TABLE study_plan_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  study_plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
  
  -- Ubicación en el plan
  semester INT NOT NULL CHECK (semester BETWEEN 1 AND 12),
  is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Prerequisito
  prerequisite_course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
  
  -- Corequisito
  corequisite_course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(study_plan_id, course_id)
);

CREATE INDEX idx_study_plan_courses_study_plan ON study_plan_courses(study_plan_id);
CREATE INDEX idx_study_plan_courses_course ON study_plan_courses(course_id);
CREATE INDEX idx_study_plan_courses_semester ON study_plan_courses(semester);

-- ============================================================================
-- HU-16: DASHBOARD LIMITADO POR ROL - TABLA PERFILES DE ESTUDIANTES
-- ============================================================================

CREATE TABLE student_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  career_id UUID NOT NULL REFERENCES careers(id) ON DELETE RESTRICT,
  current_study_plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE RESTRICT,
  
  -- Identificación académica
  cui VARCHAR(13) NOT NULL UNIQUE,
  student_code VARCHAR(20) NOT NULL UNIQUE,
  
  -- Información de contacto
  phone VARCHAR(20),
  
  -- Estado académico
  current_semester INT NOT NULL DEFAULT 1 CHECK (current_semester BETWEEN 1 AND 12),
  academic_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  
  -- Para dashboard
  enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_student_profiles_user ON student_profiles(user_id);
CREATE INDEX idx_student_profiles_career ON student_profiles(career_id);
CREATE INDEX idx_student_profiles_academic_status ON student_profiles(academic_status);

-- ============================================================================
-- HU-16: DASHBOARD LIMITADO POR ROL - TABLA PERFILES DE DOCENTES
-- ============================================================================

CREATE TABLE teacher_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Información profesional
  colegio_profesional VARCHAR(50),
  specializations TEXT,
  
  -- Información de contacto
  phone VARCHAR(20),
  office_location VARCHAR(200),
  
  -- Estado
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  hire_date DATE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_teacher_profiles_user ON teacher_profiles(user_id);
CREATE INDEX idx_teacher_profiles_status ON teacher_profiles(status);

-- ============================================================================
-- HU-21: REGISTRO DE CURSO BE - TABLA DOCENTE_CURSOS
-- ============================================================================

CREATE TABLE teacher_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES teacher_profiles(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
  study_plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE RESTRICT,
  
  -- Período académico
  year_teaching INT NOT NULL,
  semester INT NOT NULL CHECK (semester BETWEEN 1 AND 2),
  section VARCHAR(5),
  
  -- Información del grupo
  capacity INT DEFAULT 40,
  enrolled_students INT DEFAULT 0,
  
  -- Estado
  status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(teacher_id, course_id, study_plan_id, year_teaching, semester)
);

CREATE INDEX idx_teacher_courses_teacher ON teacher_courses(teacher_id);
CREATE INDEX idx_teacher_courses_course ON teacher_courses(course_id);
CREATE INDEX idx_teacher_courses_year_semester ON teacher_courses(year_teaching, semester);

-- ============================================================================
-- TABLA: PROGRAMAS DE CURSOS (Documentos Firmados por Docentes)
-- ============================================================================

CREATE TABLE course_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_course_id UUID NOT NULL REFERENCES teacher_courses(id) ON DELETE CASCADE,
  
  -- Documento almacenado
  document_url VARCHAR(500) NOT NULL,
  document_key VARCHAR(255) NOT NULL UNIQUE,
  file_size INT NOT NULL,
  mime_type VARCHAR(50),
  
  -- Metadatos de upload
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  upload_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Firma electrónica
  is_signed BOOLEAN NOT NULL DEFAULT FALSE,
  signature_date TIMESTAMP,
  signed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  
  -- Estado
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  rejection_reason TEXT,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_course_programs_teacher_course ON course_programs(teacher_course_id);
CREATE INDEX idx_course_programs_status ON course_programs(status);
CREATE INDEX idx_course_programs_upload_date ON course_programs(upload_date);

-- ============================================================================
-- HU-16: DASHBOARD LIMITADO POR ROL - TABLA SOLICITUDES DE EQUIVALENCIA
-- ============================================================================

CREATE TABLE equivalence_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
  
  origin_study_plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE RESTRICT,
  destination_study_plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE RESTRICT,
  
  -- Flujo de estados
  status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED',
  submission_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  review_start_date TIMESTAMP,
  decision_date TIMESTAMP,
  decided_by UUID REFERENCES users(id) ON DELETE SET NULL,
  
  -- Observaciones
  observations TEXT,
  rejection_reason TEXT,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_equivalence_requests_student ON equivalence_requests(student_id);
CREATE INDEX idx_equivalence_requests_status ON equivalence_requests(status);
CREATE INDEX idx_equivalence_requests_submission_date ON equivalence_requests(submission_date);

-- ============================================================================
-- TABLA: CURSOS EN SOLICITUD DE EQUIVALENCIA
-- ============================================================================

CREATE TABLE equivalence_request_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equivalence_request_id UUID NOT NULL REFERENCES equivalence_requests(id) ON DELETE CASCADE,
  
  origin_course_id UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
  destination_course_id UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
  
  -- Información académica
  origin_course_grade VARCHAR(3),
  origin_course_credits INT NOT NULL,
  destination_course_credits INT NOT NULL,
  
  -- Estado individual del curso
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(equivalence_request_id, origin_course_id)
);

CREATE INDEX idx_equivalence_request_courses_request ON equivalence_request_courses(equivalence_request_id);
CREATE INDEX idx_equivalence_request_courses_courses ON equivalence_request_courses(origin_course_id, destination_course_id);

-- ============================================================================
-- TABLA: DOCUMENTOS ADJUNTOS EN SOLICITUDES
-- ============================================================================

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equivalence_request_id UUID NOT NULL REFERENCES equivalence_requests(id) ON DELETE CASCADE,
  
  -- Metadatos del documento
  document_type VARCHAR(50) NOT NULL,
  document_name VARCHAR(255) NOT NULL,
  document_url VARCHAR(500) NOT NULL,
  document_key VARCHAR(255) NOT NULL UNIQUE,
  
  file_size INT NOT NULL,
  mime_type VARCHAR(50) NOT NULL,
  
  -- Auditoría
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  upload_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Validación
  validation_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  validation_error TEXT,
  validated_by UUID REFERENCES users(id) ON DELETE SET NULL,
  validation_date TIMESTAMP,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_documents_request ON documents(equivalence_request_id);
CREATE INDEX idx_documents_validation_status ON documents(validation_status);
CREATE INDEX idx_documents_type ON documents(document_type);

-- ============================================================================
-- TABLA: REQUISITOS DE DOCUMENTOS
-- ============================================================================

CREATE TABLE document_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  code VARCHAR(30) NOT NULL UNIQUE,
  description TEXT,
  
  required BOOLEAN NOT NULL DEFAULT TRUE,
  allowed_formats VARCHAR(100),
  max_file_size INT,
  
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_document_requirements_code ON document_requirements(code);
CREATE INDEX idx_document_requirements_required ON document_requirements(required);

-- ============================================================================
-- TABLA: NOTIFICACIONES (Para HU-08: Mensaje de error seguro)
-- ============================================================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  equivalence_request_id UUID REFERENCES equivalence_requests(id) ON DELETE SET NULL,
  
  -- Contenido
  notification_type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  
  -- Estado de entrega
  email_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  sent_at TIMESTAMP,
  read_at TIMESTAMP,
  
  -- Reintento
  last_retry_at TIMESTAMP,
  retry_count INT NOT NULL DEFAULT 0,
  error_message TEXT,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(recipient_user_id);
CREATE INDEX idx_notifications_email_status ON notifications(email_status);
CREATE INDEX idx_notifications_request ON notifications(equivalence_request_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- ============================================================================
-- TABLA: HISTORIAL DE CAMBIOS DE ESTADO (Auditoría)
-- ============================================================================

CREATE TABLE equivalence_request_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equivalence_request_id UUID NOT NULL REFERENCES equivalence_requests(id) ON DELETE CASCADE,
  
  from_status VARCHAR(30) NOT NULL,
  to_status VARCHAR(30) NOT NULL,
  changed_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  change_reason TEXT,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_status_history_request ON equivalence_request_status_history(equivalence_request_id);
CREATE INDEX idx_status_history_changed_by ON equivalence_request_status_history(changed_by);

-- ============================================================================
-- TABLA: LOG DE ACTIVIDAD DE USUARIOS (Auditoría)
-- ============================================================================

CREATE TABLE user_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Acción realizada
  action VARCHAR(100) NOT NULL,
  resource_type VARCHAR(50) NOT NULL,
  resource_id UUID,
  
  -- Contexto
  details JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_activity_log_user ON user_activity_log(user_id);
CREATE INDEX idx_user_activity_log_created_at ON user_activity_log(created_at);
CREATE INDEX idx_user_activity_log_action ON user_activity_log(action);

-- ============================================================================
-- TABLA: ESTADÍSTICAS DE SOLICITUDES (Para reportes y dashboard)
-- ============================================================================

CREATE TABLE request_statistics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equivalence_request_id UUID NOT NULL UNIQUE REFERENCES equivalence_requests(id) ON DELETE CASCADE,
  
  days_to_resolution INT,
  documents_count INT NOT NULL DEFAULT 0,
  courses_count INT NOT NULL DEFAULT 0,
  average_response_time_hours NUMERIC(10, 2),
  
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_request_statistics_request ON request_statistics(equivalence_request_id);



-- ============================================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- ============================================================================
COMMENT ON TABLE users IS 'HU-14: Tabla de usuarios con manejo seguro de tokens y sesiones';
COMMENT ON TABLE sessions IS 'HU-14: Tabla de sesiones activas con tokens hasheados';
COMMENT ON TABLE roles IS 'HU-15: Roles del sistema para restricción de URLs';
COMMENT ON TABLE permissions IS 'HU-15: Permisos específicos por rol';
COMMENT ON TABLE courses IS 'HU-18: Tabla principal de cursos académicos';
COMMENT ON TABLE teacher_courses IS 'HU-21: Registro de cursos impartidos por docentes';
COMMENT ON TABLE equivalence_requests IS 'HU-16: Solicitudes de equivalencia con estado por rol';
COMMENT ON TABLE error_logs IS 'HU-08: Registro seguro de errores sin datos sensibles';
