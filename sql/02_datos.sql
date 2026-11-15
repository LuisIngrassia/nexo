USE NexoAcademico;
GO

/* ================================================================
   DATOS DE PRUEBA (esquema del contrato F1)
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
    (N'Ingeniería en Informática', N'FAIN', N'Plan 2026', N'GRADO'),
    (N'Licenciatura en Sistemas', N'FAIN', N'Plan 2025', N'GRADO'),
    (N'Abogacía', N'FACE', N'Plan 2024', N'GRADO'),
    (N'Contador Público', N'FACE', N'Plan 2025', N'GRADO'),
    (N'Administración de Empresas', N'FACE', N'Plan 2026', N'GRADO'),
    (N'Marketing', N'FACE', N'Plan 2025', N'GRADO'),
    (N'Recursos Humanos', N'FACE', N'Plan 2024', N'GRADO'),
    (N'Diseño Gráfico', N'FADI', N'Plan 2026', N'GRADO'),
    (N'Comercio Internacional', N'FACE', N'Plan 2025', N'GRADO'),
    (N'Ingeniería Industrial', N'FAIN', N'Plan 2026', N'GRADO');

-- Materias: carrera n tiene los ids 2n-1 y 2n
INSERT INTO Materia (id_carrera, codigo, nombre)
VALUES
    (1, N'INF101', N'Programación I'),
    (1, N'INF102', N'Base de Datos I'),
    (2, N'SIS101', N'Análisis de Sistemas'),
    (2, N'SIS102', N'Gestión de Proyectos'),
    (3, N'DER101', N'Derecho Civil'),
    (3, N'DER102', N'Derecho Laboral'),
    (4, N'CON101', N'Contabilidad I'),
    (4, N'CON102', N'Impuestos I'),
    (5, N'ADM101', N'Administración General'),
    (5, N'ADM102', N'Finanzas'),
    (6, N'MKT101', N'Marketing Digital'),
    (6, N'MKT102', N'Investigación de Mercados'),
    (7, N'RRH101', N'Gestión de Personas'),
    (7, N'RRH102', N'Selección de Personal'),
    (8, N'DIS101', N'Diseño Visual'),
    (8, N'DIS102', N'Herramientas Digitales'),
    (9, N'COM101', N'Operatoria Internacional'),
    (9, N'COM102', N'Logística Internacional'),
    (10, N'IND101', N'Procesos Industriales'),
    (10, N'IND102', N'Gestión de Calidad');

INSERT INTO Estudiante (legajo, nombre, apellido, email)
VALUES
    (N'10001', N'Ana', N'Pérez', N'ana.perez@ejemplo.edu'),
    (N'10002', N'Bruno', N'López', N'bruno.lopez@ejemplo.edu'),
    (N'10003', N'Carla', N'Gómez', N'carla.gomez@ejemplo.edu'),
    (N'10004', N'Diego', N'Ruiz', N'diego.ruiz@ejemplo.edu'),
    (N'10005', N'Elena', N'Torres', N'elena.torres@ejemplo.edu'),
    (N'10006', N'Facundo', N'Díaz', N'facundo.diaz@ejemplo.edu'),
    (N'10007', N'Gabriela', N'Sosa', N'gabriela.sosa@ejemplo.edu'),
    (N'10008', N'Hugo', N'Castro', N'hugo.castro@ejemplo.edu'),
    (N'10009', N'Irene', N'Molina', N'irene.molina@ejemplo.edu'),
    (N'10010', N'Juan', N'Romero', N'juan.romero@ejemplo.edu'),
    (N'10011', N'Karina', N'Vega', N'karina.vega@ejemplo.edu'),
    (N'10012', N'Lucas', N'Benítez', N'lucas.benitez@ejemplo.edu');

-- Ana (1): EGRESADA en Sistemas y ACTIVA en Informática. Diego (4): ACTIVO en Contador y en Administración.
-- Karina (11): EGRESADA. Lucas (12): INACTIVO.
INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado)
VALUES
    (1, 1, 2023, N'ACTIVO'),
    (1, 2, 2019, N'EGRESADO'),
    (2, 2, 2022, N'ACTIVO'),
    (3, 3, 2021, N'ACTIVO'),
    (4, 4, 2023, N'ACTIVO'),
    (4, 5, 2024, N'ACTIVO'),
    (5, 5, 2022, N'ACTIVO'),
    (6, 6, 2024, N'ACTIVO'),
    (7, 7, 2021, N'ACTIVO'),
    (8, 8, 2023, N'ACTIVO'),
    (9, 9, 2022, N'ACTIVO'),
    (10, 10, 2024, N'ACTIVO'),
    (11, 3, 2018, N'EGRESADO'),
    (12, 2, 2020, N'INACTIVO');

-- Avance variado: Ana 100% en Sistemas y 50% en Informática; Diego 50% en Contador y 0% en Administración.
INSERT INTO Estudiante_Materia (id_estudiante, id_materia, fecha_aprobacion)
VALUES
    (1, 3, N'2020-07-15'), (1, 4, N'2021-07-15'), (1, 1, N'2024-07-15'),
    (2, 3, N'2023-07-15'),
    (3, 5, N'2022-07-15'), (3, 6, N'2023-07-15'),
    (4, 7, N'2024-07-15'),
    (5, 9, N'2023-07-15'), (5, 10, N'2024-07-15'),
    (6, 11, N'2025-07-15'),
    (7, 13, N'2022-07-15'), (7, 14, N'2023-07-15'),
    (8, 15, N'2024-07-15'),
    (9, 17, N'2023-07-15'), (9, 18, N'2024-07-15'),
    (10, 19, N'2025-07-15'),
    (11, 5, N'2019-07-15'), (11, 6, N'2020-07-15'),
    (12, 3, N'2021-07-15');

INSERT INTO Competencia (nombre, categoria, descripcion)
VALUES
    (N'SQL', N'TECNICA', N'Consultas y modelado de datos'),
    (N'Programación', N'TECNICA', N'Desarrollo de soluciones de software'),
    (N'Análisis jurídico', N'PROFESIONAL', N'Interpretación y análisis normativo'),
    (N'Contabilidad', N'PROFESIONAL', N'Registro y análisis contable'),
    (N'Gestión de proyectos', N'TRANSVERSAL', N'Planificación y seguimiento de proyectos'),
    (N'Marketing digital', N'PROFESIONAL', N'Campañas y canales digitales'),
    (N'Selección de personal', N'PROFESIONAL', N'Procesos de búsqueda y selección'),
    (N'Diseño visual', N'TECNICA', N'Comunicación mediante recursos visuales'),
    (N'Logística', N'PROFESIONAL', N'Gestión de operaciones y distribución'),
    (N'Comunicación', N'TRANSVERSAL', N'Comunicación oral y escrita');

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
    (N'30-10000001-1', N'Datos del Sur SA', N'Tecnología', N'MEDIANA', N'CABA', N'ACTIVA'),
    (N'30-10000002-2', N'Sistemas Río SRL', N'Tecnología', N'PEQUEÑA', N'CABA', N'ACTIVA'),
    (N'30-10000003-3', N'Estudio Legal Centro', N'Servicios legales', N'PEQUEÑA', N'CABA', N'ACTIVA'),
    (N'30-10000004-4', N'Contables Asociados', N'Contabilidad', N'MEDIANA', N'Rosario', N'ACTIVA'),
    (N'30-10000005-5', N'Gestión Federal SA', N'Consultoría', N'GRANDE', N'CABA', N'ACTIVA'),
    (N'30-10000006-6', N'Mercado Creativo SRL', N'Marketing', N'PEQUEÑA', N'Córdoba', N'ACTIVA'),
    (N'30-10000007-7', N'Personas Primero SA', N'Recursos humanos', N'MEDIANA', N'CABA', N'ACTIVA'),
    (N'30-10000008-8', N'Estudio Visual SRL', N'Diseño', N'PEQUEÑA', N'La Plata', N'ACTIVA'),
    (N'30-10000009-9', N'Comercio Global SA', N'Comercio exterior', N'GRANDE', N'CABA', N'ACTIVA'),
    (N'30-10000010-0', N'Industria Nacional SA', N'Industria', N'GRANDE', N'Pilar', N'ACTIVA'),
    (N'30-10000011-1', N'Servicios del Centro SRL', N'Servicios', N'PEQUEÑA', N'CABA', N'PROSPECTO'),
    (N'30-10000012-2', N'Textil Andina SA', N'Industria textil', N'MEDIANA', N'Mendoza', N'SUSPENDIDA');

-- Convenio 4: VENCIDO (termino 2025-12-31). Convenio 11: SUSPENDIDO (empresa 12). El resto VIGENTE.
INSERT INTO Convenio (id_empresa, fecha_inicio, fecha_fin, estado, objetivo, cupos_referenciales)
VALUES
    (1, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas de datos', 5),
    (2, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas de sistemas', 5),
    (3, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas jurídicas', 3),
    (4, N'2024-01-01', N'2025-12-31', N'VENCIDO', N'Prácticas contables', 4),
    (5, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas de gestión', 5),
    (6, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas de marketing', 4),
    (7, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas de recursos humanos', 4),
    (8, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas de diseño', 3),
    (9, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas de comercio exterior', 5),
    (10, N'2026-01-01', N'2028-12-31', N'VIGENTE', N'Prácticas industriales', 6),
    (12, N'2025-03-01', N'2027-02-28', N'SUSPENDIDO', N'Prácticas de producción textil', 2);

-- Ofertas 11 y 12: BORRADOR (fecha_publicacion NULL); la 11 sin convenio. Ofertas 3, 4 y 8: CERRADA. Oferta 13: CANCELADA.
INSERT INTO Oferta
    (id_empresa, id_convenio, titulo, descripcion, fecha_publicacion,
     fecha_cierre, vacantes, modalidad, jornada, estado)
VALUES
    (1, 1, N'Asistente de datos', N'Apoyo en consultas y reportes', N'2026-07-01', N'2027-06-30', 2, N'HIBRIDA', N'20 horas', N'PUBLICADA'),
    (2, 2, N'Analista funcional junior', N'Apoyo en relevamiento funcional', N'2026-07-02', N'2027-06-30', 2, N'REMOTA', N'20 horas', N'PUBLICADA'),
    (3, 3, N'Asistente legal', N'Apoyo en investigación jurídica', N'2026-02-02', N'2026-03-31', 1, N'PRESENCIAL', N'20 horas', N'CERRADA'),
    (4, 4, N'Auxiliar contable', N'Registración y conciliaciones', N'2025-03-03', N'2025-04-30', 1, N'HIBRIDA', N'20 horas', N'CERRADA'),
    (5, 5, N'Asistente de proyectos', N'Seguimiento de proyectos internos', N'2026-07-08', N'2027-06-30', 2, N'HIBRIDA', N'24 horas', N'PUBLICADA'),
    (6, 6, N'Asistente de marketing', N'Apoyo en campañas digitales', N'2026-02-09', N'2027-02-28', 2, N'REMOTA', N'20 horas', N'PUBLICADA'),
    (7, 7, N'Asistente de selección', N'Apoyo en búsquedas laborales', N'2026-07-13', N'2027-06-30', 2, N'HIBRIDA', N'20 horas', N'PUBLICADA'),
    (8, 8, N'Diseñador junior', N'Producción de piezas visuales', N'2026-05-04', N'2026-06-05', 1, N'REMOTA', N'20 horas', N'CERRADA'),
    (9, 9, N'Asistente de comercio exterior', N'Seguimiento documental de operaciones', N'2026-07-20', N'2027-06-30', 2, N'HIBRIDA', N'20 horas', N'PUBLICADA'),
    (10, 10, N'Asistente de procesos', N'Relevamiento de procesos productivos', N'2026-07-22', N'2027-06-30', 2, N'PRESENCIAL', N'24 horas', N'PUBLICADA'),
    (11, NULL, N'Asistente administrativo', N'Apoyo administrativo (borrador, sin convenio)', NULL, N'2027-03-31', 1, N'PRESENCIAL', N'20 horas', N'BORRADOR'),
    (1, 1, N'Analista de BI junior', N'Tableros e indicadores (borrador)', NULL, N'2027-03-31', 1, N'REMOTA', N'20 horas', N'BORRADOR'),
    (12, 11, N'Asistente de producción', N'Control de planta textil', N'2026-02-02', N'2026-06-30', 1, N'PRESENCIAL', N'24 horas', N'CANCELADA');

INSERT INTO Oferta_Carrera (id_oferta, id_carrera, pertinencia, criterio_pertinencia)
VALUES
    (1, 1, N'ALTA', N'Tareas de consultas SQL y reportes propias de la carrera'),
    (1, 2, N'MEDIA', N'Análisis de datos como complemento del perfil de sistemas'),
    (2, 2, N'ALTA', N'Relevamiento funcional es el núcleo de la carrera'),
    (2, 1, N'BAJA', N'Perfil orientado al desarrollo, poco relevamiento funcional'),
    (3, 3, N'ALTA', N'Investigación jurídica directa'),
    (4, 4, N'ALTA', N'Registración contable directa'),
    (4, 5, N'MEDIA', N'Conciliaciones vinculadas a finanzas de la empresa'),
    (5, 5, N'ALTA', N'Gestión de proyectos internos'),
    (5, 10, N'MEDIA', N'Seguimiento de proyectos con enfoque de procesos'),
    (6, 6, N'ALTA', N'Campañas digitales'),
    (6, 8, N'MEDIA', N'Piezas gráficas para las campañas'),
    (7, 7, N'ALTA', N'Búsqueda y selección de personal'),
    (7, 6, N'MEDIA', N'Comunicación de la marca empleadora'),
    (8, 8, N'ALTA', N'Producción de piezas visuales'),
    (8, 6, N'MEDIA', N'Contenido para redes'),
    (9, 9, N'ALTA', N'Operaciones de comercio exterior'),
    (9, 10, N'BAJA', N'Aporte logístico limitado'),
    (10, 10, N'ALTA', N'Relevamiento de procesos productivos'),
    (10, 5, N'MEDIA', N'Mejora de procesos desde la administración'),
    (11, 5, N'MEDIA', N'Tareas administrativas generales'),
    (12, 1, N'ALTA', N'Modelado y explotación de datos'),
    (13, 3, N'MEDIA', N'Normativa laboral y de planta');

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
    (1, 1, 1, N'2026-07-20 09:00', N'SELECCIONADA', N'CV', N'Perfil con SQL avanzado'),
    (2, 2, 2, N'2026-07-22 10:00', N'SELECCIONADA', N'PORTAL', N'Postulación desde el portal'),
    (3, 3, 3, N'2026-02-16 09:30', N'SELECCIONADA', N'REFERIDO', N'Referida por un docente'),
    (4, 4, 4, N'2025-03-10 11:00', N'SELECCIONADA', N'FERIA', N'Contacto en la feria de empleo'),
    (5, 5, 5, N'2026-08-03 09:00', N'SELECCIONADA', N'CV', N'Perfil de gestión de proyectos'),
    (6, 6, 6, N'2026-02-20 14:00', N'SELECCIONADA', N'PORTAL', N'Postulación desde el portal'),
    (7, 7, 7, N'2026-08-10 10:00', N'SELECCIONADA', N'CV', N'Perfil de selección de personal'),
    (8, 8, 8, N'2026-05-18 09:00', N'SELECCIONADA', N'REFERIDO', N'Referido por la empresa'),
    (9, 9, 9, N'2026-08-17 10:30', N'SELECCIONADA', N'PORTAL', N'Postulación desde el portal'),
    (10, 10, 10, N'2026-08-24 09:00', N'SELECCIONADA', N'FERIA', N'Contacto en la feria de empleo'),
    (4, 5, 5, N'2026-10-20 09:00', N'SELECCIONADA', N'PORTAL', N'Segunda carrera del estudiante'),
    (2, 1, 2, N'2026-07-25 15:00', N'RECHAZADA', N'CV', N'Postulación a una segunda oferta'),
    (8, 6, 8, N'2026-11-03 10:00', N'EN_REVISION', N'PORTAL', N'Perfil en revisión'),
    (5, 10, 5, N'2026-11-02 11:00', N'ENTREVISTA', N'CV', N'Entrevista técnica coordinada'),
    (6, 7, 6, N'2026-08-18 09:00', N'RETIRADA', N'FERIA', N'Contacto en la feria de empleo'),
    (10, 5, 10, N'2026-11-12 16:00', N'RECIBIDA', N'REFERIDO', N'Postulación recibida'),
    (1, 2, 1, N'2026-08-01 10:00', N'RECHAZADA', N'PORTAL', N'Postulación desde el portal');

-- Historial legal segun la maquina de estados; cada cambio es posterior a la oferta y a la postulacion.
INSERT INTO Postulacion_Estado_Historial
    (id_postulacion, estado_anterior, estado_nuevo, fecha_cambio, motivo)
VALUES
    (1, NULL, N'RECIBIDA', N'2026-07-20 09:00', N'Postulación registrada'),
    (1, N'RECIBIDA', N'EN_REVISION', N'2026-07-24 11:00', N'Perfil enviado a la empresa'),
    (1, N'EN_REVISION', N'ENTREVISTA', N'2026-08-03 09:00', N'Entrevista coordinada'),
    (1, N'ENTREVISTA', N'SELECCIONADA', N'2026-08-17 15:00', N'Aprobó la entrevista y cumple el perfil'),
    (2, NULL, N'RECIBIDA', N'2026-07-22 10:00', N'Postulación registrada'),
    (2, N'RECIBIDA', N'EN_REVISION', N'2026-07-27 11:00', N'Perfil enviado a la empresa'),
    (2, N'EN_REVISION', N'ENTREVISTA', N'2026-08-05 09:00', N'Entrevista coordinada'),
    (2, N'ENTREVISTA', N'SELECCIONADA', N'2026-08-20 15:00', N'Aprobó la entrevista técnica'),
    (3, NULL, N'RECIBIDA', N'2026-02-16 09:30', N'Postulación registrada'),
    (3, N'RECIBIDA', N'EN_REVISION', N'2026-02-18 11:00', N'Perfil enviado a la empresa'),
    (3, N'EN_REVISION', N'ENTREVISTA', N'2026-02-20 09:00', N'Entrevista coordinada'),
    (3, N'ENTREVISTA', N'SELECCIONADA', N'2026-03-02 15:00', N'Aprobó la entrevista con RR. HH.'),
    (4, NULL, N'RECIBIDA', N'2025-03-10 11:00', N'Postulación registrada'),
    (4, N'RECIBIDA', N'EN_REVISION', N'2025-03-12 11:00', N'Perfil enviado a la empresa'),
    (4, N'EN_REVISION', N'ENTREVISTA', N'2025-03-17 09:00', N'Entrevista coordinada'),
    (4, N'ENTREVISTA', N'SELECCIONADA', N'2025-04-02 15:00', N'Aprobó la entrevista final'),
    (5, NULL, N'RECIBIDA', N'2026-08-03 09:00', N'Postulación registrada'),
    (5, N'RECIBIDA', N'EN_REVISION', N'2026-08-06 11:00', N'Perfil enviado a la empresa'),
    (5, N'EN_REVISION', N'ENTREVISTA', N'2026-08-12 09:00', N'Entrevistas coordinadas'),
    (5, N'ENTREVISTA', N'SELECCIONADA', N'2026-08-28 15:00', N'Aprobó las dos entrevistas'),
    (6, NULL, N'RECIBIDA', N'2026-02-20 14:00', N'Postulación registrada'),
    (6, N'RECIBIDA', N'EN_REVISION', N'2026-02-23 11:00', N'Perfil enviado a la empresa'),
    (6, N'EN_REVISION', N'ENTREVISTA', N'2026-03-02 09:00', N'Entrevista coordinada'),
    (6, N'ENTREVISTA', N'SELECCIONADA', N'2026-03-11 15:00', N'Aprobó la entrevista'),
    (7, NULL, N'RECIBIDA', N'2026-08-10 10:00', N'Postulación registrada'),
    (7, N'RECIBIDA', N'EN_REVISION', N'2026-08-12 11:00', N'Perfil enviado a la empresa'),
    (7, N'EN_REVISION', N'ENTREVISTA', N'2026-08-19 09:00', N'Entrevistas coordinadas'),
    (7, N'ENTREVISTA', N'SELECCIONADA', N'2026-09-02 15:00', N'Aprobó las dos entrevistas'),
    (8, NULL, N'RECIBIDA', N'2026-05-18 09:00', N'Postulación registrada'),
    (8, N'RECIBIDA', N'EN_REVISION', N'2026-05-20 11:00', N'Perfil enviado a la empresa'),
    (8, N'EN_REVISION', N'ENTREVISTA', N'2026-05-25 09:00', N'Entrevista coordinada'),
    (8, N'ENTREVISTA', N'SELECCIONADA', N'2026-06-01 15:00', N'Aprobó la entrevista técnica'),
    (9, NULL, N'RECIBIDA', N'2026-08-17 10:30', N'Postulación registrada'),
    (9, N'RECIBIDA', N'EN_REVISION', N'2026-08-19 11:00', N'Perfil enviado a la empresa'),
    (9, N'EN_REVISION', N'ENTREVISTA', N'2026-08-26 09:00', N'Entrevista coordinada'),
    (9, N'ENTREVISTA', N'SELECCIONADA', N'2026-09-09 15:00', N'Aprobó la entrevista con RR. HH.'),
    (10, NULL, N'RECIBIDA', N'2026-08-24 09:00', N'Postulación registrada'),
    (10, N'RECIBIDA', N'EN_REVISION', N'2026-08-26 11:00', N'Perfil enviado a la empresa'),
    (10, N'EN_REVISION', N'ENTREVISTA', N'2026-09-02 09:00', N'Entrevista coordinada'),
    (10, N'ENTREVISTA', N'SELECCIONADA', N'2026-09-16 15:00', N'Aprobó la entrevista'),
    (11, NULL, N'RECIBIDA', N'2026-10-20 09:00', N'Postulación registrada'),
    (11, N'RECIBIDA', N'EN_REVISION', N'2026-10-23 11:00', N'Perfil enviado a la empresa'),
    (11, N'EN_REVISION', N'ENTREVISTA', N'2026-10-27 09:00', N'Entrevista coordinada'),
    (11, N'ENTREVISTA', N'SELECCIONADA', N'2026-11-05 15:00', N'Aprobó la entrevista técnica'),
    (12, NULL, N'RECIBIDA', N'2026-07-25 15:00', N'Postulación registrada'),
    (12, N'RECIBIDA', N'EN_REVISION', N'2026-07-28 11:00', N'Perfil enviado a la empresa'),
    (12, N'EN_REVISION', N'ENTREVISTA', N'2026-08-04 09:00', N'Entrevista coordinada'),
    (12, N'ENTREVISTA', N'RECHAZADA', N'2026-08-10 12:00', N'Nivel de SQL insuficiente para el puesto'),
    (13, NULL, N'RECIBIDA', N'2026-11-03 10:00', N'Postulación registrada'),
    (13, N'RECIBIDA', N'EN_REVISION', N'2026-11-06 11:00', N'Perfil enviado a la empresa'),
    (14, NULL, N'RECIBIDA', N'2026-11-02 11:00', N'Postulación registrada'),
    (14, N'RECIBIDA', N'EN_REVISION', N'2026-11-05 11:00', N'Perfil enviado a la empresa'),
    (14, N'EN_REVISION', N'ENTREVISTA', N'2026-11-10 09:00', N'Entrevista técnica coordinada para el 2026-11-18'),
    (15, NULL, N'RECIBIDA', N'2026-08-18 09:00', N'Postulación registrada'),
    (15, N'RECIBIDA', N'EN_REVISION', N'2026-08-20 11:00', N'Perfil enviado a la empresa'),
    (15, N'EN_REVISION', N'RETIRADA', N'2026-08-28 17:00', N'El estudiante retiró la postulación por superposición horaria con la cursada'),
    (16, NULL, N'RECIBIDA', N'2026-11-12 16:00', N'Postulación registrada'),
    (17, NULL, N'RECIBIDA', N'2026-08-01 10:00', N'Postulación registrada'),
    (17, N'RECIBIDA', N'EN_REVISION', N'2026-08-04 11:00', N'Perfil enviado a la empresa'),
    (17, N'EN_REVISION', N'RECHAZADA', N'2026-08-12 12:00', N'Pertinencia baja: falta la competencia obligatoria Gestión de proyectos');

-- La entrevista de la postulacion 14 (id 15) es futura (PENDIENTE): aun no es un hecho consumado.
INSERT INTO Entrevista (id_postulacion, fecha, etapa, resultado, devolucion)
VALUES
    (1, N'2026-08-05 10:00', N'GENERAL', N'APROBADA', N'Perfil adecuado'),
    (2, N'2026-08-07 10:00', N'TECNICA', N'APROBADA', N'Buen manejo del relevamiento funcional'),
    (3, N'2026-02-23 10:00', N'RRHH', N'APROBADA', N'Buena comunicación'),
    (4, N'2025-03-19 10:00', N'FINAL', N'APROBADA', N'Perfil adecuado'),
    (5, N'2026-08-14 10:00', N'GENERAL', N'APROBADA', N'Perfil adecuado'),
    (5, N'2026-08-21 10:00', N'TECNICA', N'APROBADA', N'Dominio de gestión de proyectos'),
    (6, N'2026-03-04 10:00', N'GENERAL', N'APROBADA', N'Perfil adecuado'),
    (7, N'2026-08-21 10:00', N'GENERAL', N'APROBADA', N'Perfil adecuado'),
    (7, N'2026-08-26 10:00', N'FINAL', N'APROBADA', N'Confirmado por la empresa'),
    (8, N'2026-05-27 10:00', N'TECNICA', N'APROBADA', N'Buen nivel de diseño'),
    (9, N'2026-08-28 10:00', N'RRHH', N'APROBADA', N'Perfil adecuado'),
    (10, N'2026-09-04 10:00', N'GENERAL', N'APROBADA', N'Perfil adecuado'),
    (11, N'2026-10-29 10:00', N'TECNICA', N'APROBADA', N'Perfil adecuado'),
    (12, N'2026-08-06 10:00', N'TECNICA', N'RECHAZADA', N'Nivel de SQL insuficiente'),
    (14, N'2026-11-18 10:00', N'TECNICA', N'PENDIENTE', N'Entrevista programada');

-- Practica k = Postulacion k. 1,2,5,7,9,10 EN_CURSO; 3,4,6 FINALIZADA; 8 INTERRUMPIDA; 11 PLANIFICADA.
-- Una sola practica activa por estudiante: Diego (4) tiene la 4 FINALIZADA (2025) y la 11 PLANIFICADA.
INSERT INTO Practica
    (id_postulacion, fecha_inicio, fecha_fin_prevista, fecha_fin_real,
     horas_semanales, modalidad, estado, motivo_cierre)
VALUES
    (1, N'2026-09-01', N'2027-02-26', NULL, 20, N'HIBRIDA', N'EN_CURSO', NULL),
    (2, N'2026-09-01', N'2027-02-26', NULL, 20, N'REMOTA', N'EN_CURSO', NULL),
    (3, N'2026-03-16', N'2026-09-30', N'2026-09-30', 20, N'PRESENCIAL', N'FINALIZADA', N'Finalización prevista'),
    (4, N'2025-05-05', N'2025-11-28', N'2025-11-28', 20, N'HIBRIDA', N'FINALIZADA', N'Finalización prevista'),
    (5, N'2026-09-14', N'2027-03-12', NULL, 24, N'HIBRIDA', N'EN_CURSO', NULL),
    (6, N'2026-03-30', N'2026-10-30', N'2026-10-30', 20, N'REMOTA', N'FINALIZADA', N'Finalización prevista'),
    (7, N'2026-09-21', N'2027-03-19', NULL, 20, N'HIBRIDA', N'EN_CURSO', NULL),
    (8, N'2026-06-15', N'2026-12-15', N'2026-09-10', 20, N'REMOTA', N'INTERRUMPIDA', N'Cambio de disponibilidad horaria del estudiante'),
    (9, N'2026-09-28', N'2027-03-26', NULL, 20, N'HIBRIDA', N'EN_CURSO', NULL),
    (10, N'2026-10-01', N'2027-03-31', NULL, 24, N'PRESENCIAL', N'EN_CURSO', NULL),
    (11, N'2026-12-01', N'2027-05-31', NULL, 20, N'HIBRIDA', N'PLANIFICADA', NULL);

-- Cada practica: NULL->PLANIFICADA (alta, posterior a la seleccion) y PLANIFICADA->EN_CURSO (fecha de inicio);
-- las cerradas suman el cierre. Nada posterior a una interrupcion.
INSERT INTO Historial_Practica
    (id_practica, estado_anterior, estado_nuevo, fecha_cambio, motivo)
VALUES
    (1, NULL, N'PLANIFICADA', N'2026-08-20 10:00', N'Práctica creada tras la selección'),
    (1, N'PLANIFICADA', N'EN_CURSO', N'2026-09-01 08:00', N'Inicio de la práctica'),
    (2, NULL, N'PLANIFICADA', N'2026-08-24 10:00', N'Práctica creada tras la selección'),
    (2, N'PLANIFICADA', N'EN_CURSO', N'2026-09-01 08:00', N'Inicio de la práctica'),
    (3, NULL, N'PLANIFICADA', N'2026-03-05 10:00', N'Práctica creada tras la selección'),
    (3, N'PLANIFICADA', N'EN_CURSO', N'2026-03-16 08:00', N'Inicio de la práctica'),
    (3, N'EN_CURSO', N'FINALIZADA', N'2026-09-30 18:00', N'Finalización prevista'),
    (4, NULL, N'PLANIFICADA', N'2025-04-10 10:00', N'Práctica creada tras la selección'),
    (4, N'PLANIFICADA', N'EN_CURSO', N'2025-05-05 08:00', N'Inicio de la práctica'),
    (4, N'EN_CURSO', N'FINALIZADA', N'2025-11-28 18:00', N'Finalización prevista'),
    (5, NULL, N'PLANIFICADA', N'2026-09-01 10:00', N'Práctica creada tras la selección'),
    (5, N'PLANIFICADA', N'EN_CURSO', N'2026-09-14 08:00', N'Inicio de la práctica'),
    (6, NULL, N'PLANIFICADA', N'2026-03-16 10:00', N'Práctica creada tras la selección'),
    (6, N'PLANIFICADA', N'EN_CURSO', N'2026-03-30 08:00', N'Inicio de la práctica'),
    (6, N'EN_CURSO', N'FINALIZADA', N'2026-10-30 18:00', N'Finalización prevista'),
    (7, NULL, N'PLANIFICADA', N'2026-09-07 10:00', N'Práctica creada tras la selección'),
    (7, N'PLANIFICADA', N'EN_CURSO', N'2026-09-21 08:00', N'Inicio de la práctica'),
    (8, NULL, N'PLANIFICADA', N'2026-06-05 10:00', N'Práctica creada tras la selección'),
    (8, N'PLANIFICADA', N'EN_CURSO', N'2026-06-15 08:00', N'Inicio de la práctica'),
    (8, N'EN_CURSO', N'INTERRUMPIDA', N'2026-09-10 12:00', N'Cambio de disponibilidad horaria del estudiante'),
    (9, NULL, N'PLANIFICADA', N'2026-09-14 10:00', N'Práctica creada tras la selección'),
    (9, N'PLANIFICADA', N'EN_CURSO', N'2026-09-28 08:00', N'Inicio de la práctica'),
    (10, NULL, N'PLANIFICADA', N'2026-09-21 10:00', N'Práctica creada tras la selección'),
    (10, N'PLANIFICADA', N'EN_CURSO', N'2026-10-01 08:00', N'Inicio de la práctica'),
    (11, NULL, N'PLANIFICADA', N'2026-11-10 10:00', N'Práctica creada tras la selección');

-- Ultimo seguimiento: practica 2 EN_OBSERVACION (revision vencida), practica 7 REQUIERE_INTERVENCION (revision vencida,
-- aparece en la vista de intervencion); practica 9 tuvo REQUIERE_INTERVENCION pero el ULTIMO es SIN_NOVEDADES (no aparece);
-- practica 8 REQUIERE_INTERVENCION pero INTERRUMPIDA (no aparece).
INSERT INTO Seguimiento
    (id_practica, fecha, tipo_seguimiento, origen_feedback,
     estado_seguimiento, observaciones, intervencion_facultad, proxima_revision)
VALUES
    (1, N'2026-09-15', N'INICIAL', N'AMBOS', N'SIN_NOVEDADES', N'Inicio normal', NULL, N'2026-10-15'),
    (1, N'2026-10-15', N'PERIODICO', N'AMBOS', N'SIN_NOVEDADES', N'Desarrollo normal', NULL, N'2026-12-15'),
    (2, N'2026-09-15', N'INICIAL', N'EMPRESA', N'SIN_NOVEDADES', N'Inicio normal', NULL, N'2026-10-15'),
    (2, N'2026-10-16', N'PERIODICO', N'ESTUDIANTE', N'EN_OBSERVACION', N'Requiere ajustar horarios', N'Revisar horarios con la empresa', N'2026-11-01'),
    (3, N'2026-03-30', N'INICIAL', N'AMBOS', N'SIN_NOVEDADES', N'Inicio normal', NULL, N'2026-06-15'),
    (3, N'2026-06-15', N'PERIODICO', N'AMBOS', N'SIN_NOVEDADES', N'Desarrollo normal', NULL, N'2026-09-15'),
    (3, N'2026-09-30', N'CIERRE', N'AMBOS', N'SIN_NOVEDADES', N'Cierre sin observaciones', NULL, NULL),
    (4, N'2025-05-19', N'INICIAL', N'AMBOS', N'SIN_NOVEDADES', N'Inicio normal', NULL, N'2025-08-18'),
    (4, N'2025-08-18', N'PERIODICO', N'AMBOS', N'SIN_NOVEDADES', N'Desarrollo normal', NULL, N'2025-11-17'),
    (4, N'2025-11-28', N'CIERRE', N'AMBOS', N'SIN_NOVEDADES', N'Cierre sin observaciones', NULL, NULL),
    (5, N'2026-09-28', N'INICIAL', N'EMPRESA', N'SIN_NOVEDADES', N'Buen inicio', NULL, N'2026-11-02'),
    (5, N'2026-11-02', N'PERIODICO', N'AMBOS', N'SIN_NOVEDADES', N'Desarrollo normal', NULL, N'2026-12-02'),
    (6, N'2026-04-13', N'INICIAL', N'AMBOS', N'SIN_NOVEDADES', N'Inicio normal', NULL, N'2026-07-13'),
    (6, N'2026-07-13', N'PERIODICO', N'AMBOS', N'SIN_NOVEDADES', N'Desarrollo normal', NULL, N'2026-10-13'),
    (6, N'2026-10-30', N'CIERRE', N'AMBOS', N'SIN_NOVEDADES', N'Cierre sin observaciones', NULL, NULL),
    (7, N'2026-10-05', N'INICIAL', N'AMBOS', N'EN_OBSERVACION', N'Dificultad de comunicación con el tutor', N'Seguir la comunicación', N'2026-10-19'),
    (7, N'2026-10-19', N'EXTRAORDINARIO', N'AMBOS', N'REQUIERE_INTERVENCION', N'La dificultad de comunicación persiste', N'Coordinar una reunión con el tutor', N'2026-10-26'),
    (8, N'2026-06-29', N'INICIAL', N'AMBOS', N'SIN_NOVEDADES', N'Inicio normal', NULL, N'2026-07-27'),
    (8, N'2026-07-27', N'PERIODICO', N'ESTUDIANTE', N'EN_OBSERVACION', N'Dificultad con los horarios', N'Revisar disponibilidad', N'2026-08-24'),
    (8, N'2026-08-24', N'EXTRAORDINARIO', N'ESTUDIANTE', N'REQUIERE_INTERVENCION', N'Posible interrupción', N'Analizar alternativas', N'2026-09-07'),
    (9, N'2026-10-12', N'INICIAL', N'AMBOS', N'REQUIERE_INTERVENCION', N'Falta de accesos a los sistemas', N'Gestionar accesos con la empresa', N'2026-10-26'),
    (9, N'2026-11-02', N'PERIODICO', N'AMBOS', N'SIN_NOVEDADES', N'Accesos resueltos', NULL, N'2026-12-02'),
    (10, N'2026-10-15', N'INICIAL', N'AMBOS', N'SIN_NOVEDADES', N'Inicio normal', NULL, N'2026-11-30');

-- Practicas FINALIZADA (3, 4, 6): PARCIAL y FINAL de ESTUDIANTE y de EMPRESA.
-- La 8 (INTERRUMPIDA) solo tiene evaluaciones PARCIAL anteriores a la interrupcion.
-- Estudiante cargan puntaje_satisfaccion; Empresa carga puntaje_desempeno.
INSERT INTO Evaluacion
    (id_practica, fecha, tipo_evaluador, instancia, puntaje_desempeno,
     puntaje_satisfaccion, resultado, comentarios)
VALUES
    (1, N'2026-11-02 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 4, N'SATISFACTORIA', N'Buena experiencia inicial'),
    (1, N'2026-11-02 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen desempeño inicial'),
    (2, N'2026-11-02 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 3, N'A_MEJORAR', N'Necesita ajustar horarios'),
    (2, N'2026-11-02 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen desempeño'),
    (3, N'2026-06-20 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 4, N'SATISFACTORIA', N'Experiencia positiva'),
    (3, N'2026-06-20 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen desempeño'),
    (3, N'2026-09-28 11:00', N'ESTUDIANTE', N'FINAL', NULL, 5, N'SATISFACTORIA', N'Experiencia muy positiva'),
    (3, N'2026-09-28 11:30', N'EMPRESA', N'FINAL', 5, NULL, N'SATISFACTORIA', N'Desempeño destacado'),
    (4, N'2025-08-22 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 4, N'SATISFACTORIA', N'Experiencia positiva'),
    (4, N'2025-08-22 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen desempeño'),
    (4, N'2025-11-26 11:00', N'ESTUDIANTE', N'FINAL', NULL, 4, N'SATISFACTORIA', N'Experiencia positiva'),
    (4, N'2025-11-26 11:30', N'EMPRESA', N'FINAL', 4, NULL, N'SATISFACTORIA', N'Buen desempeño'),
    (5, N'2026-11-05 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 4, N'SATISFACTORIA', N'Buen inicio'),
    (5, N'2026-11-05 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen inicio'),
    (6, N'2026-07-20 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 5, N'SATISFACTORIA', N'Experiencia positiva'),
    (6, N'2026-07-20 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen desempeño'),
    (6, N'2026-10-29 11:00', N'ESTUDIANTE', N'FINAL', NULL, 5, N'SATISFACTORIA', N'Experiencia muy positiva'),
    (6, N'2026-10-29 11:30', N'EMPRESA', N'FINAL', 4, NULL, N'SATISFACTORIA', N'Buen desempeño'),
    (7, N'2026-11-07 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 3, N'A_MEJORAR', N'Necesita acompañamiento'),
    (7, N'2026-11-07 11:30', N'EMPRESA', N'PARCIAL', 3, NULL, N'A_MEJORAR', N'Debe mejorar la comunicación'),
    (8, N'2026-08-28 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 2, N'INSATISFACTORIA', N'Dificultad para sostener los horarios'),
    (8, N'2026-08-28 11:30', N'EMPRESA', N'PARCIAL', 3, NULL, N'A_MEJORAR', N'Asistencia irregular'),
    (9, N'2026-11-09 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 4, N'SATISFACTORIA', N'Buen inicio'),
    (9, N'2026-11-09 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen inicio'),
    (10, N'2026-11-10 11:00', N'ESTUDIANTE', N'PARCIAL', NULL, 4, N'SATISFACTORIA', N'Buen inicio'),
    (10, N'2026-11-10 11:30', N'EMPRESA', N'PARCIAL', 4, NULL, N'SATISFACTORIA', N'Buen inicio');

-- Solo Seguimiento y Evaluacion; el valor_nuevo coincide con el valor final de la fila (ids por orden de insercion).
INSERT INTO Auditoria_Cambios
    (tabla, id_registro, operacion, fecha, valor_anterior, valor_nuevo)
VALUES
    (N'Seguimiento', 4, N'UPDATE', N'2026-10-16 17:00', N'SIN_NOVEDADES', N'EN_OBSERVACION'),
    (N'Seguimiento', 17, N'UPDATE', N'2026-10-20 09:00', N'EN_OBSERVACION', N'REQUIERE_INTERVENCION'),
    (N'Seguimiento', 19, N'UPDATE', N'2026-07-28 10:00', N'SIN_NOVEDADES', N'EN_OBSERVACION'),
    (N'Seguimiento', 20, N'UPDATE', N'2026-08-25 10:00', N'EN_OBSERVACION', N'REQUIERE_INTERVENCION'),
    (N'Seguimiento', 21, N'UPDATE', N'2026-10-13 10:00', N'EN_OBSERVACION', N'REQUIERE_INTERVENCION'),
    (N'Evaluacion', 3, N'UPDATE', N'2026-11-03 09:00', N'SATISFACTORIA', N'A_MEJORAR'),
    (N'Evaluacion', 19, N'UPDATE', N'2026-11-08 09:00', N'SATISFACTORIA', N'A_MEJORAR'),
    (N'Evaluacion', 20, N'UPDATE', N'2026-11-08 09:30', N'SATISFACTORIA', N'A_MEJORAR'),
    (N'Evaluacion', 21, N'UPDATE', N'2026-08-29 09:00', N'A_MEJORAR', N'INSATISFACTORIA'),
    (N'Evaluacion', 22, N'UPDATE', N'2026-08-29 09:30', N'SATISFACTORIA', N'A_MEJORAR');

COMMIT;
GO
