INSERT INTO careers (code, name, description) VALUES
('SIS', 'Ingeniería en Ciencias y Sistemas', 'Carrera de sistemas'),
('CIV', 'Ingeniería Civil', 'Carrera de civil'),
('IND', 'Ingeniería Industrial', 'Carrera industrial'),
('MEC', 'Ingeniería Mecánica', 'Carrera mecánica'),
('MEC_IND', 'Ingeniería Mecánica Industrial', 'Carrera mecánica industrial');


INSERT INTO study_plans (career_id, code, version, name, description, effective_date)
SELECT id, 'SIS-2016', '2016', 'Pensum Sistemas 2016', 'Plan 2016', '2016-01-01'
FROM careers WHERE code = 'SIS';

INSERT INTO study_plans (career_id, code, version, name, description, effective_date)
SELECT id, 'SIS-2025', '2025', 'Pensum Sistemas 2025', 'Plan 2025', '2025-01-01'
FROM careers WHERE code = 'SIS';

INSERT INTO study_plans (career_id, code, version, name, description, effective_date)
SELECT id, 'CIV-2012', '2012', 'Pensum Civil 2012', 'Plan 2012', '2012-01-01'
FROM careers WHERE code = 'CIV';

INSERT INTO study_plans (career_id, code, version, name, description, effective_date)
SELECT id, 'IND-2024', '2024', 'Pensum Industrial 2024', 'Plan 2024', '2024-01-01'
FROM careers WHERE code = 'IND';

 
DO $$
DECLARE
  v_user_id UUID;
  v_role_id UUID;
