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
    nombre VARCHAR(100) NOT NULL,
    unidad_academica VARCHAR(100) NOT NULL,
    plan_estudios VARCHAR(30) NOT NULL,
    nivel VARCHAR(30) NOT NULL,
    activo BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_Carrera PRIMARY KEY (id_carrera),
    CONSTRAINT UQ_Carrera_Nombre_Plan UNIQUE (nombre, plan_estudios)
);
GO

CREATE TABLE Materia (
    id_materia INT IDENTITY(1,1) NOT NULL,
    id_carrera INT NOT NULL,
    codigo VARCHAR(20) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
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
    legajo VARCHAR(20) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,

    CONSTRAINT PK_Estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT UQ_Estudiante_Legajo UNIQUE (legajo),
    CONSTRAINT UQ_Estudiante_Email UNIQUE (email)
);
GO

-- Un estudiante puede cursar varias carreras.
CREATE TABLE Estudiante_Carrera (
    id_estudiante INT NOT NULL,
    id_carrera INT NOT NULL,
    anio_ingreso SMALLINT NOT NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',

    CONSTRAINT PK_Estudiante_Carrera PRIMARY KEY (id_estudiante, id_carrera),
    CONSTRAINT CK_EstudianteCarrera_Anio CHECK (anio_ingreso BETWEEN 1900 AND 2100),
    CONSTRAINT CK_EstudianteCarrera_Estado
        CHECK (estado IN ('ACTIVO', 'EGRESADO', 'INACTIVO')),
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
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(500) NULL,
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
    fecha_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

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

CREATE TABLE Empresa (
    id_empresa INT IDENTITY(1,1) NOT NULL,
    cuit VARCHAR(20) NOT NULL,
    razon_social VARCHAR(120) NOT NULL,
    sector VARCHAR(80) NOT NULL,
    tamano VARCHAR(30) NULL,
    ciudad VARCHAR(80) NOT NULL,
    estado_vinculo VARCHAR(15) NOT NULL DEFAULT 'PROSPECTO',

    CONSTRAINT PK_Empresa PRIMARY KEY (id_empresa),
    CONSTRAINT UQ_Empresa_CUIT UNIQUE (cuit),
    CONSTRAINT CK_Empresa_Estado
        CHECK (estado_vinculo IN ('PROSPECTO', 'ACTIVA', 'SUSPENDIDA'))
);
GO

CREATE TABLE Convenio (
    id_convenio INT IDENTITY(1,1) NOT NULL,
    id_empresa INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    estado VARCHAR(15) NOT NULL,
    objetivo VARCHAR(500) NOT NULL,
    cupos_referenciales INT NULL,  -- orientativo, no limita prácticas

    CONSTRAINT PK_Convenio PRIMARY KEY (id_convenio),
    CONSTRAINT CK_Convenio_Fechas
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT CK_Convenio_Estado
        CHECK (estado IN ('VIGENTE', 'VENCIDO', 'SUSPENDIDO')),
    -- Coherencia estado/fecha: un convenio vencido tiene fecha de fin.
    CONSTRAINT CK_Convenio_Vencido
        CHECK (estado <> 'VENCIDO' OR fecha_fin IS NOT NULL),
    CONSTRAINT CK_Convenio_Cupos
        CHECK (cupos_referenciales IS NULL OR cupos_referenciales >= 0),
    CONSTRAINT UQ_Convenio_Id_Empresa
        UNIQUE (id_convenio, id_empresa),
    CONSTRAINT FK_Convenio_Empresa FOREIGN KEY (id_empresa)
        REFERENCES Empresa (id_empresa)
);
GO

-- fecha_publicacion es NULL en borradores; la fija usp_PublicarOferta.
CREATE TABLE Oferta (
    id_oferta INT IDENTITY(1,1) NOT NULL,
    id_empresa INT NOT NULL,
    id_convenio INT NULL,
    titulo VARCHAR(120) NOT NULL,
    descripcion VARCHAR(800) NOT NULL,
    fecha_publicacion DATE NULL,
    fecha_cierre DATE NOT NULL,
    vacantes INT NOT NULL,
    modalidad VARCHAR(15) NOT NULL,
    jornada VARCHAR(40) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'BORRADOR',

    CONSTRAINT PK_Oferta PRIMARY KEY (id_oferta),
    CONSTRAINT CK_Oferta_Fechas
        CHECK (fecha_publicacion IS NULL OR fecha_cierre >= fecha_publicacion),
    CONSTRAINT CK_Oferta_Publicacion
        CHECK (estado = 'BORRADOR' OR fecha_publicacion IS NOT NULL),
    CONSTRAINT CK_Oferta_Vacantes CHECK (vacantes > 0),
    CONSTRAINT CK_Oferta_Modalidad
        CHECK (modalidad IN ('PRESENCIAL', 'REMOTA', 'HIBRIDA')),
    CONSTRAINT CK_Oferta_Estado
        CHECK (estado IN ('BORRADOR', 'PUBLICADA', 'CERRADA', 'CANCELADA')),
    CONSTRAINT FK_Oferta_Empresa FOREIGN KEY (id_empresa)
        REFERENCES Empresa (id_empresa),
    CONSTRAINT FK_Oferta_Convenio_Empresa FOREIGN KEY (id_convenio, id_empresa)
        REFERENCES Convenio (id_convenio, id_empresa)
);
GO

-- Carreras destinatarias de la oferta, con su pertinencia.
CREATE TABLE Oferta_Carrera (
    id_oferta INT NOT NULL,
    id_carrera INT NOT NULL,
    pertinencia VARCHAR(5) NOT NULL,
    criterio_pertinencia VARCHAR(300) NULL,

    CONSTRAINT PK_Oferta_Carrera
        PRIMARY KEY (id_oferta, id_carrera),
    CONSTRAINT CK_OfertaCarrera_Pertinencia
        CHECK (pertinencia IN ('ALTA', 'MEDIA', 'BAJA')),
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
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    estado VARCHAR(15) NOT NULL DEFAULT 'RECIBIDA',
    origen VARCHAR(30) NOT NULL,
    observaciones VARCHAR(500) NULL,

    CONSTRAINT PK_Postulacion PRIMARY KEY (id_postulacion),
    CONSTRAINT UQ_Postulacion_Estudiante_Oferta UNIQUE (id_estudiante, id_oferta),
    CONSTRAINT CK_Postulacion_Estado
        CHECK (estado IN (
            'RECIBIDA', 'EN_REVISION', 'ENTREVISTA',
            'SELECCIONADA', 'RECHAZADA', 'RETIRADA'
        )),
    CONSTRAINT CK_Postulacion_Origen
        CHECK (origen IN ('CV', 'PORTAL', 'REFERIDO', 'FERIA')),
    -- Las FK compuestas ya garantizan que existan el estudiante y la oferta.
    CONSTRAINT FK_Postulacion_EstudianteCarrera FOREIGN KEY (id_estudiante, id_carrera)
        REFERENCES Estudiante_Carrera (id_estudiante, id_carrera),
    CONSTRAINT FK_Postulacion_OfertaCarrera FOREIGN KEY (id_oferta, id_carrera)
        REFERENCES Oferta_Carrera (id_oferta, id_carrera)
);
GO

CREATE TABLE Postulacion_Estado_Historial (
    id_historial INT IDENTITY(1,1) NOT NULL,
    id_postulacion INT NOT NULL,
    estado_anterior VARCHAR(15) NULL,
    estado_nuevo VARCHAR(15) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT GETDATE(),
    motivo VARCHAR(500) NULL,
    usuario VARCHAR(128) NOT NULL DEFAULT ORIGINAL_LOGIN(),

    CONSTRAINT PK_Postulacion_Estado_Historial PRIMARY KEY (id_historial),
    CONSTRAINT CK_Historial_EstadoAnterior
        CHECK (estado_anterior IS NULL OR estado_anterior IN (
            'RECIBIDA', 'EN_REVISION', 'ENTREVISTA',
            'SELECCIONADA', 'RECHAZADA', 'RETIRADA'
        )),
    CONSTRAINT CK_Historial_EstadoNuevo
        CHECK (estado_nuevo IN (
            'RECIBIDA', 'EN_REVISION', 'ENTREVISTA',
            'SELECCIONADA', 'RECHAZADA', 'RETIRADA'
        )),
    CONSTRAINT FK_Historial_Postulacion FOREIGN KEY (id_postulacion)
        REFERENCES Postulacion (id_postulacion)
);
GO

CREATE TABLE Entrevista (
    id_entrevista INT IDENTITY(1,1) NOT NULL,
    id_postulacion INT NOT NULL,
    fecha DATETIME NOT NULL,
    etapa VARCHAR(30) NOT NULL,
    resultado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    devolucion VARCHAR(400) NULL,

    CONSTRAINT PK_Entrevista PRIMARY KEY (id_entrevista),
    CONSTRAINT CK_Entrevista_Etapa
        CHECK (etapa IN ('GENERAL', 'TECNICA', 'RRHH', 'FINAL')),
    CONSTRAINT CK_Entrevista_Resultado
        CHECK (resultado IN ('PENDIENTE', 'APROBADA', 'RECHAZADA')),
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
    modalidad VARCHAR(15) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'PLANIFICADA',
    motivo_cierre VARCHAR(250) NULL,

    CONSTRAINT PK_Practica PRIMARY KEY (id_practica),
    CONSTRAINT UQ_Practica_Postulacion UNIQUE (id_postulacion),
    CONSTRAINT CK_Practica_Fechas
        CHECK (fecha_fin_prevista >= fecha_inicio
            AND (fecha_fin_real IS NULL OR fecha_fin_real >= fecha_inicio)),
    CONSTRAINT CK_Practica_Horas CHECK (horas_semanales BETWEEN 1 AND 48),
    CONSTRAINT CK_Practica_Modalidad
        CHECK (modalidad IN ('PRESENCIAL', 'REMOTA', 'HIBRIDA')),
    CONSTRAINT CK_Practica_Estado
        CHECK (estado IN ('PLANIFICADA', 'EN_CURSO', 'FINALIZADA', 'INTERRUMPIDA')),
    -- Coherencia: solo las prácticas terminadas tienen fecha de fin real.
    CONSTRAINT CK_Practica_FinReal
        CHECK ((estado IN ('FINALIZADA', 'INTERRUMPIDA') AND fecha_fin_real IS NOT NULL)
            OR (estado IN ('PLANIFICADA', 'EN_CURSO') AND fecha_fin_real IS NULL)),
    CONSTRAINT FK_Practica_Postulacion FOREIGN KEY (id_postulacion)
        REFERENCES Postulacion (id_postulacion)
);
GO

-- Cambios de estado de la práctica; lo cargan los procedimientos.
CREATE TABLE Historial_Practica (
    id_historial INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    estado_anterior VARCHAR(15) NULL,
    estado_nuevo VARCHAR(15) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT GETDATE(),
    motivo VARCHAR(500) NULL,
    usuario VARCHAR(128) NOT NULL DEFAULT ORIGINAL_LOGIN(),

    CONSTRAINT PK_Historial_Practica PRIMARY KEY (id_historial),
    CONSTRAINT CK_HistorialPractica_EstadoAnterior
        CHECK (estado_anterior IS NULL OR estado_anterior IN (
            'PLANIFICADA', 'EN_CURSO', 'FINALIZADA', 'INTERRUMPIDA'
        )),
    CONSTRAINT CK_HistorialPractica_EstadoNuevo
        CHECK (estado_nuevo IN (
            'PLANIFICADA', 'EN_CURSO', 'FINALIZADA', 'INTERRUMPIDA'
        )),
    CONSTRAINT FK_HistorialPractica_Practica FOREIGN KEY (id_practica)
        REFERENCES Practica (id_practica)
);
GO

CREATE TABLE Seguimiento (
    id_seguimiento INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    tipo_seguimiento VARCHAR(15) NOT NULL,
    origen_feedback VARCHAR(15) NOT NULL,
    estado_seguimiento VARCHAR(25) NOT NULL,
    observaciones VARCHAR(500) NOT NULL,
    intervencion_facultad VARCHAR(500) NULL,
    proxima_revision DATE NULL,

    CONSTRAINT PK_Seguimiento PRIMARY KEY (id_seguimiento),
    CONSTRAINT CK_Seguimiento_Tipo
        CHECK (tipo_seguimiento IN ('INICIAL', 'PERIODICO', 'EXTRAORDINARIO', 'CIERRE')),
    CONSTRAINT CK_Seguimiento_Origen
        CHECK (origen_feedback IN ('ESTUDIANTE', 'EMPRESA', 'AMBOS')),
    CONSTRAINT CK_Seguimiento_Estado
        CHECK (estado_seguimiento IN (
            'SIN_NOVEDADES', 'EN_OBSERVACION', 'REQUIERE_INTERVENCION'
        )),
    CONSTRAINT FK_Seguimiento_Practica FOREIGN KEY (id_practica)
        REFERENCES Practica (id_practica)
);
GO

-- instancia distingue la evaluación PARCIAL de la FINAL.
CREATE TABLE Evaluacion (
    id_evaluacion INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    tipo_evaluador VARCHAR(15) NOT NULL,
    instancia VARCHAR(7) NOT NULL,
    puntaje_desempeno DECIMAL(3,1) NULL,
    puntaje_satisfaccion DECIMAL(3,1) NULL,
    resultado VARCHAR(20) NOT NULL,
    comentarios VARCHAR(500) NULL,

    CONSTRAINT PK_Evaluacion PRIMARY KEY (id_evaluacion),
    CONSTRAINT UQ_Evaluacion_Practica_Tipo_Instancia
        UNIQUE (id_practica, tipo_evaluador, instancia),
    CONSTRAINT CK_Evaluacion_Tipo
        CHECK (tipo_evaluador IN ('ESTUDIANTE', 'EMPRESA', 'UNIVERSIDAD')),
    CONSTRAINT CK_Evaluacion_Instancia
        CHECK (instancia IN ('PARCIAL', 'FINAL')),
    CONSTRAINT CK_Evaluacion_Resultado
        CHECK (resultado IN ('SATISFACTORIA', 'A_MEJORAR', 'INSATISFACTORIA')),
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
    tabla VARCHAR(50) NOT NULL,
    id_registro INT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    valor_anterior VARCHAR(100) NULL,
    valor_nuevo VARCHAR(100) NULL,
    usuario VARCHAR(128) NOT NULL DEFAULT ORIGINAL_LOGIN(),

    CONSTRAINT PK_Auditoria_Cambios PRIMARY KEY (id_auditoria)
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
WHERE p.estado IN ('PLANIFICADA', 'EN_CURSO');
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

-- Prácticas en curso cuyo ÚLTIMO seguimiento pide atención.
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
INNER JOIN (
    SELECT id_practica, MAX(fecha) AS ultima
    FROM Seguimiento
    GROUP BY id_practica
) u ON u.id_practica = p.id_practica
INNER JOIN Seguimiento s
    ON s.id_practica = u.id_practica
   AND s.fecha = u.ultima
WHERE p.estado = 'EN_CURSO'
  AND s.estado_seguimiento IN ('EN_OBSERVACION', 'REQUIERE_INTERVENCION');
GO

-- Embudo acumulativo: por oferta y estado, cuántas postulaciones
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
   AND ev.instancia = 'FINAL'
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
   AND ev.instancia = 'FINAL'
GROUP BY c.id_carrera, c.nombre, c.plan_estudios;
GO

-- Compara niveles: cuántos estudiantes alcanzan el nivel máximo
-- que piden las ofertas. Subconsultas agregadas, sin producto cartesiano.
CREATE VIEW vw_BrechaCompetencias
AS
SELECT
    c.id_competencia,
    c.nombre AS competencia,
    ISNULL(d.ofertas, 0) AS ofertas_que_la_solicitan,
    d.nivel_requerido_max,
    ISNULL(s.estudiantes, 0) AS estudiantes_que_la_declaran,
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
LEFT JOIN (
    SELECT ec.id_competencia,
           COUNT(*) AS estudiantes,
           SUM(CASE WHEN ec.nivel_declarado >= dm.nivel_requerido_max
                    THEN 1 ELSE 0 END) AS alcanzan
    FROM Estudiante_Competencia ec
    LEFT JOIN (
        SELECT id_competencia, MAX(nivel_requerido) AS nivel_requerido_max
        FROM Oferta_Competencia
        GROUP BY id_competencia
    ) dm ON dm.id_competencia = ec.id_competencia
    GROUP BY ec.id_competencia
) s ON s.id_competencia = c.id_competencia;
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
   Orientativa: no considera "obligatoria";
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
   Patrón de los que escriben: primero los chequeos (si uno no se cumple,
   PRINT con el motivo y RETURN, sin guardar nada) y, si hay más de una
   escritura, BEGIN TRY / TRANSACTION / CATCH con ROLLBACK.
   ================================================================ */

CREATE PROCEDURE usp_RegistrarMateriaAprobada
    @id_estudiante INT,
    @id_materia INT,
    @fecha_aprobacion DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante)
    BEGIN
        PRINT 'El estudiante no existe.';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Materia WHERE id_materia = @id_materia)
    BEGIN
        PRINT 'La materia no existe.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1
        FROM Materia m
        INNER JOIN Estudiante_Carrera ec ON ec.id_carrera = m.id_carrera
        WHERE m.id_materia = @id_materia
          AND ec.id_estudiante = @id_estudiante
    )
    BEGIN
        PRINT 'La materia no pertenece a ninguna carrera del estudiante.';
        RETURN;
    END;

    INSERT INTO Estudiante_Materia (id_estudiante, id_materia, fecha_aprobacion)
    VALUES (@id_estudiante, @id_materia, @fecha_aprobacion);
