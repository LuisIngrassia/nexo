/* ================================================================
   NexoAcademico - 01_estructura.sql
   Tablas, vistas, función, procedimientos, triggers e índices.
   Requiere la base creada por 00_crear_base.sql.
   ================================================================ */

USE NexoAcademico;
GO

/* ================================================================
   1. TABLAS (en orden de dependencias de FK)
   ================================================================ */

CREATE TABLE Carrera (
    id_carrera INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    unidad_academica NVARCHAR(100) NOT NULL,
    plan_estudios NVARCHAR(30) NOT NULL,
    nivel NVARCHAR(30) NOT NULL,
    activo BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_Carrera PRIMARY KEY (id_carrera),
    CONSTRAINT UQ_Carrera_Nombre_Plan UNIQUE (nombre, plan_estudios)
);
GO

CREATE TABLE Materia (
    id_materia INT IDENTITY(1,1) NOT NULL,
    id_carrera INT NOT NULL,
    codigo NVARCHAR(20) NOT NULL,
    nombre NVARCHAR(120) NOT NULL,
    activo BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_Materia PRIMARY KEY (id_materia),
    CONSTRAINT UQ_Materia_Carrera_Codigo UNIQUE (id_carrera, codigo),
    CONSTRAINT FK_Materia_Carrera FOREIGN KEY (id_carrera)
        REFERENCES Carrera (id_carrera)
);
GO

-- La carrera, el año de ingreso y el estado académico pasan a Estudiante_Carrera.
CREATE TABLE Estudiante (
    id_estudiante INT IDENTITY(1,1) NOT NULL,
    legajo NVARCHAR(20) NOT NULL,
    nombre NVARCHAR(50) NOT NULL,
    apellido NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT UQ_Estudiante_Legajo UNIQUE (legajo),
    CONSTRAINT UQ_Estudiante_Email UNIQUE (email)
);
GO

-- Un estudiante puede cursar varias carreras (decisión 6).
CREATE TABLE Estudiante_Carrera (
    id_estudiante INT NOT NULL,
    id_carrera INT NOT NULL,
    anio_ingreso SMALLINT NOT NULL,
    estado NVARCHAR(10) NOT NULL DEFAULT N'ACTIVO',

    CONSTRAINT PK_Estudiante_Carrera PRIMARY KEY (id_estudiante, id_carrera),
    CONSTRAINT CK_EstudianteCarrera_Anio CHECK (anio_ingreso BETWEEN 1900 AND 2100),
    CONSTRAINT CK_EstudianteCarrera_Estado
        CHECK (estado IN (N'ACTIVO', N'EGRESADO', N'INACTIVO')),
    CONSTRAINT FK_EstudianteCarrera_Estudiante FOREIGN KEY (id_estudiante)
        REFERENCES Estudiante (id_estudiante),
    CONSTRAINT FK_EstudianteCarrera_Carrera FOREIGN KEY (id_carrera)
        REFERENCES Carrera (id_carrera)
);
GO

CREATE TABLE Estudiante_Materia (
    id_estudiante INT NOT NULL,
    id_materia INT NOT NULL,
    fecha_aprobacion DATE NOT NULL,

    CONSTRAINT PK_Estudiante_Materia PRIMARY KEY (id_estudiante, id_materia),
    CONSTRAINT FK_EstudianteMateria_Estudiante FOREIGN KEY (id_estudiante)
        REFERENCES Estudiante (id_estudiante),
    CONSTRAINT FK_EstudianteMateria_Materia FOREIGN KEY (id_materia)
        REFERENCES Materia (id_materia)
);
GO

CREATE TABLE Competencia (
    id_competencia INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    categoria NVARCHAR(50) NOT NULL,
    descripcion NVARCHAR(500) NULL,
    activo BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_Competencia PRIMARY KEY (id_competencia),
    CONSTRAINT UQ_Competencia_Nombre UNIQUE (nombre)
);
GO

-- Competencias declaradas por el estudiante (no validadas).
CREATE TABLE Estudiante_Competencia (
    id_estudiante INT NOT NULL,
    id_competencia INT NOT NULL,
    nivel_declarado INT NOT NULL,
    fecha_actualizacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Estudiante_Competencia
        PRIMARY KEY (id_estudiante, id_competencia),
    CONSTRAINT CK_EstudianteCompetencia_Nivel
        CHECK (nivel_declarado BETWEEN 1 AND 3),
    CONSTRAINT FK_EstudianteCompetencia_Estudiante FOREIGN KEY (id_estudiante)
        REFERENCES Estudiante (id_estudiante),
    CONSTRAINT FK_EstudianteCompetencia_Competencia FOREIGN KEY (id_competencia)
        REFERENCES Competencia (id_competencia)
);
GO

-- Se quita "activo": era redundante con estado_vinculo (hallazgo 18).
CREATE TABLE Empresa (
    id_empresa INT IDENTITY(1,1) NOT NULL,
    cuit NVARCHAR(20) NOT NULL,
    razon_social NVARCHAR(120) NOT NULL,
    sector NVARCHAR(80) NOT NULL,
    tamano NVARCHAR(30) NULL,
    ciudad NVARCHAR(80) NOT NULL,
    estado_vinculo NVARCHAR(15) NOT NULL DEFAULT N'PROSPECTO',

    CONSTRAINT PK_Empresa PRIMARY KEY (id_empresa),
    CONSTRAINT UQ_Empresa_CUIT UNIQUE (cuit),
    CONSTRAINT CK_Empresa_Estado
        CHECK (estado_vinculo IN (N'PROSPECTO', N'ACTIVA', N'SUSPENDIDA'))
);
GO

CREATE TABLE Convenio (
    id_convenio INT IDENTITY(1,1) NOT NULL,
    id_empresa INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    estado NVARCHAR(15) NOT NULL,
    objetivo NVARCHAR(500) NOT NULL,
    cupos_referenciales INT NULL,  -- orientativo, no limita prácticas

    CONSTRAINT PK_Convenio PRIMARY KEY (id_convenio),
    CONSTRAINT CK_Convenio_Fechas
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT CK_Convenio_Estado
        CHECK (estado IN (N'VIGENTE', N'VENCIDO', N'SUSPENDIDO')),
    -- Coherencia estado/fecha: un convenio vencido tiene fecha de fin.
    CONSTRAINT CK_Convenio_Vencido
        CHECK (estado <> N'VENCIDO' OR fecha_fin IS NOT NULL),
    CONSTRAINT CK_Convenio_Cupos
        CHECK (cupos_referenciales IS NULL OR cupos_referenciales >= 0),
    CONSTRAINT UQ_Convenio_Id_Empresa
        UNIQUE (id_convenio, id_empresa),
    CONSTRAINT FK_Convenio_Empresa FOREIGN KEY (id_empresa)
        REFERENCES Empresa (id_empresa)
);
GO