BEGIN
 
  SELECT id INTO v_role_id FROM roles WHERE code = 'TEACHER';
 
  -- ─── 1. William Daniel Velásquez Lorenzo ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'wdvelasquez', 'wdvelasquez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'William Daniel', 'Velásquez Lorenzo', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 2. Jorge Aparicio Garcia ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'japaricio', 'japaricio@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Jorge', 'Aparicio Garcia', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 3. Iván Alejandro Esteban Archila ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'iaesteban', 'iaesteban@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Iván Alejandro', 'Esteban Archila', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 4. César Augusto Grijalva ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'cagrijalva', 'cagrijalva@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'César Augusto', 'Grijalva', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 5. Luis Fernando Velásquez Pérez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'lfvelasquez', 'lfvelasquez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Luis Fernando', 'Velásquez Pérez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 6. David Luis Ernesto Aguilar López ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'dlaguilar', 'dlaguilar@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'David Luis Ernesto', 'Aguilar López', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 7. Oscar Manuel Maldonado Castillo ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'ommaldonado', 'ommaldonado@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Oscar Manuel', 'Maldonado Castillo', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 8. Edwin Ariel Pérez Álvarez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'eaperez', 'eaperez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Edwin Ariel', 'Pérez Álvarez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 9. Jorge Leonel Rivera Méndez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jlrivera', 'jlrivera@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Jorge Leonel', 'Rivera Méndez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 10. Humberto Osvaldo Hernández Sac ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'hohernandez', 'hohernandez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Humberto Osvaldo', 'Hernández Sac', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 11. Álvaro Humberto Flores Aguilar ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'ahflores', 'ahflores@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Álvaro Humberto', 'Flores Aguilar', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 12. Otto Alejandro Soto Macal ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'oasoto', 'oasoto@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Otto Alejandro', 'Soto Macal', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 13. Carlos Alberto Quijivix Racancoj ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'caquijivix', 'caquijivix@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Carlos Alberto', 'Quijivix Racancoj', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 14. Marvin Juan José Maldonado De León ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mjmaldonado', 'mjmaldonado@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Marvin Juan José', 'Maldonado De León', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 15. Daniel Antonio Quintana Archila ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'daquintana', 'daquintana@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Daniel Antonio', 'Quintana Archila', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 16. Bryan Enrique López Pérez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'belopez', 'belopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Bryan Enrique', 'López Pérez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 17. Sebastian Charchalac Ochoa ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'scharchalac', 'scharchalac@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Sebastian', 'Charchalac Ochoa', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 18. Victor Carol Hernández Monzón ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'vchernandez', 'vchernandez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Victor Carol', 'Hernández Monzón', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 19. Santiago Alejandro Pineda Barillas ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'sapineda', 'sapineda@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Santiago Alejandro', 'Pineda Barillas', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 20. Sergio Arturo Martínez Rodas ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'samartinez', 'samartinez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Sergio Arturo', 'Martínez Rodas', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 21. Carlos Eduardo Chavarría Alecio ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'cechavarria', 'cechavarria@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Carlos Eduardo', 'Chavarría Alecio', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 22. Bruno Israel Coyoy Lucas ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'bicoyoy', 'bicoyoy@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Bruno Israel', 'Coyoy Lucas', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 23. Jahen Gildardo Figueroa Merida ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jgfigueroa', 'jgfigueroa@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Jahen Gildardo', 'Figueroa Merida', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 24. Edgar Juvencio López Ovalle ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'ejlopez', 'ejlopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Edgar Juvencio', 'López Ovalle', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 25. Luis Efraín Abalí De León Regil ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'leabali', 'leabali@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Luis Efraín', 'Abalí De León Regil', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 26. Rony Estuardo Ramírez Paz ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'rerramirez', 'rerramirez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Rony Estuardo', 'Ramírez Paz', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 27. Deiffy Amarilis Morales Flores De Lima ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'damflores', 'damflores@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Deiffy Amarilis', 'Morales Flores De Lima', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 28. Erick Adolfo Coti Sac ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'eacoti', 'eacoti@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Erick Adolfo', 'Coti Sac', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 29. Ana Alicia Armas Hernández ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'aaaherandez', 'aaaherandez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Ana Alicia', 'Armas Hernández', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 30. Edelman Cándido Monzón López ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'ecmonzon', 'ecmonzon@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Edelman Cándido', 'Monzón López', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 31. Francisco Alberto Castañeda Ocaña ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'facastaneda', 'facastaneda@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Francisco Alberto', 'Castañeda Ocaña', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 32. María Elena Pérez Morales ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'meperez', 'meperez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'María Elena', 'Pérez Morales', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 33. Carlos Julián Hernández García ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'cjhernandez', 'cjhernandez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Carlos Julián', 'Hernández García', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 34. Santos Danilo Xivir Huix ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'sdxivir', 'sdxivir@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Santos Danilo', 'Xivir Huix', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 35. José Aroldo Nimatuj Quijivix ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'janimatuj', 'janimatuj@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'José Aroldo', 'Nimatuj Quijivix', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 36. Mario Luis Cifuentes Jacobs ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mlcifuentes', 'mlcifuentes@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Mario Luis', 'Cifuentes Jacobs', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 37. Karin Rossana Rivas Chávez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'krrivas', 'krrivas@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Karin Rossana', 'Rivas Chávez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 38. José Ricardo Mérida López ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jrmerida', 'jrmerida@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'José Ricardo', 'Mérida López', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 39. Gustavo Adolfo Fuentes Fuentes ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'gafuentes', 'gafuentes@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Gustavo Adolfo', 'Fuentes Fuentes', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 40. Álvaro Mauricio Ordóñez Cifuentes ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'amordenezc', 'amordenezc@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Álvaro Mauricio', 'Ordóñez Cifuentes', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 41. Nery Iván Pérez Morales ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'niperez', 'niperez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Nery Iván', 'Pérez Morales', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 42. Marvin Giovanni Velásquez López ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mgvelasquez', 'mgvelasquez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Marvin Giovanni', 'Velásquez López', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 43. Álvaro Mauricio Ordóñez Paz ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'amordenezp', 'amordenezp@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Álvaro Mauricio', 'Ordóñez Paz', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 44. Olimpia Eunice Martínez Vásquez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'oemartinez', 'oemartinez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Olimpia Eunice', 'Martínez Vásquez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 45. Erick Gilberto Calderón Arango ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'egcalderon', 'egcalderon@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Erick Gilberto', 'Calderón Arango', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 46. Mario Fernando Cajas Domínguez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mfcajas', 'mfcajas@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Mario Fernando', 'Cajas Domínguez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 47. Eddie Omar Flores Aceituno ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'eoflores', 'eoflores@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Eddie Omar', 'Flores Aceituno', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 48. Juan José Godínez Godínez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jjgodinez', 'jjgodinez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Juan José', 'Godínez Godínez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 49. Bryan Misael Monzón Fuentes ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'bmmonzon', 'bmmonzon@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Bryan Misael', 'Monzón Fuentes', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 50. Pedro Luis Domingo Vásquez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'pldomingo', 'pldomingo@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Pedro Luis', 'Domingo Vásquez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 51. José Moisés Granados Guevara ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jmgranados', 'jmgranados@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'José Moisés', 'Granados Guevara', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 52. Daniel Alberto González González ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'dagomzalez', 'dagomzalez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Daniel Alberto', 'González González', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 53. Mauricio Gerardo López Maldonado ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mglopez', 'mglopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Mauricio Gerardo', 'López Maldonado', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 54. Mario Moisés Ramírez Tobar ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mmramirez', 'mmramirez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Mario Moisés', 'Ramírez Tobar', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 55. Juan Francisco Rojas Santizo ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jfrojas', 'jfrojas@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Juan Francisco', 'Rojas Santizo', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 56. Erick Norberto Stewart Herrador ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'enstewart', 'enstewart@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Erick Norberto', 'Stewart Herrador', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 57. Aura Skarleth Mauricio Rodriguez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'asmauricio', 'asmauricio@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Aura Skarleth', 'Mauricio Rodriguez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 58. Wendy Lucrecia Díaz Cotí ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'wldiaz', 'wldiaz@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Wendy Lucrecia', 'Díaz Cotí', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 59. Edgar Enrique Barrios Herédia ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'eebarrios', 'eebarrios@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Edgar Enrique', 'Barrios Herédia', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 60. Carlos Eduardo Morales Lam ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'cemorales', 'cemorales@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Carlos Eduardo', 'Morales Lam', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 61. Javiera Yolanda Maldonado de León ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jymaldonado', 'jymaldonado@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Javiera Yolanda', 'Maldonado de León', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 62. María Renée Martínez Bethancourt ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mrmartinez', 'mrmartinez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'María Renée', 'Martínez Bethancourt', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 63. Erick Estuardo Martínez Rodríguez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'eemartinez', 'eemartinez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Erick Estuardo', 'Martínez Rodríguez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 64. Mario Randolfo Moreno Paiz ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'mrmoreno', 'mrmoreno@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Mario Randolfo', 'Moreno Paiz', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 65. Alicia Noemí García Tovar ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'angarcia', 'angarcia@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Alicia Noemí', 'García Tovar', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 66. Ángel Rodolfo Puac Morales ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'arpuac', 'arpuac@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Ángel Rodolfo', 'Puac Morales', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 67. César Adolfo Cobaquil Quemé ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'cacobaquil', 'cacobaquil@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'César Adolfo', 'Cobaquil Quemé', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 68. Jorge Mario González Hidalgo ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jmgonzalez', 'jmgonzalez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Jorge Mario', 'González Hidalgo', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 69. Edwin Antonio López Basegoda ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'ealopez', 'ealopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Edwin Antonio', 'López Basegoda', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 70. William Antonio López Coronado ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'walopez', 'walopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'William Antonio', 'López Coronado', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 71. Francisco Dionicio Simón Andrés ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'fdsimon', 'fdsimon@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Francisco Dionicio', 'Simón Andrés', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 72. Coralia Angélica Velásquez Cotí ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'cavelasquez', 'cavelasquez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Coralia Angélica', 'Velásquez Cotí', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 73. Aníbal Alonzo López Mazariegos ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'aalopez', 'aalopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Aníbal Alonzo', 'López Mazariegos', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 74. Álvaro Clementino Ajpop Bravo ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'acajpop', 'acajpop@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Álvaro Clementino', 'Ajpop Bravo', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 75. Luis Humberto Hernández Silín ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'lhhernandez', 'lhhernandez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Luis Humberto', 'Hernández Silín', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 76. Roger Edelman Alain Monzón Bartlett ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'reamonzon', 'reamonzon@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Roger Edelman Alain', 'Monzón Bartlett', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 77. Christian Alberto López Quiroa ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'calopez', 'calopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Christian Alberto', 'López Quiroa', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 78. José Antonio Sajquím Xicará ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jasajquim', 'jasajquim@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'José Antonio', 'Sajquím Xicará', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 79. Rodolfo Leonidas Cifuentes Morales ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'rlcifuentes', 'rlcifuentes@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Rodolfo Leonidas', 'Cifuentes Morales', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 80. Héctor Romeo Xicará Méndez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'hrxicara', 'hrxicara@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Héctor Romeo', 'Xicará Méndez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 81. Carlos Enrique Castillo Martínez ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'cecastillo', 'cecastillo@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Carlos Enrique', 'Castillo Martínez', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 82. Matías Arturo Tacám Coyoy ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'matacam', 'matacam@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Matías Arturo', 'Tacám Coyoy', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 83. Julio César Leonardo Jucup Escobar ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jcljucup', 'jcljucup@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Julio César Leonardo', 'Jucup Escobar', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 84. Telma Johana de León Hip ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'tjdeleon', 'tjdeleon@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Telma Johana', 'de León Hip', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 85. Jorge Luis Domínguez Monterroso ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'jldominguez', 'jldominguez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Jorge Luis', 'Domínguez Monterroso', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 86. Kevin Eduardo Coyoy Marroquín ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'kecoyoy', 'kecoyoy@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Kevin Eduardo', 'Coyoy Marroquín', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 87. Pablo César López Fuentes ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'pclopez', 'pclopez@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Pablo César', 'López Fuentes', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 88. Federico Toribio Chaj Saquic ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'ftchaj', 'ftchaj@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Federico Toribio', 'Chaj Saquic', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
  -- ─── 89. Diego Esteban Orozco Orozco ───
  INSERT INTO users (id, username, email, password_hash, first_name, last_name, email_verified, enabled)
  VALUES (gen_random_uuid(), 'deorozco', 'deorozco@cunoc.edu.gt',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHuu',
    'Diego Esteban', 'Orozco Orozco', true, true)
  RETURNING id INTO v_user_id;
  INSERT INTO teacher_profiles (id, user_id, status) VALUES (gen_random_uuid(), v_user_id, 'ACTIVE');
  INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
 