END;
GO

CREATE PROCEDURE usp_PublicarOferta
    @id_oferta INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(GETDATE() AS date);

    IF NOT EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta)
    BEGIN
        PRINT 'La oferta no existe.';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta AND estado = 'BORRADOR')
    BEGIN
        PRINT 'Solo se publica una oferta en BORRADOR.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Oferta o
        INNER JOIN Empresa e ON e.id_empresa = o.id_empresa
        WHERE o.id_oferta = @id_oferta AND e.estado_vinculo = 'ACTIVA'
    )
    BEGIN
        PRINT 'La empresa no está ACTIVA.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Oferta o
        INNER JOIN Convenio c
            ON c.id_convenio = o.id_convenio
           AND c.id_empresa = o.id_empresa
        WHERE o.id_oferta = @id_oferta
          AND c.estado = 'VIGENTE'
          AND (c.fecha_fin IS NULL OR c.fecha_fin >= @hoy)
    )
    BEGIN
        PRINT 'La oferta no tiene un convenio vigente.';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Oferta_Carrera WHERE id_oferta = @id_oferta)
    BEGIN
        PRINT 'La oferta no está dirigida a ninguna carrera.';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Oferta_Competencia WHERE id_oferta = @id_oferta)
    BEGIN
        PRINT 'La oferta no tiene competencias.';
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta AND fecha_cierre < @hoy)
    BEGIN
        PRINT 'La fecha de cierre de la oferta ya pasó.';
        RETURN;
    END;

    UPDATE Oferta
    SET estado = 'PUBLICADA',
        fecha_publicacion = @hoy
    WHERE id_oferta = @id_oferta;