-- fecha_publicacion es NULL en borradores; la fija usp_PublicarOferta (hallazgo 19).
CREATE TABLE Oferta (
    id_oferta INT IDENTITY(1,1) NOT NULL,
    id_empresa INT NOT NULL,
    id_convenio INT NULL,
    titulo NVARCHAR(120) NOT NULL,
    descripcion NVARCHAR(800) NOT NULL,
    fecha_publicacion DATE NULL,
    fecha_cierre DATE NOT NULL,
    vacantes INT NOT NULL,
    modalidad NVARCHAR(15) NOT NULL,
    jornada NVARCHAR(40) NOT NULL,
    estado NVARCHAR(15) NOT NULL DEFAULT N'BORRADOR',

    CONSTRAINT PK_Oferta PRIMARY KEY (id_oferta),
    CONSTRAINT CK_Oferta_Fechas
        CHECK (fecha_publicacion IS NULL OR fecha_cierre >= fecha_publicacion),
    CONSTRAINT CK_Oferta_Publicacion
        CHECK (estado = N'BORRADOR' OR fecha_publicacion IS NOT NULL),
    CONSTRAINT CK_Oferta_Vacantes CHECK (vacantes > 0),
    CONSTRAINT CK_Oferta_Modalidad
        CHECK (modalidad IN (N'PRESENCIAL', N'REMOTA', N'HIBRIDA')),
    CONSTRAINT CK_Oferta_Estado
        CHECK (estado IN (N'BORRADOR', N'PUBLICADA', N'CERRADA', N'CANCELADA')),
    CONSTRAINT FK_Oferta_Empresa FOREIGN KEY (id_empresa)
        REFERENCES Empresa (id_empresa),
    CONSTRAINT FK_Oferta_Convenio_Empresa FOREIGN KEY (id_convenio, id_empresa)
        REFERENCES Convenio (id_convenio, id_empresa)
);
GO

-- Carreras destinatarias de la oferta, con su pertinencia (decisión 5).
CREATE TABLE Oferta_Carrera (
    id_oferta INT NOT NULL,
    id_carrera INT NOT NULL,
    pertinencia NVARCHAR(5) NOT NULL,
    criterio_pertinencia NVARCHAR(300) NULL,

    CONSTRAINT PK_Oferta_Carrera
        PRIMARY KEY (id_oferta, id_carrera),
    CONSTRAINT CK_OfertaCarrera_Pertinencia
        CHECK (pertinencia IN (N'ALTA', N'MEDIA', N'BAJA')),
    CONSTRAINT FK_OfertaCarrera_Oferta FOREIGN KEY (id_oferta)
        REFERENCES Oferta (id_oferta),
    CONSTRAINT FK_OfertaCarrera_Carrera FOREIGN KEY (id_carrera)
        REFERENCES Carrera (id_carrera)
);
GO

CREATE TABLE Oferta_Competencia (
    id_oferta INT NOT NULL,
    id_competencia INT NOT NULL,
    nivel_requerido INT NOT NULL,
    obligatoria BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_Oferta_Competencia PRIMARY KEY (id_oferta, id_competencia),
    CONSTRAINT CK_OfertaCompetencia_Nivel
        CHECK (nivel_requerido BETWEEN 1 AND 3),
    CONSTRAINT FK_OfertaCompetencia_Oferta FOREIGN KEY (id_oferta)
        REFERENCES Oferta (id_oferta),
    CONSTRAINT FK_OfertaCompetencia_Competencia FOREIGN KEY (id_competencia)
        REFERENCES Competencia (id_competencia)
);
GO

-- id_carrera: carrera por la que se postula. Las dos FK compuestas garantizan
-- que el estudiante cursa esa carrera y que la oferta está dirigida a ella.
CREATE TABLE Postulacion (
    id_postulacion INT IDENTITY(1,1) NOT NULL,
    id_estudiante INT NOT NULL,
    id_oferta INT NOT NULL,
    id_carrera INT NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    estado NVARCHAR(15) NOT NULL DEFAULT N'RECIBIDA',
    origen NVARCHAR(30) NOT NULL,
    observaciones NVARCHAR(500) NULL,

    CONSTRAINT PK_Postulacion PRIMARY KEY (id_postulacion),
    CONSTRAINT UQ_Postulacion_Estudiante_Oferta UNIQUE (id_estudiante, id_oferta),
    CONSTRAINT CK_Postulacion_Estado
        CHECK (estado IN (
            N'RECIBIDA', N'EN_REVISION', N'ENTREVISTA',
            N'SELECCIONADA', N'RECHAZADA', N'RETIRADA'
        )),
    CONSTRAINT CK_Postulacion_Origen
        CHECK (origen IN (N'CV', N'PORTAL', N'REFERIDO', N'FERIA')),
    CONSTRAINT FK_Postulacion_Estudiante FOREIGN KEY (id_estudiante)
        REFERENCES Estudiante (id_estudiante),
    CONSTRAINT FK_Postulacion_Oferta FOREIGN KEY (id_oferta)
        REFERENCES Oferta (id_oferta),
    CONSTRAINT FK_Postulacion_EstudianteCarrera FOREIGN KEY (id_estudiante, id_carrera)
        REFERENCES Estudiante_Carrera (id_estudiante, id_carrera),
    CONSTRAINT FK_Postulacion_OfertaCarrera FOREIGN KEY (id_oferta, id_carrera)
        REFERENCES Oferta_Carrera (id_oferta, id_carrera)
);
GO

CREATE TABLE Postulacion_Estado_Historial (
    id_historial INT IDENTITY(1,1) NOT NULL,
    id_postulacion INT NOT NULL,
    estado_anterior NVARCHAR(15) NULL,
    estado_nuevo NVARCHAR(15) NOT NULL,
    fecha_cambio DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    motivo NVARCHAR(500) NULL,
    usuario NVARCHAR(128) NOT NULL DEFAULT ORIGINAL_LOGIN(),

    CONSTRAINT PK_Postulacion_Estado_Historial PRIMARY KEY (id_historial),
    CONSTRAINT CK_Historial_EstadoAnterior
        CHECK (estado_anterior IS NULL OR estado_anterior IN (
            N'RECIBIDA', N'EN_REVISION', N'ENTREVISTA',
            N'SELECCIONADA', N'RECHAZADA', N'RETIRADA'
        )),
    CONSTRAINT CK_Historial_EstadoNuevo
        CHECK (estado_nuevo IN (
            N'RECIBIDA', N'EN_REVISION', N'ENTREVISTA',
            N'SELECCIONADA', N'RECHAZADA', N'RETIRADA'
        )),
    CONSTRAINT FK_Historial_Postulacion FOREIGN KEY (id_postulacion)
        REFERENCES Postulacion (id_postulacion)
);
GO

CREATE TABLE Entrevista (
    id_entrevista INT IDENTITY(1,1) NOT NULL,
    id_postulacion INT NOT NULL,
    fecha DATETIME2 NOT NULL,
    etapa NVARCHAR(30) NOT NULL,
    resultado NVARCHAR(15) NOT NULL DEFAULT N'PENDIENTE',
    devolucion NVARCHAR(400) NULL,

    CONSTRAINT PK_Entrevista PRIMARY KEY (id_entrevista),
    CONSTRAINT CK_Entrevista_Etapa
        CHECK (etapa IN (N'GENERAL', N'TECNICA', N'RRHH', N'FINAL')),
    CONSTRAINT CK_Entrevista_Resultado
        CHECK (resultado IN (N'PENDIENTE', N'APROBADA', N'RECHAZADA')),
    CONSTRAINT FK_Entrevista_Postulacion FOREIGN KEY (id_postulacion)
        REFERENCES Postulacion (id_postulacion)
);
GO