END $$;

INSERT INTO users (username, email, password_hash, first_name, last_name, email_verified) VALUES
('egarcia', 'egarcia@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Eduardo', 'García', true),
('mrodriguez', 'mrodriguez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Marta', 'Rodríguez', true),
('jmartinez', 'jmartinez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Jorge', 'Martínez', true),
('ahernandez', 'ahernandez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Andrea', 'Hernández', true),
('llopez', 'llopez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Luis', 'López', true),
('cgonzalez', 'cgonzalez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Carmen', 'González', true),
('pperez', 'pperez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Pedro', 'Pérez', true),
('asanchez', 'asanchez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Ana', 'Sánchez', true),
('rramirez', 'rramirez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Raúl', 'Ramírez', true),
('scruz', 'scruz@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Silvia', 'Cruz', true),
('dflores', 'dflores@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Daniel', 'Flores', true),
('vgomez', 'vgomez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Víctor', 'Gómez', true),
('lcastillo', 'lcastillo@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Laura', 'Castillo', true),
('mrivera', 'mrivera@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Mario', 'Rivera', true),
('ptorres', 'ptorres@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Patricia', 'Torres', true),
('fmorales', 'fmorales@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Fernando', 'Morales', true),
('rreyes', 'rreyes@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Rosa', 'Reyes', true),
('hdiaz', 'hdiaz@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Héctor', 'Díaz', true),
('mvasquez', 'mvasquez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Mónica', 'Vásquez', true),
('jalvarez', 'jalvarez@cunoc.edu.gt', '$2a$12$HashDePruebaFalso1234567890123456', 'Javier', 'Álvarez', true)
ON CONFLICT (username) DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id 
FROM users u, roles r 
WHERE r.code = 'STUDENT'
AND u.username IN (
  'egarcia', 'mrodriguez', 'jmartinez', 'ahernandez', 'llopez', 
  'cgonzalez', 'pperez', 'asanchez', 'rramirez', 'scruz', 
  'dflores', 'vgomez', 'lcastillo', 'mrivera', 'ptorres', 
  'fmorales', 'rreyes', 'hdiaz', 'mvasquez', 'jalvarez'
)
ON CONFLICT DO NOTHING;