END;
GO

CREATE PROCEDURE usp_RegistrarPostulacion
    @id_estudiante INT,
    @id_oferta INT,
    @id_carrera INT,
    @origen VARCHAR(30),
    @observaciones VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_postulacion INT;

    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante)
    BEGIN
        PRINT 'El estudiante no existe.';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Oferta WHERE id_oferta = @id_oferta)
    BEGIN
        PRINT 'La oferta no existe.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Estudiante_Carrera
        WHERE id_estudiante = @id_estudiante
          AND id_carrera = @id_carrera
          AND estado = 'ACTIVO'
    )
    BEGIN
        PRINT 'El estudiante no está ACTIVO en esa carrera.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Oferta
        WHERE id_oferta = @id_oferta
          AND estado = 'PUBLICADA'
          AND fecha_cierre >= CAST(GETDATE() AS date)
    )
    BEGIN
        PRINT 'La oferta no admite postulaciones.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Postulacion
            (id_estudiante, id_oferta, id_carrera, estado, origen, observaciones)
        VALUES
            (@id_estudiante, @id_oferta, @id_carrera, 'RECIBIDA', @origen, @observaciones);

        SET @id_postulacion = SCOPE_IDENTITY();

        INSERT INTO Postulacion_Estado_Historial
            (id_postulacion, estado_anterior, estado_nuevo, motivo)
        VALUES
            (@id_postulacion, NULL, 'RECIBIDA', 'Registro inicial');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE PROCEDURE usp_ModificarPostulacion
    @id_postulacion INT,
    @origen VARCHAR(30),
    @observaciones VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Postulacion WHERE id_postulacion = @id_postulacion)
    BEGIN
        PRINT 'La postulación no existe.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Postulacion
        WHERE id_postulacion = @id_postulacion
          AND estado IN ('RECIBIDA', 'EN_REVISION')
    )
    BEGIN
        PRINT 'La postulación ya no puede modificarse.';
        RETURN;
    END;

    UPDATE Postulacion
    SET origen = @origen,
        observaciones = @observaciones
    WHERE id_postulacion = @id_postulacion;