CREATE TABLE Practica (
    id_practica INT IDENTITY(1,1) NOT NULL,
    id_postulacion INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin_prevista DATE NOT NULL,
    fecha_fin_real DATE NULL,
    horas_semanales INT NOT NULL,
    modalidad NVARCHAR(15) NOT NULL,
    estado NVARCHAR(15) NOT NULL DEFAULT N'PLANIFICADA',
    motivo_cierre NVARCHAR(250) NULL,

    CONSTRAINT PK_Practica PRIMARY KEY (id_practica),
    CONSTRAINT UQ_Practica_Postulacion UNIQUE (id_postulacion),
    CONSTRAINT CK_Practica_Fechas
        CHECK (fecha_fin_prevista >= fecha_inicio
            AND (fecha_fin_real IS NULL OR fecha_fin_real >= fecha_inicio)),
    CONSTRAINT CK_Practica_Horas CHECK (horas_semanales BETWEEN 1 AND 48),
    CONSTRAINT CK_Practica_Modalidad
        CHECK (modalidad IN (N'PRESENCIAL', N'REMOTA', N'HIBRIDA')),
    CONSTRAINT CK_Practica_Estado
        CHECK (estado IN (N'PLANIFICADA', N'EN_CURSO', N'FINALIZADA', N'INTERRUMPIDA')),
    -- Coherencia: solo las prácticas terminadas tienen fecha de fin real (hallazgo 8).
    CONSTRAINT CK_Practica_FinReal
        CHECK ((estado IN (N'FINALIZADA', N'INTERRUMPIDA') AND fecha_fin_real IS NOT NULL)
            OR (estado IN (N'PLANIFICADA', N'EN_CURSO') AND fecha_fin_real IS NULL)),
    CONSTRAINT FK_Practica_Postulacion FOREIGN KEY (id_postulacion)
        REFERENCES Postulacion (id_postulacion)
);
GO

-- Cambios de estado de la práctica; lo cargan los procedimientos (decisión 3).
CREATE TABLE Historial_Practica (
    id_historial INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    estado_anterior NVARCHAR(15) NULL,
    estado_nuevo NVARCHAR(15) NOT NULL,
    fecha_cambio DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    motivo NVARCHAR(500) NULL,
    usuario NVARCHAR(128) NOT NULL DEFAULT ORIGINAL_LOGIN(),

    CONSTRAINT PK_Historial_Practica PRIMARY KEY (id_historial),
    CONSTRAINT CK_HistorialPractica_EstadoAnterior
        CHECK (estado_anterior IS NULL OR estado_anterior IN (
            N'PLANIFICADA', N'EN_CURSO', N'FINALIZADA', N'INTERRUMPIDA'
        )),
    CONSTRAINT CK_HistorialPractica_EstadoNuevo
        CHECK (estado_nuevo IN (
            N'PLANIFICADA', N'EN_CURSO', N'FINALIZADA', N'INTERRUMPIDA'
        )),
    CONSTRAINT FK_HistorialPractica_Practica FOREIGN KEY (id_practica)
        REFERENCES Practica (id_practica)
);
GO

CREATE TABLE Seguimiento (
    id_seguimiento INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    tipo_seguimiento NVARCHAR(15) NOT NULL,
    origen_feedback NVARCHAR(15) NOT NULL,
    estado_seguimiento NVARCHAR(25) NOT NULL,
    observaciones NVARCHAR(500) NOT NULL,
    intervencion_facultad NVARCHAR(500) NULL,
    proxima_revision DATE NULL,

    CONSTRAINT PK_Seguimiento PRIMARY KEY (id_seguimiento),
    CONSTRAINT CK_Seguimiento_Tipo
        CHECK (tipo_seguimiento IN (N'INICIAL', N'PERIODICO', N'EXTRAORDINARIO', N'CIERRE')),
    CONSTRAINT CK_Seguimiento_Origen
        CHECK (origen_feedback IN (N'ESTUDIANTE', N'EMPRESA', N'AMBOS')),
    CONSTRAINT CK_Seguimiento_Estado
        CHECK (estado_seguimiento IN (
            N'SIN_NOVEDADES', N'EN_OBSERVACION', N'REQUIERE_INTERVENCION'
        )),
    CONSTRAINT FK_Seguimiento_Practica FOREIGN KEY (id_practica)
        REFERENCES Practica (id_practica)
);
GO

-- instancia distingue la evaluación PARCIAL de la FINAL (decisión 13, hallazgo 2).
CREATE TABLE Evaluacion (
    id_evaluacion INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    tipo_evaluador NVARCHAR(15) NOT NULL,
    instancia NVARCHAR(7) NOT NULL,
    puntaje_desempeno DECIMAL(3,1) NULL,
    puntaje_satisfaccion DECIMAL(3,1) NULL,
    resultado NVARCHAR(20) NOT NULL,
    comentarios NVARCHAR(500) NULL,

    CONSTRAINT PK_Evaluacion PRIMARY KEY (id_evaluacion),
    CONSTRAINT UQ_Evaluacion_Practica_Tipo_Instancia
        UNIQUE (id_practica, tipo_evaluador, instancia),
    CONSTRAINT CK_Evaluacion_Tipo
        CHECK (tipo_evaluador IN (N'ESTUDIANTE', N'EMPRESA', N'UNIVERSIDAD')),
    CONSTRAINT CK_Evaluacion_Instancia
        CHECK (instancia IN (N'PARCIAL', N'FINAL')),
    CONSTRAINT CK_Evaluacion_Resultado
        CHECK (resultado IN (N'SATISFACTORIA', N'A_MEJORAR', N'INSATISFACTORIA')),
    CONSTRAINT CK_Evaluacion_Desempeno
        CHECK (puntaje_desempeno IS NULL OR puntaje_desempeno BETWEEN 1 AND 5),
    CONSTRAINT CK_Evaluacion_Satisfaccion
        CHECK (puntaje_satisfaccion IS NULL OR puntaje_satisfaccion BETWEEN 1 AND 5),
    CONSTRAINT FK_Evaluacion_Practica FOREIGN KEY (id_practica)
        REFERENCES Practica (id_practica)
);
GO

CREATE TABLE Auditoria_Cambios (
    id_auditoria INT IDENTITY(1,1) NOT NULL,
    tabla NVARCHAR(50) NOT NULL,
    id_registro INT NOT NULL,
    operacion NVARCHAR(10) NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    valor_anterior NVARCHAR(100) NULL,
    valor_nuevo NVARCHAR(100) NULL,
    usuario NVARCHAR(128) NOT NULL DEFAULT ORIGINAL_LOGIN(),

    CONSTRAINT PK_Auditoria_Cambios PRIMARY KEY (id_auditoria),
    CONSTRAINT CK_Auditoria_Operacion CHECK (operacion = N'UPDATE')
);
GO

/* ================================================================
   2. VISTAS
   ================================================================ */

