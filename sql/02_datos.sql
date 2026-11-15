USE NexoAcademico;
GO

/* ================================================================
   DATOS DE PRUEBA
   Fecha de referencia ("hoy"): 2026-11-15. Ningun hecho consumado es posterior.

   IDs: se ejecuta sobre las tablas recien creadas por 01_estructura.sql
   (IDENTITY desde 1). Cada INSERT respeta el orden de las FK y las filas se
   listan en el orden de su ID, asi que los IDs que se referencian
   (id_carrera, id_estudiante, id_oferta, id_postulacion, id_practica, etc.)
   quedan garantizados. Si se vuelve a ejecutar, recrear la base antes.

   Auditoria_Cambios: los triggers son AFTER UPDATE, asi que un INSERT no los
   dispara. Se cargan a mano solo filas de Seguimiento y Evaluacion (correcciones
   de estado posteriores a la carga, coherentes con el valor final de cada fila).
   Las altas/cambios de Postulacion y Practica no se auditan a mano: los
   registran Postulacion_Estado_Historial e Historial_Practica, y los triggers
   los auditaran cuando los procedimientos hagan los UPDATE.

   Mapa de IDs usado por todo el script:
     Practica k = Postulacion k (k = 1..11); Estudiante k <-> Carrera k (k = 1..10).
   ================================================================ */

SET XACT_ABORT ON;
BEGIN TRAN;

INSERT INTO Carrera (nombre, unidad_academica, plan_estudios, nivel)
VALUES
    ('Ingeniería en Informática', 'FAIN', 'Plan 2026', 'GRADO'),
    ('Licenciatura en Sistemas', 'FAIN', 'Plan 2025', 'GRADO'),
    ('Abogacía', 'FACE', 'Plan 2024', 'GRADO'),
    ('Contador Público', 'FACE', 'Plan 2025', 'GRADO'),
    ('Administración de Empresas', 'FACE', 'Plan 2026', 'GRADO'),
    ('Marketing', 'FACE', 'Plan 2025', 'GRADO'),
    ('Recursos Humanos', 'FACE', 'Plan 2024', 'GRADO'),
    ('Diseño Gráfico', 'FADI', 'Plan 2026', 'GRADO'),
    ('Comercio Internacional', 'FACE', 'Plan 2025', 'GRADO'),
    ('Ingeniería Industrial', 'FAIN', 'Plan 2026', 'GRADO');

-- Materias: carrera n tiene los ids 2n-1 y 2n
INSERT INTO Materia (id_carrera, codigo, nombre)
VALUES
    (1, 'INF101', 'Programación I'),
    (1, 'INF102', 'Base de Datos I'),
    (2, 'SIS101', 'Análisis de Sistemas'),
    (2, 'SIS102', 'Gestión de Proyectos'),
    (3, 'DER101', 'Derecho Civil'),
    (3, 'DER102', 'Derecho Laboral'),
    (4, 'CON101', 'Contabilidad I'),
    (4, 'CON102', 'Impuestos I'),
    (5, 'ADM101', 'Administración General'),
    (5, 'ADM102', 'Finanzas'),
    (6, 'MKT101', 'Marketing Digital'),
    (6, 'MKT102', 'Investigación de Mercados'),
    (7, 'RRH101', 'Gestión de Personas'),
    (7, 'RRH102', 'Selección de Personal'),
    (8, 'DIS101', 'Diseño Visual'),
    (8, 'DIS102', 'Herramientas Digitales'),
    (9, 'COM101', 'Operatoria Internacional'),
    (9, 'COM102', 'Logística Internacional'),
    (10, 'IND101', 'Procesos Industriales'),
    (10, 'IND102', 'Gestión de Calidad');

INSERT INTO Estudiante (legajo, nombre, apellido, email)
VALUES
    ('10001', 'Ana', 'Pérez', 'ana.perez@ejemplo.edu'),
    ('10002', 'Bruno', 'López', 'bruno.lopez@ejemplo.edu'),
    ('10003', 'Carla', 'Gómez', 'carla.gomez@ejemplo.edu'),
    ('10004', 'Diego', 'Ruiz', 'diego.ruiz@ejemplo.edu'),
    ('10005', 'Elena', 'Torres', 'elena.torres@ejemplo.edu'),
    ('10006', 'Facundo', 'Díaz', 'facundo.diaz@ejemplo.edu'),
    ('10007', 'Gabriela', 'Sosa', 'gabriela.sosa@ejemplo.edu'),
    ('10008', 'Hugo', 'Castro', 'hugo.castro@ejemplo.edu'),
    ('10009', 'Irene', 'Molina', 'irene.molina@ejemplo.edu'),
    ('10010', 'Juan', 'Romero', 'juan.romero@ejemplo.edu'),
    ('10011', 'Karina', 'Vega', 'karina.vega@ejemplo.edu'),
    ('10012', 'Lucas', 'Benítez', 'lucas.benitez@ejemplo.edu');