END;
GO

CREATE PROCEDURE usp_CambiarEstadoPostulacion
    @id_postulacion INT,
    @estado_nuevo VARCHAR(15),
    @motivo VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado_anterior VARCHAR(15);
    DECLARE @id_oferta INT;
    DECLARE @vacantes INT;

    SELECT @estado_anterior = estado, @id_oferta = id_oferta
    FROM Postulacion
    WHERE id_postulacion = @id_postulacion;

    IF @estado_anterior IS NULL
    BEGIN
        PRINT 'La postulación no existe.';
        RETURN;
    END;

    SET @estado_nuevo = ISNULL(@estado_nuevo, '');
    IF NOT (
        (@estado_anterior = 'RECIBIDA' AND @estado_nuevo IN ('EN_REVISION', 'RETIRADA'))
        OR (@estado_anterior = 'EN_REVISION' AND @estado_nuevo IN ('ENTREVISTA', 'RECHAZADA', 'RETIRADA'))
        OR (@estado_anterior = 'ENTREVISTA' AND @estado_nuevo IN ('SELECCIONADA', 'RECHAZADA', 'RETIRADA'))
    )
    BEGIN
        PRINT 'El cambio de estado no está permitido.';
        RETURN;
    END;

    -- Al seleccionar, tiene que quedar alguna vacante libre.
    IF @estado_nuevo = 'SELECCIONADA'
    BEGIN
        SELECT @vacantes = vacantes FROM Oferta WHERE id_oferta = @id_oferta;

        IF (SELECT COUNT(*) FROM Postulacion
            WHERE id_oferta = @id_oferta AND estado = 'SELECCIONADA') >= @vacantes
        BEGIN
            PRINT 'La oferta no tiene vacantes disponibles.';
            RETURN;
        END;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Postulacion
        SET estado = @estado_nuevo
        WHERE id_postulacion = @id_postulacion;

        INSERT INTO Postulacion_Estado_Historial
            (id_postulacion, estado_anterior, estado_nuevo, motivo)
        VALUES
            (@id_postulacion, @estado_anterior, @estado_nuevo, @motivo);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Si la postulación está EN_REVISION, la pasa a ENTREVISTA.