-- Avance por (estudiante, carrera): materias activas aprobadas sobre el total.
CREATE VIEW vw_AvanceAcademico
AS
SELECT
    e.id_estudiante,
    e.legajo,
    e.nombre,
    e.apellido,
    c.id_carrera,
    c.nombre AS carrera,
    c.plan_estudios,
    ec.estado AS estado_en_carrera,
    COUNT(em.id_materia) AS materias_aprobadas,
    COUNT(m.id_materia) AS total_materias,
    CAST(CASE
        WHEN COUNT(m.id_materia) = 0 THEN 0
        ELSE COUNT(em.id_materia) * 100.0 / COUNT(m.id_materia)
    END AS DECIMAL(5,2)) AS porcentaje_avance
FROM Estudiante_Carrera ec
INNER JOIN Estudiante e ON e.id_estudiante = ec.id_estudiante
INNER JOIN Carrera c ON c.id_carrera = ec.id_carrera
LEFT JOIN Materia m ON m.id_carrera = ec.id_carrera AND m.activo = 1
LEFT JOIN Estudiante_Materia em
    ON em.id_estudiante = ec.id_estudiante
   AND em.id_materia = m.id_materia
GROUP BY
    e.id_estudiante, e.legajo, e.nombre, e.apellido,
    c.id_carrera, c.nombre, c.plan_estudios, ec.estado;
GO

CREATE VIEW vw_PracticasActivas
AS
SELECT
    p.id_practica,
    p.fecha_inicio,
    p.fecha_fin_prevista,
    p.estado,
    e.legajo,
    e.nombre AS nombre_estudiante,
    e.apellido AS apellido_estudiante,
    c.nombre AS carrera,
    o.titulo AS oferta,
    em.razon_social AS empresa
FROM Practica p
INNER JOIN Postulacion po ON po.id_postulacion = p.id_postulacion
INNER JOIN Estudiante e ON e.id_estudiante = po.id_estudiante
INNER JOIN Carrera c ON c.id_carrera = po.id_carrera
INNER JOIN Oferta o ON o.id_oferta = po.id_oferta
INNER JOIN Empresa em ON em.id_empresa = o.id_empresa
WHERE p.estado IN (N'PLANIFICADA', N'EN_CURSO');
GO

CREATE VIEW vw_SeguimientoPractica
AS
SELECT
    p.id_practica,
    e.legajo,
    e.nombre AS nombre_estudiante,
    e.apellido AS apellido_estudiante,
    em.razon_social AS empresa,
    s.fecha,
    s.tipo_seguimiento,
    s.origen_feedback,
    s.estado_seguimiento,
    s.observaciones,
    s.intervencion_facultad,
    s.proxima_revision
FROM Practica p
INNER JOIN Postulacion po ON po.id_postulacion = p.id_postulacion
INNER JOIN Estudiante e ON e.id_estudiante = po.id_estudiante
INNER JOIN Oferta o ON o.id_oferta = po.id_oferta
INNER JOIN Empresa em ON em.id_empresa = o.id_empresa
LEFT JOIN Seguimiento s ON s.id_practica = p.id_practica;
GO

-- Prácticas en curso cuyo ÚLTIMO seguimiento pide atención (hallazgo 7).
CREATE VIEW vw_PracticasQueRequierenIntervencion
AS
SELECT
    p.id_practica,
    e.legajo,
    e.nombre AS nombre_estudiante,
    e.apellido AS apellido_estudiante,
    em.razon_social AS empresa,
    s.fecha,
    s.estado_seguimiento,
    s.observaciones,
    s.intervencion_facultad,
    s.proxima_revision
FROM Practica p
INNER JOIN Postulacion po ON po.id_postulacion = p.id_postulacion
INNER JOIN Estudiante e ON e.id_estudiante = po.id_estudiante
INNER JOIN Oferta o ON o.id_oferta = po.id_oferta
INNER JOIN Empresa em ON em.id_empresa = o.id_empresa
CROSS APPLY (
    SELECT TOP 1 s1.*
    FROM Seguimiento s1
    WHERE s1.id_practica = p.id_practica
    ORDER BY s1.fecha DESC, s1.id_seguimiento DESC
) s
WHERE p.estado = N'EN_CURSO'
  AND s.estado_seguimiento IN (N'EN_OBSERVACION', N'REQUIERE_INTERVENCION');
GO

-- Embudo acumulativo (hallazgo 21): por oferta y estado, cuántas postulaciones
-- llegaron alguna vez a ese estado según el historial (no solo el estado actual).
CREATE VIEW vw_EmbudoPostulaciones
AS
SELECT
    o.id_oferta,
    o.titulo,
    h.estado_nuevo AS estado,
    COUNT(DISTINCT h.id_postulacion) AS cantidad_postulaciones
FROM Oferta o
INNER JOIN Postulacion p ON p.id_oferta = o.id_oferta
INNER JOIN Postulacion_Estado_Historial h ON h.id_postulacion = p.id_postulacion
GROUP BY o.id_oferta, o.titulo, h.estado_nuevo;
GO

-- Solo evaluaciones FINAL, para no mezclar con las parciales.
CREATE VIEW vw_ResultadosEmpresa
AS
SELECT
    em.id_empresa,
    em.razon_social,
    COUNT(DISTINCT p.id_practica) AS cantidad_practicas,
    AVG(ev.puntaje_desempeno) AS promedio_desempeno,
    AVG(ev.puntaje_satisfaccion) AS promedio_satisfaccion
FROM Empresa em
LEFT JOIN Oferta o ON o.id_empresa = em.id_empresa
LEFT JOIN Postulacion po ON po.id_oferta = o.id_oferta
LEFT JOIN Practica p ON p.id_postulacion = po.id_postulacion
LEFT JOIN Evaluacion ev
    ON ev.id_practica = p.id_practica
   AND ev.instancia = N'FINAL'
GROUP BY em.id_empresa, em.razon_social;
GO

-- Por la carrera de la postulación; solo evaluaciones FINAL.
CREATE VIEW vw_ResultadosCarrera
AS
SELECT
    c.id_carrera,
    c.nombre AS carrera,
    c.plan_estudios,
    COUNT(DISTINCT p.id_practica) AS cantidad_practicas,
    AVG(ev.puntaje_desempeno) AS promedio_desempeno,
    AVG(ev.puntaje_satisfaccion) AS promedio_satisfaccion
FROM Carrera c
LEFT JOIN Postulacion po ON po.id_carrera = c.id_carrera
LEFT JOIN Practica p ON p.id_postulacion = po.id_postulacion
LEFT JOIN Evaluacion ev
    ON ev.id_practica = p.id_practica
   AND ev.instancia = N'FINAL'
GROUP BY c.id_carrera, c.nombre, c.plan_estudios;
GO

-- Compara niveles (hallazgo 21): cuántos estudiantes alcanzan el nivel máximo
-- que piden las ofertas. Subconsultas agregadas, sin producto cartesiano.
CREATE VIEW vw_BrechaCompetencias
AS
SELECT
    c.id_competencia,
    c.nombre AS competencia,
    ISNULL(d.ofertas, 0) AS ofertas_que_la_solicitan,
    d.nivel_requerido_max,
    s.estudiantes AS estudiantes_que_la_declaran,
    ISNULL(s.alcanzan, 0) AS estudiantes_que_alcanzan_nivel,
    ISNULL(d.ofertas, 0) - ISNULL(s.alcanzan, 0) AS brecha
