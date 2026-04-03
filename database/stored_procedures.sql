CREATE OR REPLACE FUNCTION sp_cursos_getcursosasignados()
    RETURNS TABLE (
                      nombreEstudiante varchar(240) ,
                      carnet varchar(20) ,
                      codigoCurso varchar(30)   ,
                      nombreCurso varchar(120) ,
                      nota numeric(12, 2)
                  )
    LANGUAGE sql
AS $$
SELECT concat(u.first_name, ' ', u.last_name) AS nombreEstudiante,
       sp.student_code as carnet,
       c.code as codigoCurso,
       c.name as nombreCurso,
       st.grade as nota
FROM student_course st
         INNER JOIN course_programs cp ON st.course_program_uuid = cp.id
         INNER JOIN teacher_courses tc ON cp.teacher_course_id = tc.id
         INNER JOIN courses c ON tc.course_id = c.id
         INNER JOIN student_profiles sp ON st.student_uuid = sp.id
         INNER JOIN users u ON sp.user_id = u.id;
$$;

CREATE OR REPLACE FUNCTION sp_cursos_getcursosdocente()
    RETURNS TABLE (
        nombreProfesor varchar(240),
        codigoCurso varchar(30),
        nombreCurso varchar(120),
        carrera varchar(120),
        semestre int,
        seccion varchar(5)
    )
    LANGUAGE sql
AS $$
SELECT
    concat(u.first_name, ' ', u.last_name) AS nombreProfesor,
    c.code as codigoCurso,
    c.name as nombreCurso,
    sp.name as carrera,
    tc.semester as semestre,
    tc.section as seccion
FROM teacher_courses tc
INNER JOIN courses c on tc.course_id = c.id
INNER JOIN study_plans sp on tc.study_plan_id = sp.id
INNER JOIN teacher_profiles tp on tc.teacher_id = tp.id
INNER JOIN users u on tp.user_id = u.id;
$$;

CREATE OR REPLACE FUNCTION sp_equivalencias_getSolicitudes()
    RETURNS TABLE (
                      estado varchar(32),
                      nombre varchar(128),
                      carnet varchar(32),
                      carrera varchar(64),
                      cursoAprobado varchar(64),
                      codigoCursoAprobado varchar(64),
                      cursoEquivalencia varchar(64),
                      codigoCursoEquivalencia varchar(64),
                      cantidadArchivos bigint,
                      id uuid
                  )
    LANGUAGE sql
AS $$
SELECT
    s.name AS estado,
    concat(u.first_name, ' ', u.last_name) AS nombre,
    sp.student_code AS carnet,
    se.name AS carrera,
    c.name AS cursoAprobado,
    c.code AS codigoCursoAprobado,
    d.name AS cursoEquivalencia,
    d.code AS codigoCursoEquivalencia,
    COUNT(ds.id) AS cantidadArchivos,
    er.id AS id
FROM equivalence_requests er
         INNER JOIN student_profiles sp ON er.student_id = sp.id
         INNER JOIN users u ON sp.user_id = u.id
         INNER JOIN study_plans se ON se.id = er.destination_study_plan_id
         INNER JOIN equivalence_request_courses ec ON ec.equivalence_request_id = er.id
         INNER JOIN courses c ON ec.origin_course_id = c.id
         INNER JOIN courses d ON ec.destination_course_id = d.id
         INNER JOIN status s ON er.status_id = s.id
         INNER JOIN documents ds ON ds.equivalence_request_id = er.id
GROUP BY s.name, u.first_name, u.last_name, sp.student_code,
         se.name, c.name, c.code, d.name, d.code, er.id;
$$;

CREATE OR REPLACE FUNCTION sp_equivalencias_getSolicitudById(p_request_id uuid)
    RETURNS TABLE (
        estado varchar(32),
        nombre varchar(128),
        carnet varchar(32),
        carrera varchar(64),
        cursoAprobado varchar(64),
        codigoCursoAprobado varchar(64),
        cursoEquivalencia varchar(64),
        codigoCursoEquivalencia varchar(64),
        cantidadArchivos bigint,
        id uuid,
        fechaSolicitud timestamp,
        observaciones text
    )
    LANGUAGE sql
AS $$
SELECT
    s.name AS estado,
    concat(u.first_name, ' ', u.last_name) AS nombre,
    sp.student_code AS carnet,
    se.name AS carrera,
    c.name AS cursoAprobado,
    c.code AS codigoCursoAprobado,
    d.name AS cursoEquivalencia,
    d.code AS codigoCursoEquivalencia,
    COUNT(ds.id) AS cantidadArchivos,
    er.id AS id,
    er.submission_date AS fechaSolicitud,
    er.observations AS observaciones
FROM equivalence_requests er
         INNER JOIN student_profiles sp ON er.student_id = sp.id
         INNER JOIN users u ON sp.user_id = u.id
         INNER JOIN study_plans se ON se.id = er.destination_study_plan_id
         INNER JOIN equivalence_request_courses ec ON ec.equivalence_request_id = er.id
         INNER JOIN courses c ON ec.origin_course_id = c.id
         INNER JOIN courses d ON ec.destination_course_id = d.id
         INNER JOIN status s ON er.status_id = s.id
         LEFT JOIN documents ds ON ds.equivalence_request_id = er.id
WHERE er.id = p_request_id
GROUP BY s.name, u.first_name, u.last_name, sp.student_code,
         se.name, c.name, c.code, d.name, d.code, er.id, er.submission_date, er.observations;
$$;

CREATE OR REPLACE FUNCTION sp_equivalencias_getDocumentosBySolicitud(p_request_id uuid)
    RETURNS TABLE (
        id uuid,
        tipoDocumentoLabel varchar(100),
        nombre varchar(255),
        tipo varchar(50),
        tamanio bigint,
        fechaCarga timestamp,
        estado varchar(30)
    )
    LANGUAGE sql
AS $$
SELECT
    ds.id,
    COALESCE(dr.name, ds.document_type) AS tipoDocumentoLabel,
    ds.document_name AS nombre,
    ds.mime_type AS tipo,
    ds.file_size AS tamanio,
    ds.upload_date AS fechaCarga,
    ds.validation_status AS estado
FROM documents ds
LEFT JOIN document_requirements dr ON dr.code = ds.document_type
WHERE ds.equivalence_request_id = p_request_id
ORDER BY ds.upload_date DESC, ds.document_name;
$$;