CREATE PROCEDURE usp_RegistrarEntrevista
    @id_postulacion INT,
    @fecha DATETIME,
    @etapa VARCHAR(30),
    @resultado VARCHAR(15),
    @devolucion VARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado VARCHAR(15);

    SELECT @estado = estado
    FROM Postulacion
    WHERE id_postulacion = @id_postulacion;

    IF @estado IS NULL
    BEGIN
        PRINT 'La postulación no existe.';
        RETURN;
    END;
    IF @estado NOT IN ('EN_REVISION', 'ENTREVISTA')
    BEGIN
        PRINT 'La postulación no admite entrevistas.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @estado = 'EN_REVISION'
        BEGIN
            UPDATE Postulacion
            SET estado = 'ENTREVISTA'
            WHERE id_postulacion = @id_postulacion;

            INSERT INTO Postulacion_Estado_Historial
                (id_postulacion, estado_anterior, estado_nuevo, motivo)
            VALUES
                (@id_postulacion, 'EN_REVISION', 'ENTREVISTA', 'Entrevista registrada');
        END;

        INSERT INTO Entrevista (id_postulacion, fecha, etapa, resultado, devolucion)
        VALUES (@id_postulacion, @fecha, @etapa, @resultado, @devolucion);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Resuelve una entrevista PENDIENTE.