FROM Competencia c
LEFT JOIN (
    SELECT id_competencia,
           COUNT(*) AS ofertas,
           MAX(nivel_requerido) AS nivel_requerido_max
    FROM Oferta_Competencia
    GROUP BY id_competencia
) d ON d.id_competencia = c.id_competencia
OUTER APPLY (
    -- El CASE va en una tabla derivada: SQL Server no admite agregar una
    -- expresión que mezcla columnas propias con una referencia externa (Msg 8124).
    SELECT COUNT(*) AS estudiantes, SUM(x.alcanza) AS alcanzan
    FROM (
        SELECT CASE WHEN ec.nivel_declarado >= d.nivel_requerido_max
                    THEN 1 ELSE 0 END AS alcanza
        FROM Estudiante_Competencia ec
        WHERE ec.id_competencia = c.id_competencia
    ) x
) s;
GO

CREATE VIEW vw_OfertasPorCarrera
AS
SELECT
    c.id_carrera,
    c.nombre AS carrera,
    c.plan_estudios,
    o.id_oferta,
    o.titulo,
    em.razon_social AS empresa,
    o.estado,
    o.fecha_cierre,
    oc.pertinencia,
    oc.criterio_pertinencia
FROM Carrera c
INNER JOIN Oferta_Carrera oc ON oc.id_carrera = c.id_carrera
INNER JOIN Oferta o ON o.id_oferta = oc.id_oferta
INNER JOIN Empresa em ON em.id_empresa = o.id_empresa;
GO

/* ================================================================
   3. FUNCIÓN
   Orientativa (decisión 21): no considera "obligatoria";
   las obligatorias faltantes las informa usp_VerCompatibilidad.
   ================================================================ */

CREATE FUNCTION fn_PorcentajeCompatibilidad (
    @id_estudiante INT,
    @id_oferta INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total_competencias INT;
    DECLARE @competencias_cumplidas INT;
    DECLARE @porcentaje DECIMAL(5,2);

    SELECT @total_competencias = COUNT(*)
    FROM Oferta_Competencia
    WHERE id_oferta = @id_oferta;

    SELECT @competencias_cumplidas = COUNT(*)
    FROM Oferta_Competencia oc
    INNER JOIN Estudiante_Competencia ec
        ON ec.id_competencia = oc.id_competencia
       AND ec.id_estudiante = @id_estudiante
    WHERE oc.id_oferta = @id_oferta
      AND ec.nivel_declarado >= oc.nivel_requerido;

    IF @total_competencias = 0
        SET @porcentaje = 0;
    ELSE
        SET @porcentaje = CAST(
            @competencias_cumplidas * 100.0 / @total_competencias
            AS DECIMAL(5,2)
        );

    RETURN @porcentaje;
END;
GO

/* ================================================================
   4. PROCEDIMIENTOS
   Patrón de los que escriben: SET NOCOUNT, XACT_ABORT ON; TRY/TRAN;
   CATCH con ROLLBACK condicionado y THROW. Códigos en decisiones_F1.md:
   50001 inexistente, 50002 estado no válido, 50003 transición no permitida,
   50004 concurrencia, 50005 carrera, 50006 convenio, 50007 vacantes,
   50008 fechas, 50009 requisitos de cierre, 50010 duplicado,
   50011 dato obligatorio faltante.
   ================================================================ */

CREATE PROCEDURE usp_RegistrarMateriaAprobada
    @id_estudiante INT,
    @id_materia INT,
    @fecha_aprobacion DATE
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante)
            THROW 50001, N'El estudiante no existe.', 1;
        IF NOT EXISTS (SELECT 1 FROM Materia WHERE id_materia = @id_materia)
            THROW 50001, N'La materia no existe.', 1;
        IF NOT EXISTS (
            SELECT 1
            FROM Materia m
            INNER JOIN Estudiante_Carrera ec ON ec.id_carrera = m.id_carrera
            WHERE m.id_materia = @id_materia
              AND ec.id_estudiante = @id_estudiante
        )
            THROW 50005, N'La materia no pertenece a ninguna carrera del estudiante.', 1;

        INSERT INTO Estudiante_Materia (id_estudiante, id_materia, fecha_aprobacion)
        VALUES (@id_estudiante, @id_materia, @fecha_aprobacion);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_PublicarOferta
    @id_oferta INT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @hoy DATE = CAST(GETDATE() AS date);

        IF NOT EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta)
            THROW 50001, N'La oferta no existe.', 1;
        IF NOT EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta AND estado = N'BORRADOR')
            THROW 50002, N'Solo se publica una oferta en BORRADOR.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Oferta o
            INNER JOIN Empresa e ON e.id_empresa = o.id_empresa
            WHERE o.id_oferta = @id_oferta AND e.estado_vinculo = N'ACTIVA'
        )
            THROW 50002, N'La empresa no está ACTIVA.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Oferta o
            INNER JOIN Convenio c
                ON c.id_convenio = o.id_convenio
               AND c.id_empresa = o.id_empresa
            WHERE o.id_oferta = @id_oferta
              AND c.estado = N'VIGENTE'
              AND (c.fecha_fin IS NULL OR c.fecha_fin >= @hoy)
        )
            THROW 50006, N'La oferta no tiene un convenio vigente.', 1;
        IF NOT EXISTS (SELECT 1 FROM Oferta_Carrera WHERE id_oferta = @id_oferta)
            THROW 50005, N'La oferta no está dirigida a ninguna carrera.', 1;
        IF NOT EXISTS (SELECT 1 FROM Oferta_Competencia WHERE id_oferta = @id_oferta)
            THROW 50011, N'La oferta no tiene competencias.', 1;
        IF EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta AND fecha_cierre < @hoy)
            THROW 50008, N'La fecha de cierre de la oferta ya pasó.', 1;

        UPDATE Oferta
        SET estado = N'PUBLICADA',
            fecha_publicacion = @hoy
        WHERE id_oferta = @id_oferta
          AND estado = N'BORRADOR';
        IF @@ROWCOUNT = 0
            THROW 50004, N'El estado de la oferta cambió durante la operación.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_RegistrarPostulacion
    @id_estudiante INT,
    @id_oferta INT,
    @id_carrera INT,
    @origen NVARCHAR(30),
    @observaciones NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @id_postulacion INT;

        IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante)
            THROW 50001, N'El estudiante no existe.', 1;
        IF NOT EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta)
            THROW 50001, N'La oferta no existe.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Estudiante_Carrera
            WHERE id_estudiante = @id_estudiante AND id_carrera = @id_carrera
        )
            THROW 50005, N'El estudiante no cursa esa carrera.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Oferta_Carrera
            WHERE id_oferta = @id_oferta AND id_carrera = @id_carrera
        )
            THROW 50005, N'La oferta no está dirigida a esa carrera.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Estudiante_Carrera
            WHERE id_estudiante = @id_estudiante
              AND id_carrera = @id_carrera
              AND estado = N'ACTIVO'
        )
            THROW 50002, N'El estudiante no está ACTIVO en esa carrera.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Oferta
            WHERE id_oferta = @id_oferta
              AND estado = N'PUBLICADA'
              AND fecha_cierre >= CAST(GETDATE() AS date)
        )
            THROW 50002, N'La oferta no admite postulaciones.', 1;
        IF EXISTS (
            SELECT 1 FROM Postulacion
            WHERE id_estudiante = @id_estudiante AND id_oferta = @id_oferta
        )
            THROW 50010, N'El estudiante ya se postuló a esa oferta.', 1;

        INSERT INTO Postulacion
            (id_estudiante, id_oferta, id_carrera, estado, origen, observaciones)
        VALUES
            (@id_estudiante, @id_oferta, @id_carrera, N'RECIBIDA', @origen, @observaciones);

        SET @id_postulacion = SCOPE_IDENTITY();

        INSERT INTO Postulacion_Estado_Historial
            (id_postulacion, estado_anterior, estado_nuevo, motivo)
        VALUES
            (@id_postulacion, NULL, N'RECIBIDA', N'Registro inicial');

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_ModificarPostulacion
    @id_postulacion INT,
    @origen NVARCHAR(30),
    @observaciones NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Postulacion WHERE id_postulacion = @id_postulacion)
            THROW 50001, N'La postulación no existe.', 1;

        UPDATE Postulacion
        SET origen = @origen,
            observaciones = @observaciones
        WHERE id_postulacion = @id_postulacion
          AND estado IN (N'RECIBIDA', N'EN_REVISION');
        IF @@ROWCOUNT = 0
            THROW 50002, N'La postulación ya no puede modificarse.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_CambiarEstadoPostulacion
    @id_postulacion INT,
    @estado_nuevo NVARCHAR(15),
    @motivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estado_anterior NVARCHAR(15);
        DECLARE @id_oferta INT;
        DECLARE @vacantes INT;

        SELECT @estado_anterior = estado, @id_oferta = id_oferta
        FROM Postulacion
        WHERE id_postulacion = @id_postulacion;

        IF @estado_anterior IS NULL
            THROW 50001, N'La postulación no existe.', 1;

        SET @estado_nuevo = ISNULL(@estado_nuevo, N'');
        IF NOT (
            (@estado_anterior = N'RECIBIDA' AND @estado_nuevo IN (N'EN_REVISION', N'RETIRADA'))
            OR (@estado_anterior = N'EN_REVISION' AND @estado_nuevo IN (N'ENTREVISTA', N'RECHAZADA', N'RETIRADA'))
            OR (@estado_anterior = N'ENTREVISTA' AND @estado_nuevo IN (N'SELECCIONADA', N'RECHAZADA', N'RETIRADA'))
        )
            THROW 50003, N'El cambio de estado no está permitido.', 1;

        IF @estado_nuevo = N'SELECCIONADA'
        BEGIN
            -- El bloqueo sobre la oferta serializa las selecciones concurrentes.
            SELECT @vacantes = vacantes
            FROM Oferta WITH (UPDLOCK, HOLDLOCK)
            WHERE id_oferta = @id_oferta;

            IF (SELECT COUNT(*) FROM Postulacion
                WHERE id_oferta = @id_oferta AND estado = N'SELECCIONADA') >= @vacantes
                THROW 50007, N'La oferta no tiene vacantes disponibles.', 1;
        END;

        -- UPDATE condicionado al estado leído (hallazgo 6).
        UPDATE Postulacion
        SET estado = @estado_nuevo
        WHERE id_postulacion = @id_postulacion
          AND estado = @estado_anterior;
        IF @@ROWCOUNT = 0
            THROW 50004, N'El estado de la postulación cambió durante la operación.', 1;

        INSERT INTO Postulacion_Estado_Historial
            (id_postulacion, estado_anterior, estado_nuevo, motivo)
        VALUES
            (@id_postulacion, @estado_anterior, @estado_nuevo, @motivo);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