-- Ana (1): EGRESADA en Sistemas y ACTIVA en Informática. Diego (4): ACTIVO en Contador y en Administración.
-- Karina (11): EGRESADA. Lucas (12): INACTIVO.
INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado)
VALUES
    (1, 1, 2023, 'ACTIVO'),
    (1, 2, 2019, 'EGRESADO'),
    (2, 2, 2022, 'ACTIVO'),
    (3, 3, 2021, 'ACTIVO'),
    (4, 4, 2023, 'ACTIVO'),
    (4, 5, 2024, 'ACTIVO'),
    (5, 5, 2022, 'ACTIVO'),
    (6, 6, 2024, 'ACTIVO'),
    (7, 7, 2021, 'ACTIVO'),
    (8, 8, 2023, 'ACTIVO'),
    (9, 9, 2022, 'ACTIVO'),
    (10, 10, 2024, 'ACTIVO'),
    (11, 3, 2018, 'EGRESADO'),
    (12, 2, 2020, 'INACTIVO');

-- Avance variado: Ana 100% en Sistemas y 50% en Informática; Diego 50% en Contador y 0% en Administración.
INSERT INTO Estudiante_Materia (id_estudiante, id_materia, fecha_aprobacion)
VALUES
    (1, 3, '2020-07-15'), (1, 4, '2021-07-15'), (1, 1, '2024-07-15'),
    (2, 3, '2023-07-15'),
    (3, 5, '2022-07-15'), (3, 6, '2023-07-15'),
    (4, 7, '2024-07-15'),
    (5, 9, '2023-07-15'), (5, 10, '2024-07-15'),
    (6, 11, '2025-07-15'),
    (7, 13, '2022-07-15'), (7, 14, '2023-07-15'),
    (8, 15, '2024-07-15'),
    (9, 17, '2023-07-15'), (9, 18, '2024-07-15'),
    (10, 19, '2025-07-15'),
    (11, 5, '2019-07-15'), (11, 6, '2020-07-15'),
    (12, 3, '2021-07-15');

INSERT INTO Competencia (nombre, categoria, descripcion)
VALUES
    ('SQL', 'TECNICA', 'Consultas y modelado de datos'),
    ('Programación', 'TECNICA', 'Desarrollo de soluciones de software'),
    ('Análisis jurídico', 'PROFESIONAL', 'Interpretación y análisis normativo'),
    ('Contabilidad', 'PROFESIONAL', 'Registro y análisis contable'),
    ('Gestión de proyectos', 'TRANSVERSAL', 'Planificación y seguimiento de proyectos'),
    ('Marketing digital', 'PROFESIONAL', 'Campañas y canales digitales'),
    ('Selección de personal', 'PROFESIONAL', 'Procesos de búsqueda y selección'),
    ('Diseño visual', 'TECNICA', 'Comunicación mediante recursos visuales'),
    ('Logística', 'PROFESIONAL', 'Gestión de operaciones y distribución'),
    ('Comunicación', 'TRANSVERSAL', 'Comunicación oral y escrita');

INSERT INTO Estudiante_Competencia (id_estudiante, id_competencia, nivel_declarado)
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
    (10, 9, 2), (10, 5, 2),
    (11, 3, 3), (11, 10, 2),
    (12, 1, 1);

-- Empresa 11: PROSPECTO sin convenio. Empresa 12: SUSPENDIDA.
INSERT INTO Empresa (cuit, razon_social, sector, tamano, ciudad, estado_vinculo)
VALUES
    ('30-10000001-1', 'Datos del Sur SA', 'Tecnología', 'MEDIANA', 'CABA', 'ACTIVA'),
    ('30-10000002-2', 'Sistemas Río SRL', 'Tecnología', 'PEQUEÑA', 'CABA', 'ACTIVA'),
    ('30-10000003-3', 'Estudio Legal Centro', 'Servicios legales', 'PEQUEÑA', 'CABA', 'ACTIVA'),
    ('30-10000004-4', 'Contables Asociados', 'Contabilidad', 'MEDIANA', 'Rosario', 'ACTIVA'),
    ('30-10000005-5', 'Gestión Federal SA', 'Consultoría', 'GRANDE', 'CABA', 'ACTIVA'),
    ('30-10000006-6', 'Mercado Creativo SRL', 'Marketing', 'PEQUEÑA', 'Córdoba', 'ACTIVA'),
    ('30-10000007-7', 'Personas Primero SA', 'Recursos humanos', 'MEDIANA', 'CABA', 'ACTIVA'),
    ('30-10000008-8', 'Estudio Visual SRL', 'Diseño', 'PEQUEÑA', 'La Plata', 'ACTIVA'),
    ('30-10000009-9', 'Comercio Global SA', 'Comercio exterior', 'GRANDE', 'CABA', 'ACTIVA'),
    ('30-10000010-0', 'Industria Nacional SA', 'Industria', 'GRANDE', 'Pilar', 'ACTIVA'),
    ('30-10000011-1', 'Servicios del Centro SRL', 'Servicios', 'PEQUEÑA', 'CABA', 'PROSPECTO'),
    ('30-10000012-2', 'Textil Andina SA', 'Industria textil', 'MEDIANA', 'Mendoza', 'SUSPENDIDA');