CREATE PROCEDURE usp_ActualizarResultadoEntrevista
    @id_entrevista INT,
    @resultado VARCHAR(15),
    @devolucion VARCHAR(400)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Entrevista WHERE id_entrevista = @id_entrevista)
    BEGIN
        PRINT 'La entrevista no existe.';
        RETURN;
    END;
    IF ISNULL(@resultado, '') NOT IN ('APROBADA', 'RECHAZADA')
    BEGIN
        PRINT 'El resultado debe ser APROBADA o RECHAZADA.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Entrevista
        WHERE id_entrevista = @id_entrevista AND resultado = 'PENDIENTE'
    )
    BEGIN
        PRINT 'La entrevista ya tiene resultado.';
        RETURN;
    END;

    UPDATE Entrevista
    SET resultado = @resultado,
        devolucion = ISNULL(@devolucion, devolucion)
    WHERE id_entrevista = @id_entrevista;
END;
GO

CREATE PROCEDURE usp_CrearPractica
    @id_postulacion INT,
    @fecha_inicio DATE,
    @fecha_fin_prevista DATE,
    @horas_semanales INT,
    @modalidad VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado VARCHAR(15);
    DECLARE @id_estudiante INT;
    DECLARE @id_carrera INT;
    DECLARE @id_practica INT;

    SELECT @estado = estado, @id_estudiante = id_estudiante, @id_carrera = id_carrera
    FROM Postulacion
    WHERE id_postulacion = @id_postulacion;

    IF @estado IS NULL
    BEGIN
        PRINT 'La postulación no existe.';
        RETURN;
    END;
    IF @estado <> 'SELECCIONADA'
    BEGIN
        PRINT 'La postulación no está SELECCIONADA.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Estudiante_Carrera
        WHERE id_estudiante = @id_estudiante
          AND id_carrera = @id_carrera
          AND estado = 'ACTIVO'
    )
    BEGIN
        PRINT 'El estudiante no está ACTIVO en la carrera de la postulación.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1
        FROM Postulacion p
        INNER JOIN Oferta o ON o.id_oferta = p.id_oferta
        INNER JOIN Convenio c
            ON c.id_convenio = o.id_convenio
           AND c.id_empresa = o.id_empresa
        WHERE p.id_postulacion = @id_postulacion
          AND c.estado = 'VIGENTE'
          -- La práctica completa tiene que quedar dentro del convenio.
          AND c.fecha_inicio <= @fecha_inicio
          AND (c.fecha_fin IS NULL OR c.fecha_fin >= @fecha_fin_prevista)
    )
    BEGIN
        PRINT 'La oferta no tiene un convenio vigente que cubra las fechas de la práctica.';
        RETURN;
    END;
    -- Sin prácticas simultáneas del mismo estudiante.
    IF EXISTS (
        SELECT 1
        FROM Practica pr
        INNER JOIN Postulacion po ON po.id_postulacion = pr.id_postulacion
        WHERE po.id_estudiante = @id_estudiante
          AND pr.estado IN ('PLANIFICADA', 'EN_CURSO')
    )
    BEGIN
        PRINT 'El estudiante ya tiene una práctica planificada o en curso.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Practica
            (id_postulacion, fecha_inicio, fecha_fin_prevista,
             horas_semanales, modalidad, estado)
        VALUES
            (@id_postulacion, @fecha_inicio, @fecha_fin_prevista,
             @horas_semanales, @modalidad, 'PLANIFICADA');

        SET @id_practica = SCOPE_IDENTITY();

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, NULL, 'PLANIFICADA', 'Práctica creada');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE PROCEDURE usp_IniciarPractica
    @id_practica INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado VARCHAR(15);
    DECLARE @fecha_inicio DATE;

    SELECT @estado = estado, @fecha_inicio = fecha_inicio
    FROM Practica
    WHERE id_practica = @id_practica;

    IF @estado IS NULL
    BEGIN
        PRINT 'La práctica no existe.';
        RETURN;
    END;
    IF @estado <> 'PLANIFICADA'
    BEGIN
        PRINT 'Solo se inicia una práctica PLANIFICADA.';
        RETURN;
    END;
    IF @fecha_inicio > CAST(GETDATE() AS date)
    BEGIN
        PRINT 'La práctica todavía no llegó a su fecha de inicio.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Practica
        SET estado = 'EN_CURSO'
        WHERE id_practica = @id_practica;

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, 'PLANIFICADA', 'EN_CURSO', 'Inicio de la práctica');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE PROCEDURE usp_RegistrarSeguimiento
    @id_practica INT,
    @tipo_seguimiento VARCHAR(15),
    @origen_feedback VARCHAR(15),
    @estado_seguimiento VARCHAR(25),
    @observaciones VARCHAR(500),
    @intervencion_facultad VARCHAR(500),
    @proxima_revision DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Practica WHERE id_practica = @id_practica)
    BEGIN
        PRINT 'La práctica no existe.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Practica
        WHERE id_practica = @id_practica AND estado = 'EN_CURSO'
    )
    BEGIN
        PRINT 'Solo se registran seguimientos de prácticas EN_CURSO.';
        RETURN;
    END;

    INSERT INTO Seguimiento
        (id_practica, tipo_seguimiento, origen_feedback,
         estado_seguimiento, observaciones,
         intervencion_facultad, proxima_revision)
    VALUES
        (@id_practica, @tipo_seguimiento, @origen_feedback,
         @estado_seguimiento, @observaciones,
         @intervencion_facultad, @proxima_revision);