-- Si la postulación está EN_REVISION, la pasa a ENTREVISTA (hallazgo 22).
CREATE PROCEDURE usp_RegistrarEntrevista
    @id_postulacion INT,
    @fecha DATETIME2,
    @etapa NVARCHAR(30),
    @resultado NVARCHAR(15),
    @devolucion NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estado NVARCHAR(15);

        SELECT @estado = estado
        FROM Postulacion
        WHERE id_postulacion = @id_postulacion;

        IF @estado IS NULL
            THROW 50001, N'La postulación no existe.', 1;
        IF @estado NOT IN (N'EN_REVISION', N'ENTREVISTA')
            THROW 50002, N'La postulación no admite entrevistas.', 1;

        IF @estado = N'EN_REVISION'
        BEGIN
            UPDATE Postulacion
            SET estado = N'ENTREVISTA'
            WHERE id_postulacion = @id_postulacion
              AND estado = N'EN_REVISION';
            IF @@ROWCOUNT = 0
                THROW 50004, N'El estado de la postulación cambió durante la operación.', 1;

            INSERT INTO Postulacion_Estado_Historial
                (id_postulacion, estado_anterior, estado_nuevo, motivo)
            VALUES
                (@id_postulacion, N'EN_REVISION', N'ENTREVISTA', N'Entrevista registrada');
        END;

        INSERT INTO Entrevista (id_postulacion, fecha, etapa, resultado, devolucion)
        VALUES (@id_postulacion, @fecha, @etapa, @resultado, @devolucion);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

