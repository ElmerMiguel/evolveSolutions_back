-- ============================================================================
-- INSERTS INICIALES DE DATOS REQUERIDOS
-- EJECUTAR DESPUÉS DE: equivalency_system_db.sql
-- ============================================================================

-- Insertar roles básicos
INSERT INTO roles (code, name, description, display_order) VALUES
  ('STUDENT', 'Estudiante', 'Usuario estudiante que solicita equivalencias', 1),
  ('TEACHER', 'Docente', 'Usuario docente que sube programas y valida cursos', 2),
  ('SECRETARY', 'Secretaría', 'Usuario administrador que revisa y aprueba solicitudes', 3),
  ('ADMIN', 'Administrador', 'Administrador del sistema', 4)
ON CONFLICT (code) DO NOTHING;

-- Insertar permisos (HU-15: Restricción URLs)
INSERT INTO permissions (code, name, resource, action) VALUES
  ('STUDENT_VIEW_REQUESTS', 'Ver propias solicitudes', 'equivalence_requests', 'VIEW'),
  ('STUDENT_CREATE_REQUESTS', 'Crear solicitudes', 'equivalence_requests', 'CREATE'),
  ('STUDENT_UPLOAD_DOCUMENTS', 'Subir documentos', 'documents', 'CREATE'),
  
  ('TEACHER_VIEW_COURSES', 'Ver cursos asignados', 'teacher_courses', 'VIEW'),
  ('TEACHER_UPLOAD_PROGRAMS', 'Subir programas', 'course_programs', 'CREATE'),
  ('TEACHER_VIEW_REQUESTS', 'Ver solicitudes', 'equivalence_requests', 'VIEW'),
  
  ('SECRETARY_VIEW_ALL_REQUESTS', 'Ver todas solicitudes', 'equivalence_requests', 'VIEW'),
  ('SECRETARY_APPROVE_REQUESTS', 'Aprobar solicitudes', 'equivalence_requests', 'UPDATE'),
  ('SECRETARY_REJECT_REQUESTS', 'Rechazar solicitudes', 'equivalence_requests', 'UPDATE'),
  ('SECRETARY_VIEW_REPORTS', 'Ver reportes', 'reports', 'VIEW'),
  
  ('ADMIN_MANAGE_USERS', 'Gestionar usuarios', 'users', 'MANAGE'),
  ('ADMIN_MANAGE_COURSES', 'Gestionar cursos', 'courses', 'MANAGE'),
  ('ADMIN_VIEW_LOGS', 'Ver logs de auditoría', 'logs', 'VIEW')
ON CONFLICT (code) DO NOTHING;

-- Asignar permisos a roles (HU-15: Restricción URLs)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.code = 'STUDENT' AND p.code IN ('STUDENT_VIEW_REQUESTS', 'STUDENT_CREATE_REQUESTS', 'STUDENT_UPLOAD_DOCUMENTS')
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.code = 'TEACHER' AND p.code IN ('TEACHER_VIEW_COURSES', 'TEACHER_UPLOAD_PROGRAMS', 'TEACHER_VIEW_REQUESTS')
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.code = 'SECRETARY' AND p.code IN ('SECRETARY_VIEW_ALL_REQUESTS', 'SECRETARY_APPROVE_REQUESTS', 'SECRETARY_REJECT_REQUESTS', 'SECRETARY_VIEW_REPORTS')
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.code = 'ADMIN' AND p.code LIKE 'ADMIN_%'
ON CONFLICT DO NOTHING;