END;
GO

CREATE PROCEDURE usp_RegistrarEvaluacion
    @id_practica INT,
    @tipo_evaluador VARCHAR(15),
    @instancia VARCHAR(7),
    @puntaje_desempeno DECIMAL(3,1),
    @puntaje_satisfaccion DECIMAL(3,1),
    @resultado VARCHAR(20),
    @comentarios VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Practica WHERE id_practica = @id_practica)
    BEGIN
        PRINT 'La práctica no existe.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Practica
        WHERE id_practica = @id_practica AND estado = 'EN_CURSO'
    )
    BEGIN
        PRINT 'Solo se evalúan prácticas EN_CURSO.';
        RETURN;
    END;

    INSERT INTO Evaluacion
        (id_practica, tipo_evaluador, instancia, puntaje_desempeno,
         puntaje_satisfaccion, resultado, comentarios)
    VALUES
        (@id_practica, @tipo_evaluador, @instancia, @puntaje_desempeno,
         @puntaje_satisfaccion, @resultado, @comentarios);
END;
GO

CREATE PROCEDURE usp_CerrarPractica
    @id_practica INT,
    @fecha_fin_real DATE,
    @motivo_cierre VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado VARCHAR(15);

    SELECT @estado = estado
    FROM Practica
    WHERE id_practica = @id_practica;

    IF @estado IS NULL
    BEGIN
        PRINT 'La práctica no existe.';
        RETURN;
    END;
    IF @estado <> 'EN_CURSO'
    BEGIN
        PRINT 'Solo se cierra una práctica EN_CURSO.';
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM Seguimiento WHERE id_practica = @id_practica)
    BEGIN
        PRINT 'La práctica no tiene seguimientos.';
        RETURN;
    END;
    IF NOT EXISTS (
        SELECT 1 FROM Evaluacion
        WHERE id_practica = @id_practica
          AND tipo_evaluador = 'ESTUDIANTE'
          AND instancia = 'FINAL'
    )
    OR NOT EXISTS (
        SELECT 1 FROM Evaluacion
        WHERE id_practica = @id_practica
          AND tipo_evaluador = 'EMPRESA'
          AND instancia = 'FINAL'
    )
    BEGIN
        PRINT 'Faltan las evaluaciones FINAL del estudiante y de la empresa.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Practica
        SET estado = 'FINALIZADA',
            fecha_fin_real = @fecha_fin_real,
            motivo_cierre = @motivo_cierre
        WHERE id_practica = @id_practica;

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, 'EN_CURSO', 'FINALIZADA', @motivo_cierre);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE PROCEDURE usp_InterrumpirPractica
    @id_practica INT,
    @fecha_fin_real DATE,
    @motivo_cierre VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @estado VARCHAR(15);

    SELECT @estado = estado
    FROM Practica
    WHERE id_practica = @id_practica;

    IF @estado IS NULL
    BEGIN
        PRINT 'La práctica no existe.';
        RETURN;
    END;
    IF @estado NOT IN ('PLANIFICADA', 'EN_CURSO')
    BEGIN
        PRINT 'Solo se interrumpe una práctica PLANIFICADA o EN_CURSO.';
        RETURN;
    END;
    IF @motivo_cierre IS NULL
    BEGIN
        PRINT 'El motivo es obligatorio.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Practica
        SET estado = 'INTERRUMPIDA',
            fecha_fin_real = @fecha_fin_real,
            motivo_cierre = @motivo_cierre
        WHERE id_practica = @id_practica;

        INSERT INTO Historial_Practica (id_practica, estado_anterior, estado_nuevo, motivo)
        VALUES (@id_practica, @estado, 'INTERRUMPIDA', @motivo_cierre);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
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
    BEGIN
        PRINT 'El estudiante no existe.';
        RETURN;
    END;

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
    WHERE o.estado = 'PUBLICADA'
      AND o.fecha_cierre >= CAST(GETDATE() AS date)
      AND EXISTS (
          SELECT 1
          FROM Oferta_Carrera ofc
          INNER JOIN Estudiante_Carrera esc
              ON esc.id_carrera = ofc.id_carrera
          WHERE ofc.id_oferta = o.id_oferta
            AND esc.id_estudiante = @id_estudiante
            AND esc.estado = 'ACTIVO'
      )
    GROUP BY o.id_oferta, o.titulo, em.razon_social;
END;
GO

/* ================================================================
   5. TRIGGERS DE AUDITORÍA
   Auditan Seguimiento y Evaluacion: ningún procedimiento modifica esas
   filas, así que cualquier UPDATE es una corrección manual que conviene
   registrar con su usuario. Postulacion y Practica no necesitan trigger:
   sus cambios de estado quedan en sus tablas de historial.
   Solo auditan si el valor cambió; el usuario lo completa el DEFAULT
   ORIGINAL_LOGIN().
   ================================================================ */

CREATE TRIGGER tr_Seguimiento_Auditoria
ON Seguimiento
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Auditoria_Cambios
        (tabla, id_registro, valor_anterior, valor_nuevo)
    SELECT
        'Seguimiento', i.id_seguimiento,
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
        (tabla, id_registro, valor_anterior, valor_nuevo)
    SELECT
        'Evaluacion', i.id_evaluacion, d.resultado, i.resultado
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
