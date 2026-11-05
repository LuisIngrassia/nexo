/* ================================================================
   DATOS DE PRUEBA
   ================================================================ */

INSERT INTO Carrera
    (nombre, unidad_academica, plan_estudios, nivel)
VALUES
    ('Ingenieria en Informatica', 'FAIN', 'Plan 2026', 'GRADO'),
    ('Licenciatura en Sistemas', 'FAIN', 'Plan 2025', 'GRADO'),
    ('Abogacia', 'FACE', 'Plan 2024', 'GRADO'),
    ('Contador Publico', 'FACE', 'Plan 2025', 'GRADO'),
    ('Administracion de Empresas', 'FACE', 'Plan 2026', 'GRADO'),
    ('Marketing', 'FACE', 'Plan 2025', 'GRADO'),
    ('Recursos Humanos', 'FACE', 'Plan 2024', 'GRADO'),
    ('Diseno Grafico', 'FADI', 'Plan 2026', 'GRADO'),
    ('Comercio Internacional', 'FACE', 'Plan 2025', 'GRADO'),
    ('Ingenieria Industrial', 'FAIN', 'Plan 2026', 'GRADO');

INSERT INTO Materia (id_carrera, codigo, nombre)
VALUES
    (1, 'INF101', 'Programacion I'),
    (1, 'INF102', 'Base de Datos I'),
    (2, 'SIS101', 'Analisis de Sistemas'),
    (2, 'SIS102', 'Gestion de Proyectos'),
    (3, 'DER101', 'Derecho Civil'),
    (3, 'DER102', 'Derecho Laboral'),
    (4, 'CON101', 'Contabilidad I'),
    (4, 'CON102', 'Impuestos I'),
    (5, 'ADM101', 'Administracion General'),
    (5, 'ADM102', 'Finanzas'),
    (6, 'MKT101', 'Marketing Digital'),
    (6, 'MKT102', 'Investigacion de Mercados'),
    (7, 'RRH101', 'Gestion de Personas'),
    (7, 'RRH102', 'Seleccion de Personal'),
    (8, 'DIS101', 'Diseno Visual'),
    (8, 'DIS102', 'Herramientas Digitales'),
    (9, 'COM101', 'Operatoria Internacional'),
    (9, 'COM102', 'Logistica Internacional'),
    (10, 'IND101', 'Procesos Industriales'),
    (10, 'IND102', 'Gestion de Calidad');

INSERT INTO Estudiante
    (id_carrera, legajo, nombre, apellido, email, anio_ingreso, estado)
VALUES
    (1, '10001', 'Ana', 'Perez', 'ana.perez@ejemplo.edu', 2023, 'ACTIVO'),
    (2, '10002', 'Bruno', 'Lopez', 'bruno.lopez@ejemplo.edu', 2022, 'ACTIVO'),
    (3, '10003', 'Carla', 'Gomez', 'carla.gomez@ejemplo.edu', 2021, 'ACTIVO'),
    (4, '10004', 'Diego', 'Ruiz', 'diego.ruiz@ejemplo.edu', 2023, 'ACTIVO'),
    (5, '10005', 'Elena', 'Torres', 'elena.torres@ejemplo.edu', 2022, 'ACTIVO'),
    (6, '10006', 'Facundo', 'Diaz', 'facundo.diaz@ejemplo.edu', 2024, 'ACTIVO'),
    (7, '10007', 'Gabriela', 'Sosa', 'gabriela.sosa@ejemplo.edu', 2021, 'ACTIVO'),
    (8, '10008', 'Hugo', 'Castro', 'hugo.castro@ejemplo.edu', 2023, 'ACTIVO'),
    (9, '10009', 'Irene', 'Molina', 'irene.molina@ejemplo.edu', 2022, 'ACTIVO'),
    (10, '10010', 'Juan', 'Romero', 'juan.romero@ejemplo.edu', 2024, 'ACTIVO');

INSERT INTO Estudiante_Materia
    (id_estudiante, id_materia, fecha_aprobacion)
VALUES
    (1, 1, '2024-07-15'), (1, 2, '2025-07-15'),
    (2, 3, '2023-07-15'), (2, 4, '2024-07-15'),
    (3, 5, '2022-07-15'), (3, 6, '2023-07-15'),
    (4, 7, '2024-07-15'), (4, 8, '2025-07-15'),
    (5, 9, '2023-07-15'), (5, 10, '2024-07-15'),
    (6, 11, '2025-07-15'), (6, 12, '2026-07-15'),
    (7, 13, '2022-07-15'), (7, 14, '2023-07-15'),
    (8, 15, '2024-07-15'), (8, 16, '2025-07-15'),
    (9, 17, '2023-07-15'), (9, 18, '2024-07-15'),
    (10, 19, '2025-07-15'), (10, 20, '2026-07-15');