WITH student_data (username, car_code, plan_code, cui, carnet, sem, enr_date) AS (
    VALUES
    ('egarcia', 'SIS', 'SIS-2016', '3001000000101', '201910001', 10, '2019-02-01'::date),
    ('mrodriguez', 'CIV', 'CIV-2012', '3001000000102', '202010002', 8, '2020-02-01'::date),
    ('jmartinez', 'IND', 'IND-2024', '3001000000103', '202410003', 3, '2024-02-01'::date),
    ('ahernandez', 'SIS', 'SIS-2025', '3001000000104', '202510004', 1, '2025-02-01'::date),
    ('llopez', 'CIV', 'CIV-2012', '3001000000105', '201810005', 12, '2018-02-01'::date),
    ('cgonzalez', 'SIS', 'SIS-2016', '3001000000106', '202110006', 6, '2021-02-01'::date),
    ('pperez', 'IND', 'IND-2024', '3001000000107', '202410007', 3, '2024-02-01'::date),
    ('asanchez', 'SIS', 'SIS-2016', '3001000000108', '202010008', 8, '2020-02-01'::date),
    ('rramirez', 'CIV', 'CIV-2012', '3001000000109', '202210009', 5, '2022-02-01'::date),
    ('scruz', 'SIS', 'SIS-2025', '3001000000110', '202510010', 1, '2025-02-01'::date),
    ('dflores', 'IND', 'IND-2024', '3001000000111', '202410011', 2, '2024-02-01'::date),
    ('vgomez', 'SIS', 'SIS-2016', '3001000000112', '201910012', 10, '2019-02-01'::date),
    ('lcastillo', 'CIV', 'CIV-2012', '3001000000113', '202310013', 4, '2023-02-01'::date),
    ('mrivera', 'SIS', 'SIS-2016', '3001000000114', '202110014', 6, '2021-02-01'::date),
    ('ptorres', 'IND', 'IND-2024', '3001000000115', '202410015', 3, '2024-02-01'::date),
    ('fmorales', 'SIS', 'SIS-2025', '3001000000116', '202510016', 1, '2025-02-01'::date),
    ('rreyes', 'CIV', 'CIV-2012', '3001000000117', '202110017', 7, '2021-02-01'::date),
    ('hdiaz', 'SIS', 'SIS-2016', '3001000000118', '202210018', 5, '2022-02-01'::date),
    ('mvasquez', 'IND', 'IND-2024', '3001000000119', '202410019', 2, '2024-02-01'::date),
    ('jalvarez', 'SIS', 'SIS-2025', '3001000000120', '202510020', 1, '2025-02-01'::date)
)
INSERT INTO student_profiles (user_id, career_id, current_study_plan_id, cui, student_code, current_semester, academic_status, enrollment_date)
SELECT 
    u.id, 
    c.id, 
    sp.id, 
    sd.cui, 
    sd.carnet, 
    sd.sem, 
    'ACTIVE',
    sd.enr_date
FROM student_data sd
JOIN users u ON u.username = sd.username
JOIN careers c ON c.code = sd.car_code
JOIN study_plans sp ON sp.code = sd.plan_code AND sp.career_id = c.id
ON CONFLICT (student_code) DO NOTHING;