-- Convenio 4: VENCIDO (termino 2025-12-31). Convenio 11: SUSPENDIDO (empresa 12). El resto VIGENTE.
INSERT INTO Convenio (id_empresa, fecha_inicio, fecha_fin, estado, objetivo, cupos_referenciales)
VALUES
    (1, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas de datos', 5),
    (2, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas de sistemas', 5),
    (3, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas jurídicas', 3),
    (4, '2024-01-01', '2025-12-31', 'VENCIDO', 'Prácticas contables', 4),
    (5, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas de gestión', 5),
    (6, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas de marketing', 4),
    (7, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas de recursos humanos', 4),
    (8, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas de diseño', 3),
    (9, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas de comercio exterior', 5),
    (10, '2026-01-01', '2028-12-31', 'VIGENTE', 'Prácticas industriales', 6),
    (12, '2025-03-01', '2027-02-28', 'SUSPENDIDO', 'Prácticas de producción textil', 2);

-- Ofertas 11 y 12: BORRADOR (fecha_publicacion NULL); la 11 sin convenio. Ofertas 3, 4 y 8: CERRADA. Oferta 13: CANCELADA.
INSERT INTO Oferta
    (id_empresa, id_convenio, titulo, descripcion, fecha_publicacion,
     fecha_cierre, vacantes, modalidad, jornada, estado)
VALUES
    (1, 1, 'Asistente de datos', 'Apoyo en consultas y reportes', '2026-07-01', '2027-06-30', 2, 'HIBRIDA', '20 horas', 'PUBLICADA'),
    (2, 2, 'Analista funcional junior', 'Apoyo en relevamiento funcional', '2026-07-02', '2027-06-30', 2, 'REMOTA', '20 horas', 'PUBLICADA'),
    (3, 3, 'Asistente legal', 'Apoyo en investigación jurídica', '2026-02-02', '2026-03-31', 1, 'PRESENCIAL', '20 horas', 'CERRADA'),
    (4, 4, 'Auxiliar contable', 'Registración y conciliaciones', '2025-03-03', '2025-04-30', 1, 'HIBRIDA', '20 horas', 'CERRADA'),
    (5, 5, 'Asistente de proyectos', 'Seguimiento de proyectos internos', '2026-07-08', '2027-06-30', 2, 'HIBRIDA', '24 horas', 'PUBLICADA'),
    (6, 6, 'Asistente de marketing', 'Apoyo en campañas digitales', '2026-02-09', '2027-02-28', 2, 'REMOTA', '20 horas', 'PUBLICADA'),
    (7, 7, 'Asistente de selección', 'Apoyo en búsquedas laborales', '2026-07-13', '2027-06-30', 2, 'HIBRIDA', '20 horas', 'PUBLICADA'),
    (8, 8, 'Diseñador junior', 'Producción de piezas visuales', '2026-05-04', '2026-06-05', 1, 'REMOTA', '20 horas', 'CERRADA'),
    (9, 9, 'Asistente de comercio exterior', 'Seguimiento documental de operaciones', '2026-07-20', '2027-06-30', 2, 'HIBRIDA', '20 horas', 'PUBLICADA'),
    (10, 10, 'Asistente de procesos', 'Relevamiento de procesos productivos', '2026-07-22', '2027-06-30', 2, 'PRESENCIAL', '24 horas', 'PUBLICADA'),
    (11, NULL, 'Asistente administrativo', 'Apoyo administrativo (borrador, sin convenio)', NULL, '2027-03-31', 1, 'PRESENCIAL', '20 horas', 'BORRADOR'),
    (1, 1, 'Analista de BI junior', 'Tableros e indicadores (borrador)', NULL, '2027-03-31', 1, 'REMOTA', '20 horas', 'BORRADOR'),
    (12, 11, 'Asistente de producción', 'Control de planta textil', '2026-02-02', '2026-06-30', 1, 'PRESENCIAL', '24 horas', 'CANCELADA');

INSERT INTO Oferta_Carrera (id_oferta, id_carrera, pertinencia, criterio_pertinencia)
VALUES
    (1, 1, 'ALTA', 'Tareas de consultas SQL y reportes propias de la carrera'),
    (1, 2, 'MEDIA', 'Análisis de datos como complemento del perfil de sistemas'),
    (2, 2, 'ALTA', 'Relevamiento funcional es el núcleo de la carrera'),
    (2, 1, 'BAJA', 'Perfil orientado al desarrollo, poco relevamiento funcional'),
    (3, 3, 'ALTA', 'Investigación jurídica directa'),
    (4, 4, 'ALTA', 'Registración contable directa'),
    (4, 5, 'MEDIA', 'Conciliaciones vinculadas a finanzas de la empresa'),
    (5, 5, 'ALTA', 'Gestión de proyectos internos'),
    (5, 10, 'MEDIA', 'Seguimiento de proyectos con enfoque de procesos'),
    (6, 6, 'ALTA', 'Campañas digitales'),
    (6, 8, 'MEDIA', 'Piezas gráficas para las campañas'),
    (7, 7, 'ALTA', 'Búsqueda y selección de personal'),
    (7, 6, 'MEDIA', 'Comunicación de la marca empleadora'),
    (8, 8, 'ALTA', 'Producción de piezas visuales'),
    (8, 6, 'MEDIA', 'Contenido para redes'),
    (9, 9, 'ALTA', 'Operaciones de comercio exterior'),
    (9, 10, 'BAJA', 'Aporte logístico limitado'),
    (10, 10, 'ALTA', 'Relevamiento de procesos productivos'),
    (10, 5, 'MEDIA', 'Mejora de procesos desde la administración'),
    (11, 5, 'MEDIA', 'Tareas administrativas generales'),
    (12, 1, 'ALTA', 'Modelado y explotación de datos'),
    (13, 3, 'MEDIA', 'Normativa laboral y de planta');

INSERT INTO Oferta_Competencia (id_oferta, id_competencia, nivel_requerido, obligatoria)
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
    (10, 9, 2, 1), (10, 5, 2, 0),
    (11, 5, 1, 0), (11, 10, 1, 0),
    (12, 1, 3, 1), (12, 2, 2, 0),
    (13, 3, 1, 0);

-- Postulaciones: 1-10 SELECCIONADA (una por estudiante/oferta), 11 SELECCIONADA (Diego, 2da carrera),
-- 12 RECHAZADA tras entrevista, 13 EN_REVISION, 14 ENTREVISTA, 15 RETIRADA, 16 RECIBIDA, 17 RECHAZADA sin entrevista.
-- Selecciones por oferta: o1 1/2, o2 1/2, o3 1/1, o4 1/1, o5 2/2 (Elena y Diego), o6 1/2, o7 1/2, o8 1/1, o9 1/2, o10 1/2.
INSERT INTO Postulacion
    (id_estudiante, id_oferta, id_carrera, fecha, estado, origen, observaciones)
VALUES
    (1, 1, 1, '2026-07-20 09:00', 'SELECCIONADA', 'CV', 'Perfil con SQL avanzado'),
    (2, 2, 2, '2026-07-22 10:00', 'SELECCIONADA', 'PORTAL', 'Postulación desde el portal'),
    (3, 3, 3, '2026-02-16 09:30', 'SELECCIONADA', 'REFERIDO', 'Referida por un docente'),
    (4, 4, 4, '2025-03-10 11:00', 'SELECCIONADA', 'FERIA', 'Contacto en la feria de empleo'),
    (5, 5, 5, '2026-08-03 09:00', 'SELECCIONADA', 'CV', 'Perfil de gestión de proyectos'),
    (6, 6, 6, '2026-02-20 14:00', 'SELECCIONADA', 'PORTAL', 'Postulación desde el portal'),
    (7, 7, 7, '2026-08-10 10:00', 'SELECCIONADA', 'CV', 'Perfil de selección de personal'),
    (8, 8, 8, '2026-05-18 09:00', 'SELECCIONADA', 'REFERIDO', 'Referido por la empresa'),
    (9, 9, 9, '2026-08-17 10:30', 'SELECCIONADA', 'PORTAL', 'Postulación desde el portal'),
    (10, 10, 10, '2026-08-24 09:00', 'SELECCIONADA', 'FERIA', 'Contacto en la feria de empleo'),
    (4, 5, 5, '2026-10-20 09:00', 'SELECCIONADA', 'PORTAL', 'Segunda carrera del estudiante'),
    (2, 1, 2, '2026-07-25 15:00', 'RECHAZADA', 'CV', 'Postulación a una segunda oferta'),
    (8, 6, 8, '2026-11-03 10:00', 'EN_REVISION', 'PORTAL', 'Perfil en revisión'),
    (5, 10, 5, '2026-11-02 11:00', 'ENTREVISTA', 'CV', 'Entrevista técnica coordinada'),
    (6, 7, 6, '2026-08-18 09:00', 'RETIRADA', 'FERIA', 'Contacto en la feria de empleo'),
    (10, 5, 10, '2026-11-12 16:00', 'RECIBIDA', 'REFERIDO', 'Postulación recibida'),
    (1, 2, 1, '2026-08-01 10:00', 'RECHAZADA', 'PORTAL', 'Postulación desde el portal');

-- Historial legal segun la maquina de estados; cada cambio es posterior a la oferta y a la postulacion.
INSERT INTO Postulacion_Estado_Historial
    (id_postulacion, estado_anterior, estado_nuevo, fecha_cambio, motivo)
VALUES
    (1, NULL, 'RECIBIDA', '2026-07-20 09:00', 'Postulación registrada'),
    (1, 'RECIBIDA', 'EN_REVISION', '2026-07-24 11:00', 'Perfil enviado a la empresa'),
    (1, 'EN_REVISION', 'ENTREVISTA', '2026-08-03 09:00', 'Entrevista coordinada'),
    (1, 'ENTREVISTA', 'SELECCIONADA', '2026-08-17 15:00', 'Aprobó la entrevista y cumple el perfil'),
    (2, NULL, 'RECIBIDA', '2026-07-22 10:00', 'Postulación registrada'),
    (2, 'RECIBIDA', 'EN_REVISION', '2026-07-27 11:00', 'Perfil enviado a la empresa'),
    (2, 'EN_REVISION', 'ENTREVISTA', '2026-08-05 09:00', 'Entrevista coordinada'),
    (2, 'ENTREVISTA', 'SELECCIONADA', '2026-08-20 15:00', 'Aprobó la entrevista técnica'),
    (3, NULL, 'RECIBIDA', '2026-02-16 09:30', 'Postulación registrada'),
    (3, 'RECIBIDA', 'EN_REVISION', '2026-02-18 11:00', 'Perfil enviado a la empresa'),
    (3, 'EN_REVISION', 'ENTREVISTA', '2026-02-20 09:00', 'Entrevista coordinada'),
    (3, 'ENTREVISTA', 'SELECCIONADA', '2026-03-02 15:00', 'Aprobó la entrevista con RR. HH.'),
    (4, NULL, 'RECIBIDA', '2025-03-10 11:00', 'Postulación registrada'),
    (4, 'RECIBIDA', 'EN_REVISION', '2025-03-12 11:00', 'Perfil enviado a la empresa'),
    (4, 'EN_REVISION', 'ENTREVISTA', '2025-03-17 09:00', 'Entrevista coordinada'),
    (4, 'ENTREVISTA', 'SELECCIONADA', '2025-04-02 15:00', 'Aprobó la entrevista final'),
    (5, NULL, 'RECIBIDA', '2026-08-03 09:00', 'Postulación registrada'),
    (5, 'RECIBIDA', 'EN_REVISION', '2026-08-06 11:00', 'Perfil enviado a la empresa'),
    (5, 'EN_REVISION', 'ENTREVISTA', '2026-08-12 09:00', 'Entrevistas coordinadas'),
    (5, 'ENTREVISTA', 'SELECCIONADA', '2026-08-28 15:00', 'Aprobó las dos entrevistas'),
    (6, NULL, 'RECIBIDA', '2026-02-20 14:00', 'Postulación registrada'),
    (6, 'RECIBIDA', 'EN_REVISION', '2026-02-23 11:00', 'Perfil enviado a la empresa'),
    (6, 'EN_REVISION', 'ENTREVISTA', '2026-03-02 09:00', 'Entrevista coordinada'),
    (6, 'ENTREVISTA', 'SELECCIONADA', '2026-03-11 15:00', 'Aprobó la entrevista'),
    (7, NULL, 'RECIBIDA', '2026-08-10 10:00', 'Postulación registrada'),
    (7, 'RECIBIDA', 'EN_REVISION', '2026-08-12 11:00', 'Perfil enviado a la empresa'),
    (7, 'EN_REVISION', 'ENTREVISTA', '2026-08-19 09:00', 'Entrevistas coordinadas'),
    (7, 'ENTREVISTA', 'SELECCIONADA', '2026-09-02 15:00', 'Aprobó las dos entrevistas'),
    (8, NULL, 'RECIBIDA', '2026-05-18 09:00', 'Postulación registrada'),
    (8, 'RECIBIDA', 'EN_REVISION', '2026-05-20 11:00', 'Perfil enviado a la empresa'),
    (8, 'EN_REVISION', 'ENTREVISTA', '2026-05-25 09:00', 'Entrevista coordinada'),
    (8, 'ENTREVISTA', 'SELECCIONADA', '2026-06-01 15:00', 'Aprobó la entrevista técnica'),
    (9, NULL, 'RECIBIDA', '2026-08-17 10:30', 'Postulación registrada'),
    (9, 'RECIBIDA', 'EN_REVISION', '2026-08-19 11:00', 'Perfil enviado a la empresa'),
    (9, 'EN_REVISION', 'ENTREVISTA', '2026-08-26 09:00', 'Entrevista coordinada'),
    (9, 'ENTREVISTA', 'SELECCIONADA', '2026-09-09 15:00', 'Aprobó la entrevista con RR. HH.'),
    (10, NULL, 'RECIBIDA', '2026-08-24 09:00', 'Postulación registrada'),
    (10, 'RECIBIDA', 'EN_REVISION', '2026-08-26 11:00', 'Perfil enviado a la empresa'),
    (10, 'EN_REVISION', 'ENTREVISTA', '2026-09-02 09:00', 'Entrevista coordinada'),
    (10, 'ENTREVISTA', 'SELECCIONADA', '2026-09-16 15:00', 'Aprobó la entrevista'),
    (11, NULL, 'RECIBIDA', '2026-10-20 09:00', 'Postulación registrada'),
    (11, 'RECIBIDA', 'EN_REVISION', '2026-10-23 11:00', 'Perfil enviado a la empresa'),
    (11, 'EN_REVISION', 'ENTREVISTA', '2026-10-27 09:00', 'Entrevista coordinada'),
    (11, 'ENTREVISTA', 'SELECCIONADA', '2026-11-05 15:00', 'Aprobó la entrevista técnica'),
    (12, NULL, 'RECIBIDA', '2026-07-25 15:00', 'Postulación registrada'),
    (12, 'RECIBIDA', 'EN_REVISION', '2026-07-28 11:00', 'Perfil enviado a la empresa'),
    (12, 'EN_REVISION', 'ENTREVISTA', '2026-08-04 09:00', 'Entrevista coordinada'),
    (12, 'ENTREVISTA', 'RECHAZADA', '2026-08-10 12:00', 'Nivel de SQL insuficiente para el puesto'),
    (13, NULL, 'RECIBIDA', '2026-11-03 10:00', 'Postulación registrada'),
    (13, 'RECIBIDA', 'EN_REVISION', '2026-11-06 11:00', 'Perfil enviado a la empresa'),
    (14, NULL, 'RECIBIDA', '2026-11-02 11:00', 'Postulación registrada'),
    (14, 'RECIBIDA', 'EN_REVISION', '2026-11-05 11:00', 'Perfil enviado a la empresa'),
    (14, 'EN_REVISION', 'ENTREVISTA', '2026-11-10 09:00', 'Entrevista técnica coordinada para el 2026-11-18'),
    (15, NULL, 'RECIBIDA', '2026-08-18 09:00', 'Postulación registrada'),
    (15, 'RECIBIDA', 'EN_REVISION', '2026-08-20 11:00', 'Perfil enviado a la empresa'),
    (15, 'EN_REVISION', 'RETIRADA', '2026-08-28 17:00', 'El estudiante retiró la postulación por superposición horaria con la cursada'),
    (16, NULL, 'RECIBIDA', '2026-11-12 16:00', 'Postulación registrada'),
    (17, NULL, 'RECIBIDA', '2026-08-01 10:00', 'Postulación registrada'),
    (17, 'RECIBIDA', 'EN_REVISION', '2026-08-04 11:00', 'Perfil enviado a la empresa'),
    (17, 'EN_REVISION', 'RECHAZADA', '2026-08-12 12:00', 'Pertinencia baja: falta la competencia obligatoria Gestión de proyectos');

-- La entrevista de la postulacion 14 (id 15) es futura (PENDIENTE): aun no es un hecho consumado.
INSERT INTO Entrevista (id_postulacion, fecha, etapa, resultado, devolucion)
VALUES
    (1, '2026-08-05 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (2, '2026-08-07 10:00', 'TECNICA', 'APROBADA', 'Buen manejo del relevamiento funcional'),
    (3, '2026-02-23 10:00', 'RRHH', 'APROBADA', 'Buena comunicación'),
    (4, '2025-03-19 10:00', 'FINAL', 'APROBADA', 'Perfil adecuado'),
    (5, '2026-08-14 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (5, '2026-08-21 10:00', 'TECNICA', 'APROBADA', 'Dominio de gestión de proyectos'),
    (6, '2026-03-04 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (7, '2026-08-21 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (7, '2026-08-26 10:00', 'FINAL', 'APROBADA', 'Confirmado por la empresa'),
    (8, '2026-05-27 10:00', 'TECNICA', 'APROBADA', 'Buen nivel de diseño'),
    (9, '2026-08-28 10:00', 'RRHH', 'APROBADA', 'Perfil adecuado'),
    (10, '2026-09-04 10:00', 'GENERAL', 'APROBADA', 'Perfil adecuado'),
    (11, '2026-10-29 10:00', 'TECNICA', 'APROBADA', 'Perfil adecuado'),
    (12, '2026-08-06 10:00', 'TECNICA', 'RECHAZADA', 'Nivel de SQL insuficiente'),
    (14, '2026-11-18 10:00', 'TECNICA', 'PENDIENTE', 'Entrevista programada');

-- Practica k = Postulacion k. 1,2,5,7,9,10 EN_CURSO; 3,4,6 FINALIZADA; 8 INTERRUMPIDA; 11 PLANIFICADA.
-- Una sola practica activa por estudiante: Diego (4) tiene la 4 FINALIZADA (2025) y la 11 PLANIFICADA.
INSERT INTO Practica
    (id_postulacion, fecha_inicio, fecha_fin_prevista, fecha_fin_real,
     horas_semanales, modalidad, estado, motivo_cierre)
VALUES
    (1, '2026-09-01', '2027-02-26', NULL, 20, 'HIBRIDA', 'EN_CURSO', NULL),
    (2, '2026-09-01', '2027-02-26', NULL, 20, 'REMOTA', 'EN_CURSO', NULL),
    (3, '2026-03-16', '2026-09-30', '2026-09-30', 20, 'PRESENCIAL', 'FINALIZADA', 'Finalización prevista'),
    (4, '2025-05-05', '2025-11-28', '2025-11-28', 20, 'HIBRIDA', 'FINALIZADA', 'Finalización prevista'),
    (5, '2026-09-14', '2027-03-12', NULL, 24, 'HIBRIDA', 'EN_CURSO', NULL),
    (6, '2026-03-30', '2026-10-30', '2026-10-30', 20, 'REMOTA', 'FINALIZADA', 'Finalización prevista'),
    (7, '2026-09-21', '2027-03-19', NULL, 20, 'HIBRIDA', 'EN_CURSO', NULL),
    (8, '2026-06-15', '2026-12-15', '2026-09-10', 20, 'REMOTA', 'INTERRUMPIDA', 'Cambio de disponibilidad horaria del estudiante'),
    (9, '2026-09-28', '2027-03-26', NULL, 20, 'HIBRIDA', 'EN_CURSO', NULL),
    (10, '2026-10-01', '2027-03-31', NULL, 24, 'PRESENCIAL', 'EN_CURSO', NULL),
    (11, '2026-12-01', '2027-05-31', NULL, 20, 'HIBRIDA', 'PLANIFICADA', NULL);

-- Cada practica: NULL->PLANIFICADA (alta, posterior a la seleccion) y PLANIFICADA->EN_CURSO (fecha de inicio);
-- las cerradas suman el cierre. Nada posterior a una interrupcion.
INSERT INTO Historial_Practica
    (id_practica, estado_anterior, estado_nuevo, fecha_cambio, motivo)
VALUES
    (1, NULL, 'PLANIFICADA', '2026-08-20 10:00', 'Práctica creada tras la selección'),
    (1, 'PLANIFICADA', 'EN_CURSO', '2026-09-01 08:00', 'Inicio de la práctica'),
    (2, NULL, 'PLANIFICADA', '2026-08-24 10:00', 'Práctica creada tras la selección'),
    (2, 'PLANIFICADA', 'EN_CURSO', '2026-09-01 08:00', 'Inicio de la práctica'),
    (3, NULL, 'PLANIFICADA', '2026-03-05 10:00', 'Práctica creada tras la selección'),
    (3, 'PLANIFICADA', 'EN_CURSO', '2026-03-16 08:00', 'Inicio de la práctica'),
    (3, 'EN_CURSO', 'FINALIZADA', '2026-09-30 18:00', 'Finalización prevista'),
    (4, NULL, 'PLANIFICADA', '2025-04-10 10:00', 'Práctica creada tras la selección'),
    (4, 'PLANIFICADA', 'EN_CURSO', '2025-05-05 08:00', 'Inicio de la práctica'),
    (4, 'EN_CURSO', 'FINALIZADA', '2025-11-28 18:00', 'Finalización prevista'),
    (5, NULL, 'PLANIFICADA', '2026-09-01 10:00', 'Práctica creada tras la selección'),
    (5, 'PLANIFICADA', 'EN_CURSO', '2026-09-14 08:00', 'Inicio de la práctica'),
    (6, NULL, 'PLANIFICADA', '2026-03-16 10:00', 'Práctica creada tras la selección'),
    (6, 'PLANIFICADA', 'EN_CURSO', '2026-03-30 08:00', 'Inicio de la práctica'),
    (6, 'EN_CURSO', 'FINALIZADA', '2026-10-30 18:00', 'Finalización prevista'),
    (7, NULL, 'PLANIFICADA', '2026-09-07 10:00', 'Práctica creada tras la selección'),
    (7, 'PLANIFICADA', 'EN_CURSO', '2026-09-21 08:00', 'Inicio de la práctica'),
    (8, NULL, 'PLANIFICADA', '2026-06-05 10:00', 'Práctica creada tras la selección'),
    (8, 'PLANIFICADA', 'EN_CURSO', '2026-06-15 08:00', 'Inicio de la práctica'),
    (8, 'EN_CURSO', 'INTERRUMPIDA', '2026-09-10 12:00', 'Cambio de disponibilidad horaria del estudiante'),
    (9, NULL, 'PLANIFICADA', '2026-09-14 10:00', 'Práctica creada tras la selección'),
    (9, 'PLANIFICADA', 'EN_CURSO', '2026-09-28 08:00', 'Inicio de la práctica'),
    (10, NULL, 'PLANIFICADA', '2026-09-21 10:00', 'Práctica creada tras la selección'),
    (10, 'PLANIFICADA', 'EN_CURSO', '2026-10-01 08:00', 'Inicio de la práctica'),
    (11, NULL, 'PLANIFICADA', '2026-11-10 10:00', 'Práctica creada tras la selección');

-- Ultimo seguimiento: practica 2 EN_OBSERVACION (revision vencida), practica 7 REQUIERE_INTERVENCION (revision vencida,
-- aparece en la vista de intervencion); practica 9 tuvo REQUIERE_INTERVENCION pero el ULTIMO es SIN_NOVEDADES (no aparece);
-- practica 8 REQUIERE_INTERVENCION pero INTERRUMPIDA (no aparece).
INSERT INTO Seguimiento
    (id_practica, fecha, tipo_seguimiento, origen_feedback,
     estado_seguimiento, observaciones, intervencion_facultad, proxima_revision)
VALUES
    (1, '2026-09-15', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-10-15'),
    (1, '2026-10-15', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2026-12-15'),
    (2, '2026-09-15', 'INICIAL', 'EMPRESA', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-10-15'),
    (2, '2026-10-16', 'PERIODICO', 'ESTUDIANTE', 'EN_OBSERVACION', 'Requiere ajustar horarios', 'Revisar horarios con la empresa', '2026-11-01'),
    (3, '2026-03-30', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-06-15'),
    (3, '2026-06-15', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2026-09-15'),
    (3, '2026-09-30', 'CIERRE', 'AMBOS', 'SIN_NOVEDADES', 'Cierre sin observaciones', NULL, NULL),
    (4, '2025-05-19', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2025-08-18'),
    (4, '2025-08-18', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2025-11-17'),
    (4, '2025-11-28', 'CIERRE', 'AMBOS', 'SIN_NOVEDADES', 'Cierre sin observaciones', NULL, NULL),
    (5, '2026-09-28', 'INICIAL', 'EMPRESA', 'SIN_NOVEDADES', 'Buen inicio', NULL, '2026-11-02'),
    (5, '2026-11-02', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2026-12-02'),
    (6, '2026-04-13', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-07-13'),
    (6, '2026-07-13', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Desarrollo normal', NULL, '2026-10-13'),
    (6, '2026-10-30', 'CIERRE', 'AMBOS', 'SIN_NOVEDADES', 'Cierre sin observaciones', NULL, NULL),
    (7, '2026-10-05', 'INICIAL', 'AMBOS', 'EN_OBSERVACION', 'Dificultad de comunicación con el tutor', 'Seguir la comunicación', '2026-10-19'),
    (7, '2026-10-19', 'EXTRAORDINARIO', 'AMBOS', 'REQUIERE_INTERVENCION', 'La dificultad de comunicación persiste', 'Coordinar una reunión con el tutor', '2026-10-26'),
    (8, '2026-06-29', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-07-27'),
    (8, '2026-07-27', 'PERIODICO', 'ESTUDIANTE', 'EN_OBSERVACION', 'Dificultad con los horarios', 'Revisar disponibilidad', '2026-08-24'),
    (8, '2026-08-24', 'EXTRAORDINARIO', 'ESTUDIANTE', 'REQUIERE_INTERVENCION', 'Posible interrupción', 'Analizar alternativas', '2026-09-07'),
    (9, '2026-10-12', 'INICIAL', 'AMBOS', 'REQUIERE_INTERVENCION', 'Falta de accesos a los sistemas', 'Gestionar accesos con la empresa', '2026-10-26'),
    (9, '2026-11-02', 'PERIODICO', 'AMBOS', 'SIN_NOVEDADES', 'Accesos resueltos', NULL, '2026-12-02'),
    (10, '2026-10-15', 'INICIAL', 'AMBOS', 'SIN_NOVEDADES', 'Inicio normal', NULL, '2026-11-30');

-- Practicas FINALIZADA (3, 4, 6): PARCIAL y FINAL de ESTUDIANTE y de EMPRESA.
-- La 8 (INTERRUMPIDA) solo tiene evaluaciones PARCIAL anteriores a la interrupcion.
-- Estudiante cargan puntaje_satisfaccion; Empresa carga puntaje_desempeno.
INSERT INTO Evaluacion
    (id_practica, fecha, tipo_evaluador, instancia, puntaje_desempeno,
     puntaje_satisfaccion, resultado, comentarios)
VALUES
    (1, '2026-11-02 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 4, 'SATISFACTORIA', 'Buena experiencia inicial'),
    (1, '2026-11-02 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen desempeño inicial'),
    (2, '2026-11-02 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 3, 'A_MEJORAR', 'Necesita ajustar horarios'),
    (2, '2026-11-02 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen desempeño'),
    (3, '2026-06-20 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 4, 'SATISFACTORIA', 'Experiencia positiva'),
    (3, '2026-06-20 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen desempeño'),
    (3, '2026-09-28 11:00', 'ESTUDIANTE', 'FINAL', NULL, 5, 'SATISFACTORIA', 'Experiencia muy positiva'),
    (3, '2026-09-28 11:30', 'EMPRESA', 'FINAL', 5, NULL, 'SATISFACTORIA', 'Desempeño destacado'),
    (4, '2025-08-22 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 4, 'SATISFACTORIA', 'Experiencia positiva'),
    (4, '2025-08-22 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen desempeño'),
    (4, '2025-11-26 11:00', 'ESTUDIANTE', 'FINAL', NULL, 4, 'SATISFACTORIA', 'Experiencia positiva'),
    (4, '2025-11-26 11:30', 'EMPRESA', 'FINAL', 4, NULL, 'SATISFACTORIA', 'Buen desempeño'),
    (5, '2026-11-05 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 4, 'SATISFACTORIA', 'Buen inicio'),
    (5, '2026-11-05 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen inicio'),
    (6, '2026-07-20 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 5, 'SATISFACTORIA', 'Experiencia positiva'),
    (6, '2026-07-20 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen desempeño'),
    (6, '2026-10-29 11:00', 'ESTUDIANTE', 'FINAL', NULL, 5, 'SATISFACTORIA', 'Experiencia muy positiva'),
    (6, '2026-10-29 11:30', 'EMPRESA', 'FINAL', 4, NULL, 'SATISFACTORIA', 'Buen desempeño'),
    (7, '2026-11-07 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 3, 'A_MEJORAR', 'Necesita acompañamiento'),
    (7, '2026-11-07 11:30', 'EMPRESA', 'PARCIAL', 3, NULL, 'A_MEJORAR', 'Debe mejorar la comunicación'),
    (8, '2026-08-28 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 2, 'INSATISFACTORIA', 'Dificultad para sostener los horarios'),
    (8, '2026-08-28 11:30', 'EMPRESA', 'PARCIAL', 3, NULL, 'A_MEJORAR', 'Asistencia irregular'),
    (9, '2026-11-09 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 4, 'SATISFACTORIA', 'Buen inicio'),
    (9, '2026-11-09 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen inicio'),
    (10, '2026-11-10 11:00', 'ESTUDIANTE', 'PARCIAL', NULL, 4, 'SATISFACTORIA', 'Buen inicio'),
    (10, '2026-11-10 11:30', 'EMPRESA', 'PARCIAL', 4, NULL, 'SATISFACTORIA', 'Buen inicio');

-- Solo Seguimiento y Evaluacion; el valor_nuevo coincide con el valor final de la fila (ids por orden de insercion).
INSERT INTO Auditoria_Cambios
    (tabla, id_registro, fecha, valor_anterior, valor_nuevo)
VALUES
    ('Seguimiento', 4, '2026-10-16 17:00', 'SIN_NOVEDADES', 'EN_OBSERVACION'),
    ('Seguimiento', 17, '2026-10-20 09:00', 'EN_OBSERVACION', 'REQUIERE_INTERVENCION'),
    ('Seguimiento', 19, '2026-07-28 10:00', 'SIN_NOVEDADES', 'EN_OBSERVACION'),
    ('Seguimiento', 20, '2026-08-25 10:00', 'EN_OBSERVACION', 'REQUIERE_INTERVENCION'),
    ('Seguimiento', 21, '2026-10-13 10:00', 'EN_OBSERVACION', 'REQUIERE_INTERVENCION'),
    ('Evaluacion', 3, '2026-11-03 09:00', 'SATISFACTORIA', 'A_MEJORAR'),
    ('Evaluacion', 19, '2026-11-08 09:00', 'SATISFACTORIA', 'A_MEJORAR'),
    ('Evaluacion', 20, '2026-11-08 09:30', 'SATISFACTORIA', 'A_MEJORAR'),
    ('Evaluacion', 21, '2026-08-29 09:00', 'A_MEJORAR', 'INSATISFACTORIA'),
    ('Evaluacion', 22, '2026-08-29 09:30', 'SATISFACTORIA', 'A_MEJORAR');

COMMIT;
GO