INSERT INTO Competencia (nombre, categoria, descripcion)
VALUES
    ('SQL', 'TECNICA', 'Consultas y modelado de datos'),
    ('Programacion', 'TECNICA', 'Desarrollo de soluciones de software'),
    ('Analisis juridico', 'PROFESIONAL', 'Interpretacion y analisis normativo'),
    ('Contabilidad', 'PROFESIONAL', 'Registro y analisis contable'),
    ('Gestion de proyectos', 'TRANSVERSAL', 'Planificacion y seguimiento de proyectos'),
    ('Marketing digital', 'PROFESIONAL', 'Campanas y canales digitales'),
    ('Seleccion de personal', 'PROFESIONAL', 'Procesos de busqueda y seleccion'),
    ('Diseno visual', 'TECNICA', 'Comunicacion mediante recursos visuales'),
    ('Logistica', 'PROFESIONAL', 'Gestion de operaciones y distribucion'),
    ('Comunicacion', 'TRANSVERSAL', 'Comunicacion oral y escrita');

INSERT INTO Estudiante_Competencia
    (id_estudiante, id_competencia, nivel_declarado)
VALUES
    (1, 1, 3), (1, 2, 2),
    (2, 1, 2), (2, 5, 3),
    (3, 3, 3), (3, 10, 2),
    (4, 4, 3), (4, 1, 1),
    (5, 5, 3), (5, 10, 3),
    (6, 6, 3), (6, 10, 2),
    (7, 7, 3), (7, 10, 3),
    (8, 8, 3), (8, 6, 2),
    (9, 9, 3), (9, 10, 2),
    (10, 9, 2), (10, 5, 2);

INSERT INTO Empresa
    (cuit, razon_social, sector, tamano, ciudad, estado_vinculo, activo)
VALUES
    ('30-10000001-1', 'Datos del Sur SA', 'Tecnologia', 'MEDIANA', 'CABA', 'ACTIVA', 1),
    ('30-10000002-2', 'Sistemas Rio SRL', 'Tecnologia', 'PEQUENA', 'CABA', 'ACTIVA', 1),
    ('30-10000003-3', 'Estudio Legal Centro', 'Servicios legales', 'PEQUENA', 'CABA', 'ACTIVA', 1),
    ('30-10000004-4', 'Contables Asociados', 'Contabilidad', 'MEDIANA', 'Rosario', 'ACTIVA', 1),
    ('30-10000005-5', 'Gestion Federal SA', 'Consultoria', 'GRANDE', 'CABA', 'ACTIVA', 1),
    ('30-10000006-6', 'Mercado Creativo SRL', 'Marketing', 'PEQUENA', 'Cordoba', 'ACTIVA', 1),
    ('30-10000007-7', 'Personas Primero SA', 'Recursos humanos', 'MEDIANA', 'CABA', 'ACTIVA', 1),
    ('30-10000008-8', 'Estudio Visual SRL', 'Diseno', 'PEQUENA', 'La Plata', 'ACTIVA', 1),
    ('30-10000009-9', 'Comercio Global SA', 'Comercio exterior', 'GRANDE', 'CABA', 'ACTIVA', 1),
    ('30-10000010-0', 'Industria Nacional SA', 'Industria', 'GRANDE', 'Pilar', 'ACTIVA', 1),
    ('30-10000011-1', 'Servicios del Centro SRL', 'Servicios', 'PEQUENA', 'CABA', 'PROSPECTO', 1);

INSERT INTO Convenio
    (id_empresa, fecha_inicio, fecha_fin, estado, objetivo, cupos_referenciales)