-- Resuelve una entrevista PENDIENTE (hallazgo 22).
CREATE PROCEDURE usp_ActualizarResultadoEntrevista
    @id_entrevista INT,
    @resultado NVARCHAR(15),
    @devolucion NVARCHAR(400)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Entrevista WHERE id_entrevista = @id_entrevista)
            THROW 50001, N'La entrevista no existe.', 1;
        IF ISNULL(@resultado, N'') NOT IN (N'APROBADA', N'RECHAZADA')
            THROW 50003, N'El resultado debe ser APROBADA o RECHAZADA.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Entrevista
            WHERE id_entrevista = @id_entrevista AND resultado = N'PENDIENTE'
        )
            THROW 50002, N'La entrevista ya tiene resultado.', 1;

        UPDATE Entrevista
        SET resultado = @resultado,
            devolucion = ISNULL(@devolucion, devolucion)
        WHERE id_entrevista = @id_entrevista
          AND resultado = N'PENDIENTE';
        IF @@ROWCOUNT = 0
            THROW 50004, N'El resultado de la entrevista cambió durante la operación.', 1;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_CrearPractica
    @id_postulacion INT,
    @fecha_inicio DATE,
    @fecha_fin_prevista DATE,
    @horas_semanales INT,
    @modalidad NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estado NVARCHAR(15);
        DECLARE @id_estudiante INT;
        DECLARE @id_carrera INT;
        DECLARE @id_practica INT;

        SELECT @estado = estado, @id_estudiante = id_estudiante, @id_carrera = id_carrera
        FROM Postulacion
        WHERE id_postulacion = @id_postulacion;

        IF @estado IS NULL
            THROW 50001, N'La postulación no existe.', 1;
        IF @estado <> N'SELECCIONADA'
            THROW 50002, N'La postulación no está SELECCIONADA.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Estudiante_Carrera
            WHERE id_estudiante = @id_estudiante
              AND id_carrera = @id_carrera
              AND estado = N'ACTIVO'
        )
            THROW 50002, N'El estudiante no está ACTIVO en la carrera de la postulación.', 1;
        IF @fecha_inicio IS NULL OR @fecha_fin_prevista IS NULL
            THROW 50011, N'Las fechas de la práctica son obligatorias.', 1;
        IF @fecha_fin_prevista < @fecha_inicio
            THROW 50008, N'La fecha de fin prevista es anterior al inicio.', 1;
        IF NOT EXISTS (
            SELECT 1
            FROM Postulacion p
            INNER JOIN Oferta o ON o.id_oferta = p.id_oferta
            INNER JOIN Convenio c
                ON c.id_convenio = o.id_convenio
               AND c.id_empresa = o.id_empresa
            WHERE p.id_postulacion = @id_postulacion
              AND c.estado = N'VIGENTE'
        )
            THROW 50006, N'La oferta no tiene un convenio vigente.', 1;
        -- La práctica completa tiene que quedar dentro del convenio (hallazgo 23).
        IF NOT EXISTS (
            SELECT 1
            FROM Postulacion p
            INNER JOIN Oferta o ON o.id_oferta = p.id_oferta
            INNER JOIN Convenio c
                ON c.id_convenio = o.id_convenio
               AND c.id_empresa = o.id_empresa
            WHERE p.id_postulacion = @id_postulacion
              AND c.fecha_inicio <= @fecha_inicio
              AND (c.fecha_fin IS NULL OR c.fecha_fin >= @fecha_fin_prevista)
        )
            THROW 50008, N'La práctica no queda dentro del período del convenio.', 1;
        IF EXISTS (SELECT 1 FROM Practica WHERE id_postulacion = @id_postulacion)
            THROW 50010, N'La postulación ya tiene una práctica.', 1;
        -- Sin prácticas simultáneas del mismo estudiante; el bloqueo evita la carrera.
        IF EXISTS (
            SELECT 1
            FROM Practica pr WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN Postulacion po ON po.id_postulacion = pr.id_postulacion
            WHERE po.id_estudiante = @id_estudiante
              AND pr.estado IN (N'PLANIFICADA', N'EN_CURSO')
        )
            THROW 50010, N'El estudiante ya tiene una práctica planificada o en curso.', 1;

        INSERT INTO Practica
            (id_postulacion, fecha_inicio, fecha_fin_prevista,
             horas_semanales, modalidad, estado)
        VALUES
            (@id_postulacion, @fecha_inicio, @fecha_fin_prevista,
             @horas_semanales, @modalidad, N'PLANIFICADA');

        SET @id_practica = SCOPE_IDENTITY();

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, NULL, N'PLANIFICADA', N'Práctica creada');

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_IniciarPractica
    @id_practica INT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estado NVARCHAR(15);
        DECLARE @fecha_inicio DATE;

        SELECT @estado = estado, @fecha_inicio = fecha_inicio
        FROM Practica
        WHERE id_practica = @id_practica;

        IF @estado IS NULL
            THROW 50001, N'La práctica no existe.', 1;
        IF @estado <> N'PLANIFICADA'
            THROW 50003, N'Solo se inicia una práctica PLANIFICADA.', 1;
        IF @fecha_inicio > CAST(GETDATE() AS date)
            THROW 50008, N'La práctica todavía no llegó a su fecha de inicio.', 1;

        UPDATE Practica
        SET estado = N'EN_CURSO'
        WHERE id_practica = @id_practica
          AND estado = N'PLANIFICADA';
        IF @@ROWCOUNT = 0
            THROW 50004, N'El estado de la práctica cambió durante la operación.', 1;

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, N'PLANIFICADA', N'EN_CURSO', N'Inicio de la práctica');

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_RegistrarSeguimiento
    @id_practica INT,
    @tipo_seguimiento NVARCHAR(15),
    @origen_feedback NVARCHAR(15),
    @estado_seguimiento NVARCHAR(25),
    @observaciones NVARCHAR(500),
    @intervencion_facultad NVARCHAR(500),
    @proxima_revision DATE
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Practica WHERE id_practica = @id_practica)
            THROW 50001, N'La práctica no existe.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Practica
            WHERE id_practica = @id_practica AND estado = N'EN_CURSO'
        )
            THROW 50002, N'Solo se registran seguimientos de prácticas EN_CURSO.', 1;

        INSERT INTO Seguimiento
            (id_practica, tipo_seguimiento, origen_feedback,
             estado_seguimiento, observaciones,
             intervencion_facultad, proxima_revision)
        VALUES
            (@id_practica, @tipo_seguimiento, @origen_feedback,
             @estado_seguimiento, @observaciones,
             @intervencion_facultad, @proxima_revision);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_RegistrarEvaluacion
    @id_practica INT,
    @tipo_evaluador NVARCHAR(15),
    @instancia NVARCHAR(7),
    @puntaje_desempeno DECIMAL(3,1),
    @puntaje_satisfaccion DECIMAL(3,1),
    @resultado NVARCHAR(20),
    @comentarios NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Practica WHERE id_practica = @id_practica)
            THROW 50001, N'La práctica no existe.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Practica
            WHERE id_practica = @id_practica AND estado = N'EN_CURSO'
        )
            THROW 50002, N'Solo se evalúan prácticas EN_CURSO.', 1;

        INSERT INTO Evaluacion
            (id_practica, tipo_evaluador, instancia, puntaje_desempeno,
             puntaje_satisfaccion, resultado, comentarios)
        VALUES
            (@id_practica, @tipo_evaluador, @instancia, @puntaje_desempeno,
             @puntaje_satisfaccion, @resultado, @comentarios);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_CerrarPractica
    @id_practica INT,
    @fecha_fin_real DATE,
    @motivo_cierre NVARCHAR(250)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estado NVARCHAR(15);
        DECLARE @fecha_inicio DATE;

        SELECT @estado = estado, @fecha_inicio = fecha_inicio
        FROM Practica
        WHERE id_practica = @id_practica;

        IF @estado IS NULL
            THROW 50001, N'La práctica no existe.', 1;
        IF @estado <> N'EN_CURSO'
            THROW 50003, N'Solo se cierra una práctica EN_CURSO.', 1;
        IF @fecha_fin_real IS NULL
            THROW 50011, N'La fecha de fin real es obligatoria.', 1;
        IF @fecha_fin_real < @fecha_inicio
            THROW 50008, N'La fecha de fin real es anterior al inicio.', 1;
        IF NOT EXISTS (SELECT 1 FROM Seguimiento WHERE id_practica = @id_practica)
            THROW 50009, N'La práctica no tiene seguimientos.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM Evaluacion
            WHERE id_practica = @id_practica
              AND tipo_evaluador = N'ESTUDIANTE'
              AND instancia = N'FINAL'
        )
        OR NOT EXISTS (
            SELECT 1 FROM Evaluacion
            WHERE id_practica = @id_practica
              AND tipo_evaluador = N'EMPRESA'
              AND instancia = N'FINAL'
        )
            THROW 50009, N'Faltan las evaluaciones FINAL del estudiante y de la empresa.', 1;

        UPDATE Practica
        SET estado = N'FINALIZADA',
            fecha_fin_real = @fecha_fin_real,
            motivo_cierre = @motivo_cierre
        WHERE id_practica = @id_practica
          AND estado = N'EN_CURSO';
        IF @@ROWCOUNT = 0
            THROW 50004, N'El estado de la práctica cambió durante la operación.', 1;

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, N'EN_CURSO', N'FINALIZADA', @motivo_cierre);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE PROCEDURE usp_InterrumpirPractica
    @id_practica INT,
    @fecha_fin_real DATE,
    @motivo_cierre NVARCHAR(250)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estado NVARCHAR(15);
        DECLARE @fecha_inicio DATE;

        SELECT @estado = estado, @fecha_inicio = fecha_inicio
        FROM Practica
        WHERE id_practica = @id_practica;

        IF @estado IS NULL
            THROW 50001, N'La práctica no existe.', 1;
        IF @estado NOT IN (N'PLANIFICADA', N'EN_CURSO')
            THROW 50003, N'Solo se interrumpe una práctica PLANIFICADA o EN_CURSO.', 1;
        IF @motivo_cierre IS NULL OR @fecha_fin_real IS NULL
            THROW 50011, N'El motivo y la fecha de fin real son obligatorios.', 1;
        IF @fecha_fin_real < @fecha_inicio
            THROW 50008, N'La fecha de fin real es anterior al inicio.', 1;

        UPDATE Practica
        SET estado = N'INTERRUMPIDA',
            fecha_fin_real = @fecha_fin_real,
            motivo_cierre = @motivo_cierre
        WHERE id_practica = @id_practica
          AND estado = @estado;
        IF @@ROWCOUNT = 0
            THROW 50004, N'El estado de la práctica cambió durante la operación.', 1;

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, @estado, N'INTERRUMPIDA', @motivo_cierre);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO

-- Solo lectura: ofertas publicadas y vigentes de las carreras en que el
-- estudiante está ACTIVO, con su compatibilidad orientativa.
CREATE PROCEDURE usp_VerCompatibilidad
    @id_estudiante INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante)
        THROW 50001, N'El estudiante no existe.', 1;

    SELECT
        o.id_oferta,
        o.titulo,
        em.razon_social AS empresa,
        COUNT(oc.id_competencia) AS total_competencias,
        SUM(
            CASE
                WHEN ec.nivel_declarado >= oc.nivel_requerido THEN 1
                ELSE 0
            END
        ) AS competencias_cumplidas,
        SUM(
            CASE
                WHEN oc.obligatoria = 1
                 AND (ec.id_competencia IS NULL OR ec.nivel_declarado < oc.nivel_requerido)
                    THEN 1
                ELSE 0
            END
        ) AS obligatorias_faltantes,
        dbo.fn_PorcentajeCompatibilidad(
            @id_estudiante, o.id_oferta
        ) AS porcentaje_compatibilidad
    FROM Oferta o
    INNER JOIN Empresa em ON em.id_empresa = o.id_empresa
    INNER JOIN Oferta_Competencia oc ON oc.id_oferta = o.id_oferta
    LEFT JOIN Estudiante_Competencia ec
        ON ec.id_estudiante = @id_estudiante
       AND ec.id_competencia = oc.id_competencia
    WHERE o.estado = N'PUBLICADA'
      AND o.fecha_cierre >= CAST(GETDATE() AS date)
      AND EXISTS (
          SELECT 1
          FROM Oferta_Carrera ofc
          INNER JOIN Estudiante_Carrera esc
              ON esc.id_carrera = ofc.id_carrera
          WHERE ofc.id_oferta = o.id_oferta
            AND esc.id_estudiante = @id_estudiante
            AND esc.estado = N'ACTIVO'
      )
    GROUP BY o.id_oferta, o.titulo, em.razon_social;
END;
GO

/* ================================================================
   5. TRIGGERS DE AUDITORÍA
   Se eliminan los de Postulacion y Practica: sus cambios de estado ya
   quedan en Postulacion_Estado_Historial y Historial_Practica.
   Se mantienen los de Seguimiento y Evaluacion: ningún procedimiento
   modifica esas filas, así que cualquier UPDATE es una corrección manual
   y conviene dejarla registrada con su usuario. Solo auditan si el valor
   cambió; el usuario lo completa el DEFAULT ORIGINAL_LOGIN().
   ================================================================ */

CREATE TRIGGER tr_Seguimiento_Auditoria
ON Seguimiento
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria_Cambios
        (tabla, id_registro, operacion, valor_anterior, valor_nuevo)
    SELECT
        N'Seguimiento', i.id_seguimiento, N'UPDATE',
        d.estado_seguimiento, i.estado_seguimiento
    FROM inserted i
    INNER JOIN deleted d ON d.id_seguimiento = i.id_seguimiento
    WHERE d.estado_seguimiento <> i.estado_seguimiento;
END;
GO

CREATE TRIGGER tr_Evaluacion_Auditoria
ON Evaluacion
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria_Cambios
        (tabla, id_registro, operacion, valor_anterior, valor_nuevo)
    SELECT
        N'Evaluacion', i.id_evaluacion, N'UPDATE', d.resultado, i.resultado
    FROM inserted i
    INNER JOIN deleted d ON d.id_evaluacion = i.id_evaluacion
    WHERE d.resultado <> i.resultado;
END;
GO

/* ================================================================
   6. ÍNDICES
   PK y UNIQUE ya crean índice; por eso no se repiten (p. ej. Materia
   por id_carrera queda cubierta por UQ_Materia_Carrera_Codigo).
   ================================================================ */

CREATE INDEX IX_EstudianteCarrera_Carrera ON Estudiante_Carrera (id_carrera);
CREATE INDEX IX_EstudianteMateria_Materia ON Estudiante_Materia (id_materia);
CREATE INDEX IX_EstudianteCompetencia_Competencia ON Estudiante_Competencia (id_competencia);
CREATE INDEX IX_Convenio_Empresa ON Convenio (id_empresa);
CREATE INDEX IX_Oferta_Empresa ON Oferta (id_empresa);
CREATE INDEX IX_Oferta_Convenio ON Oferta (id_convenio, id_empresa);
CREATE INDEX IX_Oferta_Estado ON Oferta (estado, fecha_cierre);
CREATE INDEX IX_OfertaCarrera_Carrera ON Oferta_Carrera (id_carrera);
CREATE INDEX IX_OfertaCompetencia_Competencia ON Oferta_Competencia (id_competencia);
CREATE INDEX IX_Postulacion_Oferta ON Postulacion (id_oferta, estado);
CREATE INDEX IX_Historial_Postulacion ON Postulacion_Estado_Historial (id_postulacion, fecha_cambio);
CREATE INDEX IX_Entrevista_Postulacion ON Entrevista (id_postulacion);
CREATE INDEX IX_Practica_Estado ON Practica (estado);
CREATE INDEX IX_HistorialPractica_Practica ON Historial_Practica (id_practica, fecha_cambio);
CREATE INDEX IX_Seguimiento_Practica ON Seguimiento (id_practica, fecha);
CREATE INDEX IX_Auditoria_Tabla_Registro ON Auditoria_Cambios (tabla, id_registro);
GO