VALUES
    (1, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas de datos', 5),
    (2, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas de sistemas', 5),
    (3, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas juridicas', 3),
    (4, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas contables', 4),
    (5, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas de gestion', 5),
    (6, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas de marketing', 4),
    (7, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas de recursos humanos', 4),
    (8, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas de diseno', 3),
    (9, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas de comercio exterior', 5),
    (10, '2026-01-01', '2028-12-31', 'VIGENTE', 'Practicas industriales', 6);

INSERT INTO Oferta
    (id_empresa, id_convenio, titulo, descripcion, fecha_publicacion,
     fecha_cierre, vacantes, modalidad, jornada, estado)
VALUES
    (1, 1, 'Asistente de datos', 'Apoyo en consultas y reportes', '2026-08-01', '2027-12-31', 2, 'HIBRIDA', '20 horas', 'PUBLICADA'),
    (2, 2, 'Analista funcional junior', 'Apoyo en relevamiento funcional', '2026-08-02', '2027-12-31', 2, 'REMOTA', '20 horas', 'PUBLICADA'),
    (3, 3, 'Asistente legal', 'Apoyo en investigacion juridica', '2026-08-03', '2027-12-31', 1, 'PRESENCIAL', '20 horas', 'PUBLICADA'),
    (4, 4, 'Auxiliar contable', 'Registracion y conciliaciones', '2026-08-04', '2027-12-31', 2, 'HIBRIDA', '20 horas', 'PUBLICADA'),
    (5, 5, 'Asistente de proyectos', 'Seguimiento de proyectos internos', '2026-08-05', '2027-12-31', 2, 'HIBRIDA', '24 horas', 'PUBLICADA'),
    (6, 6, 'Asistente de marketing', 'Apoyo en campanas digitales', '2026-08-06', '2027-12-31', 2, 'REMOTA', '20 horas', 'PUBLICADA'),
    (7, 7, 'Asistente de seleccion', 'Apoyo en busquedas laborales', '2026-08-07', '2027-12-31', 2, 'HIBRIDA', '20 horas', 'PUBLICADA'),
    (8, 8, 'Disenador junior', 'Produccion de piezas visuales', '2026-08-08', '2027-12-31', 1, 'REMOTA', '20 horas', 'PUBLICADA'),
    (9, 9, 'Asistente de comercio exterior', 'Seguimiento documental de operaciones', '2026-08-09', '2027-12-31', 2, 'HIBRIDA', '20 horas', 'PUBLICADA'),
    (10, 10, 'Asistente de procesos', 'Relevamiento de procesos productivos', '2026-08-10', '2027-12-31', 2, 'PRESENCIAL', '24 horas', 'PUBLICADA');

INSERT INTO Oferta_Carrera (id_oferta, id_carrera)
VALUES
    (1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
    (6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

INSERT INTO Oferta_Competencia
    (id_oferta, id_competencia, nivel_requerido, obligatoria)
VALUES
    (1, 1, 2, 1), (1, 10, 2, 0),
    (2, 5, 2, 1), (2, 1, 1, 0),
    (3, 3, 2, 1), (3, 10, 2, 0),
    (4, 4, 2, 1), (4, 1, 1, 0),
    (5, 5, 2, 1), (5, 10, 2, 0),
    (6, 6, 2, 1), (6, 10, 2, 0),
    (7, 7, 2, 1), (7, 10, 2, 0),
    (8, 8, 2, 1), (8, 6, 1, 0),
    (9, 9, 2, 1), (9, 10, 2, 0),
    (10, 9, 2, 1), (10, 5, 2, 0);

INSERT INTO Postulacion
    (id_estudiante, id_oferta, fecha, estado, origen, observaciones)
VALUES
    (1, 1, '2026-09-01', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (2, 2, '2026-09-02', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (3, 3, '2026-09-03', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (4, 4, '2026-09-04', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (5, 5, '2026-09-05', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (6, 6, '2026-09-06', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (7, 7, '2026-09-07', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (8, 8, '2026-09-08', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (9, 9, '2026-09-09', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (10, 10, '2026-09-10', 'SELECCIONADA', 'CV', 'Perfil recibido'),
    (1, 2, '2026-09-11', 'RECHAZADA', 'CV', 'Perfil recibido'),
    (2, 3, '2026-09-12', 'EN_REVISION', 'CV', 'Perfil en revision'),
    (3, 4, '2026-09-13', 'ENTREVISTA', 'CV', 'Entrevista pendiente'),
    (4, 5, '2026-09-14', 'RETIRADA', 'CV', 'El estudiante retiro la postulacion'),
    (5, 6, '2026-09-15', 'RECIBIDA', 'CV', 'Postulacion recibida');

INSERT INTO Postulacion_Estado_Historial
    (id_postulacion, estado_anterior, estado_nuevo, fecha_cambio, motivo)
VALUES
    (1, NULL, 'SELECCIONADA', '2026-09-15', 'Seleccion de prueba'),
    (2, NULL, 'SELECCIONADA', '2026-09-16', 'Seleccion de prueba'),
    (3, NULL, 'SELECCIONADA', '2026-09-17', 'Seleccion de prueba'),
    (4, NULL, 'SELECCIONADA', '2026-09-18', 'Seleccion de prueba'),
    (5, NULL, 'SELECCIONADA', '2026-09-19', 'Seleccion de prueba'),
    (6, NULL, 'SELECCIONADA', '2026-09-20', 'Seleccion de prueba'),
    (7, NULL, 'SELECCIONADA', '2026-09-21', 'Seleccion de prueba'),
    (8, NULL, 'SELECCIONADA', '2026-09-22', 'Seleccion de prueba'),
    (9, NULL, 'SELECCIONADA', '2026-09-23', 'Seleccion de prueba'),
    (10, NULL, 'SELECCIONADA', '2026-09-24', 'Seleccion de prueba'),
    (11, 'ENTREVISTA', 'RECHAZADA', '2026-09-25', 'No alcanzo el nivel requerido'),
    (12, 'RECIBIDA', 'EN_REVISION', '2026-09-26', 'Perfil enviado para revision'),
    (13, 'EN_REVISION', 'ENTREVISTA', '2026-09-27', 'Entrevista coordinada'),
    (14, 'EN_REVISION', 'RETIRADA', '2026-09-28', 'Cambio de disponibilidad'),
    (15, NULL, 'RECIBIDA', '2026-09-29', 'Registro inicial');

INSERT INTO Entrevista
    (id_postulacion, fecha, etapa, resultado, devolucion)
VALUES
    (1, '2026-09-11 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (2, '2026-09-12 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (3, '2026-09-13 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (4, '2026-09-14 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (5, '2026-09-15 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (6, '2026-09-16 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (7, '2026-09-17 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (8, '2026-09-18 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (9, '2026-09-19 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (10, '2026-09-20 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (11, '2026-09-21 10:00', 'GENERAL', 'RECHAZADA', 'Nivel insuficiente'),
    (13, '2026-09-22 10:00', 'GENERAL', 'PENDIENTE', 'Entrevista en proceso');

INSERT INTO Practica
    (id_postulacion, fecha_inicio, fecha_fin_prevista, fecha_fin_real,
     horas_semanales, modalidad, estado, motivo_cierre)
VALUES
    (1, '2026-10-01', '2027-03-31', NULL, 20, 'HIBRIDA', 'EN_CURSO', NULL),
    (2, '2026-10-01', '2027-03-31', NULL, 20, 'REMOTA', 'EN_CURSO', NULL),
    (3, '2026-04-01', '2026-09-30', '2026-09-30', 20, 'PRESENCIAL', 'FINALIZADA', 'Finalizacion prevista'),
    (4, '2026-04-01', '2026-09-30', '2026-09-30', 20, 'HIBRIDA', 'FINALIZADA', 'Finalizacion prevista'),
    (5, '2026-10-01', '2027-03-31', NULL, 24, 'HIBRIDA', 'EN_CURSO', NULL),
    (6, '2026-04-01', '2026-09-30', '2026-09-30', 20, 'REMOTA', 'FINALIZADA', 'Finalizacion prevista'),
    (7, '2026-10-01', '2027-03-31', NULL, 20, 'HIBRIDA', 'EN_CURSO', NULL),
    (8, '2026-04-01', '2026-09-30', '2026-09-15', 20, 'REMOTA', 'INTERRUMPIDA', 'Cambio de disponibilidad'),
    (9, '2026-10-01', '2027-03-31', NULL, 20, 'HIBRIDA', 'EN_CURSO', NULL),
    (10, '2026-10-01', '2027-03-31', NULL, 24, 'PRESENCIAL', 'EN_CURSO', NULL);

INSERT INTO Seguimiento
    (id_practica, fecha, tipo_seguimiento, origen_feedback,
     estado_seguimiento, observaciones, intervencion_facultad, proxima_revision)
VALUES
    (1, '2026-10-15', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-11-15'),
    (2, '2026-10-16', 'INICIAL', 'ESTUDIANTE', 'EN_OBSERVACION', 'Requiere ajustar horarios', 'Revisar horarios con la empresa', '2026-11-01'),
    (3, '2026-07-15', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2026-08-15'),
    (4, '2026-07-16', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2026-08-16'),
    (5, '2026-10-17', 'INICIAL', 'EMPRESA', 'SIN_NOVEDADES', 'Buen inicio', NULL, '2026-11-17'),
    (6, '2026-07-18', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2026-08-18'),
    (7, '2026-10-19', 'INICIAL', 'AMBOS', 'REQUIERE_INTERVENCION', 'Dificultad de comunicacion', 'Coordinar una reunion', '2026-10-26'),
    (8, '2026-08-20', 'EXTRAORDINARIO', 'ESTUDIANTE', 'REQUIERE_INTERVENCION', 'Posible interrupcion', 'Analizar alternativas', '2026-08-27'),
    (9, '2026-10-21', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-11-21'),
    (10, '2026-10-22', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-11-22');

INSERT INTO Evaluacion
    (id_practica, fecha, tipo_evaluador, puntaje_desempeno,
     puntaje_satisfaccion, resultado, comentarios)
VALUES
    (1, '2026-11-01', 'ESTUDIANTE', NULL, 4, 'PARCIAL', 'Buena experiencia inicial'),
    (1, '2026-11-01', 'EMPRESA', 4, NULL, 'PARCIAL', 'Buen desempeno inicial'),
    (2, '2026-11-02', 'ESTUDIANTE', NULL, 3, 'PARCIAL', 'Necesita ajustar horarios'),
    (2, '2026-11-02', 'EMPRESA', 4, NULL, 'PARCIAL', 'Buen desempeno'),
    (3, '2026-09-30', 'ESTUDIANTE', NULL, 5, 'SATISFACTORIA', 'Experiencia positiva'),
    (3, '2026-09-30', 'EMPRESA', 5, NULL, 'APROBADA', 'Desempeno destacado'),
    (4, '2026-09-30', 'ESTUDIANTE', NULL, 4, 'SATISFACTORIA', 'Experiencia positiva'),
    (4, '2026-09-30', 'EMPRESA', 4, NULL, 'APROBADA', 'Buen desempeno'),
    (5, '2026-11-05', 'ESTUDIANTE', NULL, 4, 'PARCIAL', 'Buen inicio'),
    (5, '2026-11-05', 'EMPRESA', 4, NULL, 'PARCIAL', 'Buen inicio'),
    (6, '2026-09-30', 'ESTUDIANTE', NULL, 5, 'SATISFACTORIA', 'Experiencia positiva'),
    (6, '2026-09-30', 'EMPRESA', 4, NULL, 'APROBADA', 'Buen desempeno'),
    (7, '2026-11-07', 'ESTUDIANTE', NULL, 3, 'PARCIAL', 'Necesita acompanamiento'),
    (7, '2026-11-07', 'EMPRESA', 3, NULL, 'PARCIAL', 'Debe mejorar comunicacion'),
    (8, '2026-09-15', 'ESTUDIANTE', NULL, 2, 'INTERRUMPIDA', 'No pudo continuar'),
    (8, '2026-09-15', 'EMPRESA', 3, NULL, 'INTERRUMPIDA', 'Cierre anticipado'),
    (9, '2026-11-09', 'ESTUDIANTE', NULL, 4, 'PARCIAL', 'Buen inicio'),
    (9, '2026-11-09', 'EMPRESA', 4, NULL, 'PARCIAL', 'Buen inicio'),
    (10, '2026-11-10', 'ESTUDIANTE', NULL, 4, 'PARCIAL', 'Buen inicio'),
    (10, '2026-11-10', 'EMPRESA', 4, NULL, 'PARCIAL', 'Buen inicio');

INSERT INTO Auditoria_Cambios
    (tabla, id_registro, operacion, fecha, valor_anterior, valor_nuevo)
VALUES
    ('Postulacion', 1, 'UPDATE', '2026-09-15', 'ENTREVISTA', 'SELECCIONADA'),
    ('Postulacion', 2, 'UPDATE', '2026-09-16', 'ENTREVISTA', 'SELECCIONADA'),
    ('Postulacion', 3, 'UPDATE', '2026-09-17', 'ENTREVISTA', 'SELECCIONADA'),
    ('Postulacion', 4, 'UPDATE', '2026-09-18', 'ENTREVISTA', 'SELECCIONADA'),
    ('Postulacion', 5, 'UPDATE', '2026-09-19', 'ENTREVISTA', 'SELECCIONADA'),
    ('Practica', 3, 'UPDATE', '2026-09-30', 'EN_CURSO', 'FINALIZADA'),
    ('Practica', 4, 'UPDATE', '2026-09-30', 'EN_CURSO', 'FINALIZADA'),
    ('Practica', 6, 'UPDATE', '2026-09-30', 'EN_CURSO', 'FINALIZADA'),
    ('Practica', 8, 'UPDATE', '2026-09-15', 'EN_CURSO', 'INTERRUMPIDA'),
    ('Seguimiento', 7, 'UPDATE', '2026-10-19', 'EN_OBSERVACION', 'REQUIERE_INTERVENCION');
