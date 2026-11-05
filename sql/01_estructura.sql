/* ================================================================
   1. TABLAS
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

CREATE TABLE Estudiante (
    id_estudiante INT IDENTITY(1,1) NOT NULL,
    id_carrera INT NOT NULL,
    legajo VARCHAR(20) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    anio_ingreso INT NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',

    CONSTRAINT PK_Estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT UQ_Estudiante_Legajo UNIQUE (legajo),
    CONSTRAINT UQ_Estudiante_Email UNIQUE (email),
    CONSTRAINT CK_Estudiante_Anio CHECK (anio_ingreso BETWEEN 1900 AND 2100),
    CONSTRAINT CK_Estudiante_Estado
        CHECK (estado IN ('ACTIVO', 'EGRESADO', 'INACTIVO')),
    CONSTRAINT FK_Estudiante_Carrera FOREIGN KEY (id_carrera)
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

CREATE TABLE Estudiante_Competencia (
    id_estudiante INT NOT NULL,
    id_competencia INT NOT NULL,
    nivel_declarado INT NOT NULL,
    fecha_actualizacion DATETIME2 NOT NULL DEFAULT GETDATE(),

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
    activo BIT NOT NULL DEFAULT 1,

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
    cupos_referenciales INT NULL,

    CONSTRAINT PK_Convenio PRIMARY KEY (id_convenio),
    CONSTRAINT CK_Convenio_Fechas
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT CK_Convenio_Estado
        CHECK (estado IN ('VIGENTE', 'VENCIDO', 'SUSPENDIDO')),
    CONSTRAINT CK_Convenio_Cupos
        CHECK (cupos_referenciales IS NULL OR cupos_referenciales >= 0),
    CONSTRAINT UQ_Convenio_Id_Empresa
        UNIQUE (id_convenio, id_empresa),
    CONSTRAINT FK_Convenio_Empresa FOREIGN KEY (id_empresa)
        REFERENCES Empresa (id_empresa)
);
GO

CREATE TABLE Oferta (
    id_oferta INT IDENTITY(1,1) NOT NULL,
    id_empresa INT NOT NULL,
    id_convenio INT NULL,
    titulo VARCHAR(120) NOT NULL,
    descripcion VARCHAR(800) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    fecha_cierre DATE NOT NULL,
    vacantes INT NOT NULL,
    modalidad VARCHAR(15) NOT NULL,
    jornada VARCHAR(40) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'BORRADOR',

    CONSTRAINT PK_Oferta PRIMARY KEY (id_oferta),
    CONSTRAINT CK_Oferta_Fechas CHECK (fecha_cierre >= fecha_publicacion),
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

CREATE TABLE Oferta_Carrera (
    id_oferta INT NOT NULL,
    id_carrera INT NOT NULL,

    CONSTRAINT PK_Oferta_Carrera
        PRIMARY KEY (id_oferta, id_carrera),
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

CREATE TABLE Postulacion (
    id_postulacion INT IDENTITY(1,1) NOT NULL,
    id_estudiante INT NOT NULL,
    id_oferta INT NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
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
    CONSTRAINT FK_Postulacion_Estudiante FOREIGN KEY (id_estudiante)
        REFERENCES Estudiante (id_estudiante),
    CONSTRAINT FK_Postulacion_Oferta FOREIGN KEY (id_oferta)
        REFERENCES Oferta (id_oferta)
);
GO

CREATE TABLE Postulacion_Estado_Historial (
    id_historial INT IDENTITY(1,1) NOT NULL,
    id_postulacion INT NOT NULL,
    estado_anterior VARCHAR(15) NULL,
    estado_nuevo VARCHAR(15) NOT NULL,
    fecha_cambio DATETIME2 NOT NULL DEFAULT GETDATE(),
    motivo VARCHAR(500) NULL,

    CONSTRAINT PK_Postulacion_Estado_Historial PRIMARY KEY (id_historial),
    CONSTRAINT FK_Historial_Postulacion FOREIGN KEY (id_postulacion)
        REFERENCES Postulacion (id_postulacion)
);
GO

CREATE TABLE Entrevista (
    id_entrevista INT IDENTITY(1,1) NOT NULL,
    id_postulacion INT NOT NULL,
    fecha DATETIME2 NOT NULL,
    etapa VARCHAR(30) NOT NULL,
    resultado VARCHAR(15) NOT NULL DEFAULT 'PENDIENTE',
    devolucion VARCHAR(400) NULL,

    CONSTRAINT PK_Entrevista PRIMARY KEY (id_entrevista),
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
    CONSTRAINT FK_Practica_Postulacion FOREIGN KEY (id_postulacion)
        REFERENCES Postulacion (id_postulacion)
);
GO

CREATE TABLE Seguimiento (
    id_seguimiento INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
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

CREATE TABLE Evaluacion (
    id_evaluacion INT IDENTITY(1,1) NOT NULL,
    id_practica INT NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    tipo_evaluador VARCHAR(15) NOT NULL,
    puntaje_desempeno DECIMAL(3,1) NULL,
    puntaje_satisfaccion DECIMAL(3,1) NULL,
    resultado VARCHAR(20) NOT NULL,
    comentarios VARCHAR(500) NULL,

    CONSTRAINT PK_Evaluacion PRIMARY KEY (id_evaluacion),
    CONSTRAINT UQ_Evaluacion_Practica_Tipo UNIQUE (id_practica, tipo_evaluador),
    CONSTRAINT CK_Evaluacion_Tipo
        CHECK (tipo_evaluador IN ('ESTUDIANTE', 'EMPRESA', 'UNIVERSIDAD')),
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
    operacion VARCHAR(10) NOT NULL,
    fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    valor_anterior VARCHAR(100) NULL,
    valor_nuevo VARCHAR(100) NULL,

    CONSTRAINT PK_Auditoria_Cambios PRIMARY KEY (id_auditoria),
    CONSTRAINT CK_Auditoria_Operacion CHECK (operacion = 'UPDATE')
);
GO

/* ================================================================
   2. VISTAS
   ================================================================ */

CREATE VIEW vw_AvanceAcademico
AS
SELECT
    e.id_estudiante,
    e.legajo,
    e.nombre,
    e.apellido,
    c.nombre AS carrera,
    c.plan_estudios,
    COUNT(em.id_materia) AS materias_aprobadas,
    COUNT(m.id_materia) AS total_materias,
    CASE
        WHEN COUNT(m.id_materia) = 0 THEN 0
        ELSE COUNT(em.id_materia) * 100.0 / COUNT(m.id_materia)
    END AS porcentaje_avance
FROM Estudiante e
INNER JOIN Carrera c ON c.id_carrera = e.id_carrera
LEFT JOIN Materia m ON m.id_carrera = e.id_carrera AND m.activo = 1
LEFT JOIN Estudiante_Materia em
    ON em.id_estudiante = e.id_estudiante
   AND em.id_materia = m.id_materia
GROUP BY
    e.id_estudiante, e.legajo, e.nombre, e.apellido,
    c.nombre, c.plan_estudios;
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
    o.titulo AS oferta,
    em.razon_social AS empresa
FROM Practica p
INNER JOIN Postulacion po ON po.id_postulacion = p.id_postulacion
INNER JOIN Estudiante e ON e.id_estudiante = po.id_estudiante
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
INNER JOIN Seguimiento s ON s.id_practica = p.id_practica
WHERE p.estado = 'EN_CURSO'
  AND s.estado_seguimiento IN ('EN_OBSERVACION', 'REQUIERE_INTERVENCION');
GO

CREATE VIEW vw_EmbudoPostulaciones
AS
SELECT
    o.id_oferta,
    o.titulo,
    p.estado,
    COUNT(*) AS cantidad_postulaciones
FROM Oferta o
INNER JOIN Postulacion p ON p.id_oferta = o.id_oferta
GROUP BY o.id_oferta, o.titulo, p.estado;
GO

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
LEFT JOIN Evaluacion ev ON ev.id_practica = p.id_practica
GROUP BY em.id_empresa, em.razon_social;
GO

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
LEFT JOIN Estudiante e ON e.id_carrera = c.id_carrera
LEFT JOIN Postulacion po ON po.id_estudiante = e.id_estudiante
LEFT JOIN Practica p ON p.id_postulacion = po.id_postulacion
LEFT JOIN Evaluacion ev ON ev.id_practica = p.id_practica
GROUP BY c.id_carrera, c.nombre, c.plan_estudios;
GO

CREATE VIEW vw_BrechaCompetencias
AS
SELECT
    c.id_competencia,
    c.nombre AS competencia,
    COUNT(DISTINCT oc.id_oferta) AS ofertas_que_la_solicitan,
    COUNT(DISTINCT ec.id_estudiante) AS estudiantes_que_la_declaran
FROM Competencia c
LEFT JOIN Oferta_Competencia oc ON oc.id_competencia = c.id_competencia
LEFT JOIN Estudiante_Competencia ec ON ec.id_competencia = c.id_competencia
GROUP BY c.id_competencia, c.nombre;
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
    o.fecha_cierre
FROM Carrera c
INNER JOIN Oferta_Carrera oc ON oc.id_carrera = c.id_carrera
INNER JOIN Oferta o ON o.id_oferta = oc.id_oferta
INNER JOIN Empresa em ON em.id_empresa = o.id_empresa;
GO

/* ================================================================
   3. FUNCION
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
   4. PROCEDIMIENTOS BASICOS
   ================================================================ */

CREATE PROCEDURE usp_RegistrarMateriaAprobada
    @id_estudiante INT,
    @id_materia INT,
    @fecha_aprobacion DATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Estudiante e
        INNER JOIN Materia m ON m.id_carrera = e.id_carrera
        WHERE e.id_estudiante = @id_estudiante
          AND m.id_materia = @id_materia
    )
    BEGIN
        INSERT INTO Estudiante_Materia
            (id_estudiante, id_materia, fecha_aprobacion)
        VALUES
            (@id_estudiante, @id_materia, @fecha_aprobacion);
    END
    ELSE
        PRINT 'La materia no pertenece al plan del estudiante.';
END;
GO

CREATE PROCEDURE usp_PublicarOferta
    @id_oferta INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Oferta o
        INNER JOIN Empresa e ON e.id_empresa = o.id_empresa
        WHERE o.id_oferta = @id_oferta
          AND o.estado = 'BORRADOR'
          AND e.activo = 1
          AND e.estado_vinculo = 'ACTIVA'
    )
    AND EXISTS (
        SELECT 1
        FROM Oferta_Competencia
        WHERE id_oferta = @id_oferta
    )
    BEGIN
        UPDATE Oferta
        SET estado = 'PUBLICADA',
            fecha_publicacion = GETDATE()
        WHERE id_oferta = @id_oferta;
    END
    ELSE
        PRINT 'La oferta no puede publicarse.';
END;
GO

CREATE PROCEDURE usp_RegistrarPostulacion
    @id_estudiante INT,
    @id_oferta INT,
    @origen VARCHAR(30),
    @observaciones VARCHAR(500)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Estudiante
        WHERE id_estudiante = @id_estudiante AND estado = 'ACTIVO'
    )
    AND EXISTS (
        SELECT 1 FROM Oferta
        WHERE id_oferta = @id_oferta
          AND estado = 'PUBLICADA'
          AND fecha_cierre >= GETDATE()
    )
    AND NOT EXISTS (
        SELECT 1 FROM Postulacion
        WHERE id_estudiante = @id_estudiante
          AND id_oferta = @id_oferta
    )
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO Postulacion
                (id_estudiante, id_oferta, estado, origen, observaciones)
            VALUES
                (@id_estudiante, @id_oferta, 'RECIBIDA', @origen, @observaciones);

            INSERT INTO Postulacion_Estado_Historial
                (id_postulacion, estado_anterior, estado_nuevo, motivo)
            SELECT
                id_postulacion, NULL, 'RECIBIDA', 'Registro inicial'
            FROM Postulacion
            WHERE id_estudiante = @id_estudiante
              AND id_oferta = @id_oferta;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            PRINT 'Ocurrio un error al registrar la postulacion.';
        END CATCH;
    END
    ELSE
        PRINT 'No se pudo registrar la postulacion.';
END;
GO

CREATE PROCEDURE usp_ModificarPostulacion
    @id_postulacion INT,
    @origen VARCHAR(30),
    @observaciones VARCHAR(500)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Postulacion
        WHERE id_postulacion = @id_postulacion
          AND estado IN ('RECIBIDA', 'EN_REVISION')
    )
    BEGIN
        UPDATE Postulacion
        SET origen = @origen,
            observaciones = @observaciones
        WHERE id_postulacion = @id_postulacion;
    END
    ELSE
        PRINT 'La postulacion ya no puede modificarse.';
END;
GO

CREATE PROCEDURE usp_CambiarEstadoPostulacion
    @id_postulacion INT,
    @estado_nuevo VARCHAR(15),
    @motivo VARCHAR(500)
AS
BEGIN
    DECLARE @estado_anterior VARCHAR(15);

    SELECT @estado_anterior = estado
    FROM Postulacion
    WHERE id_postulacion = @id_postulacion;

    IF (
        (@estado_anterior = 'RECIBIDA' AND @estado_nuevo IN ('EN_REVISION', 'RETIRADA'))
        OR (@estado_anterior = 'EN_REVISION' AND @estado_nuevo IN ('ENTREVISTA', 'RECHAZADA', 'RETIRADA'))
        OR (@estado_anterior = 'ENTREVISTA' AND @estado_nuevo IN ('SELECCIONADA', 'RECHAZADA', 'RETIRADA'))
    )
    BEGIN
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
            PRINT 'Ocurrio un error al cambiar el estado de la postulacion.';
        END CATCH;
    END
    ELSE
        PRINT 'El cambio de estado no esta permitido.';
END;
GO

CREATE PROCEDURE usp_RegistrarEntrevista
    @id_postulacion INT,
    @fecha DATETIME2,
    @etapa VARCHAR(30),
    @resultado VARCHAR(15),
    @devolucion VARCHAR(400)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Postulacion
        WHERE id_postulacion = @id_postulacion
          AND estado IN ('EN_REVISION', 'ENTREVISTA')
    )
    BEGIN
        INSERT INTO Entrevista
            (id_postulacion, fecha, etapa, resultado, devolucion)
        VALUES
            (@id_postulacion, @fecha, @etapa, @resultado, @devolucion);
    END
    ELSE
        PRINT 'La postulacion no admite entrevistas.';
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
    IF EXISTS (
        SELECT 1
        FROM Postulacion p
        INNER JOIN Oferta o ON o.id_oferta = p.id_oferta
        INNER JOIN Convenio c
            ON c.id_convenio = o.id_convenio
           AND c.id_empresa = o.id_empresa
        WHERE p.id_postulacion = @id_postulacion
          AND p.estado = 'SELECCIONADA'
          AND c.estado = 'VIGENTE'
          AND c.fecha_inicio <= @fecha_inicio
          AND (c.fecha_fin IS NULL OR c.fecha_fin >= @fecha_inicio)
    )
    BEGIN
        INSERT INTO Practica
            (id_postulacion, fecha_inicio, fecha_fin_prevista,
             horas_semanales, modalidad, estado)
        VALUES
            (@id_postulacion, @fecha_inicio, @fecha_fin_prevista,
             @horas_semanales, @modalidad, 'PLANIFICADA');
    END
    ELSE
        PRINT 'La practica necesita una postulacion seleccionada y un convenio vigente.';
END;
GO

CREATE PROCEDURE usp_IniciarPractica
    @id_practica INT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Practica
        WHERE id_practica = @id_practica
          AND estado = 'PLANIFICADA'
          AND fecha_inicio <= GETDATE()
    )
    BEGIN
        UPDATE Practica
        SET estado = 'EN_CURSO'
        WHERE id_practica = @id_practica;
    END
    ELSE
        PRINT 'La practica no puede iniciarse.';
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
    IF EXISTS (
        SELECT 1 FROM Practica
        WHERE id_practica = @id_practica
          AND estado = 'EN_CURSO'
    )
    BEGIN
        INSERT INTO Seguimiento
            (id_practica, tipo_seguimiento, origen_feedback,
             estado_seguimiento, observaciones,
             intervencion_facultad, proxima_revision)
        VALUES
            (@id_practica, @tipo_seguimiento, @origen_feedback,
             @estado_seguimiento, @observaciones,
             @intervencion_facultad, @proxima_revision);
    END
    ELSE
        PRINT 'Solo se siguen practicas en curso.';
END;
GO

CREATE PROCEDURE usp_RegistrarEvaluacion
    @id_practica INT,
    @tipo_evaluador VARCHAR(15),
    @puntaje_desempeno DECIMAL(3,1),
    @puntaje_satisfaccion DECIMAL(3,1),
    @resultado VARCHAR(20),
    @comentarios VARCHAR(500)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Practica
        WHERE id_practica = @id_practica
          AND estado = 'EN_CURSO'
    )
    BEGIN
        INSERT INTO Evaluacion
            (id_practica, tipo_evaluador, puntaje_desempeno,
             puntaje_satisfaccion, resultado, comentarios)
        VALUES
            (@id_practica, @tipo_evaluador, @puntaje_desempeno,
             @puntaje_satisfaccion, @resultado, @comentarios);
    END
    ELSE
        PRINT 'La practica no admite evaluaciones.';
END;
GO

CREATE PROCEDURE usp_CerrarPractica
    @id_practica INT,
    @fecha_fin_real DATE,
    @motivo_cierre VARCHAR(250)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Practica
        WHERE id_practica = @id_practica AND estado = 'EN_CURSO'
    )
    AND EXISTS (
        SELECT 1 FROM Seguimiento WHERE id_practica = @id_practica
    )
    AND EXISTS (
        SELECT 1 FROM Evaluacion
        WHERE id_practica = @id_practica AND tipo_evaluador = 'ESTUDIANTE'
    )
    AND EXISTS (
        SELECT 1 FROM Evaluacion
        WHERE id_practica = @id_practica AND tipo_evaluador = 'EMPRESA'
    )
    BEGIN
        UPDATE Practica
        SET estado = 'FINALIZADA',
            fecha_fin_real = @fecha_fin_real,
            motivo_cierre = @motivo_cierre
        WHERE id_practica = @id_practica;
    END
    ELSE
        PRINT 'Faltan seguimientos o evaluaciones para cerrar la practica.';
END;
GO

CREATE PROCEDURE usp_InterrumpirPractica
    @id_practica INT,
    @fecha_fin_real DATE,
    @motivo_cierre VARCHAR(250)
AS
BEGIN
    IF @motivo_cierre IS NOT NULL
    AND EXISTS (
        SELECT 1
        FROM Practica
        WHERE id_practica = @id_practica
          AND estado IN ('PLANIFICADA', 'EN_CURSO')
          AND @fecha_fin_real >= fecha_inicio
    )
    BEGIN
        UPDATE Practica
        SET estado = 'INTERRUMPIDA',
            fecha_fin_real = @fecha_fin_real,
            motivo_cierre = @motivo_cierre
        WHERE id_practica = @id_practica;
    END
    ELSE
        PRINT 'La practica no puede interrumpirse o falta indicar el motivo.';
END;
GO

CREATE PROCEDURE usp_VerCompatibilidad
    @id_estudiante INT
AS
BEGIN
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
      AND o.fecha_cierre >= GETDATE()
    GROUP BY o.id_oferta, o.titulo, em.razon_social;
END;
GO

/* ================================================================
   5. TRIGGERS SIMPLES DE AUDITORIA
   Solo registran modificaciones.
   ================================================================ */

CREATE TRIGGER tr_Postulacion_Auditoria
ON Postulacion
AFTER UPDATE
AS
BEGIN
    INSERT INTO Auditoria_Cambios
        (tabla, id_registro, operacion, valor_anterior, valor_nuevo)
    SELECT
        'Postulacion', i.id_postulacion, 'UPDATE', d.estado, i.estado
    FROM inserted i
    INNER JOIN deleted d ON d.id_postulacion = i.id_postulacion;
END;
GO

CREATE TRIGGER tr_Practica_Auditoria
ON Practica
AFTER UPDATE
AS
BEGIN
    INSERT INTO Auditoria_Cambios
        (tabla, id_registro, operacion, valor_anterior, valor_nuevo)
    SELECT
        'Practica', i.id_practica, 'UPDATE', d.estado, i.estado
    FROM inserted i
    INNER JOIN deleted d ON d.id_practica = i.id_practica;
END;
GO

CREATE TRIGGER tr_Seguimiento_Auditoria
ON Seguimiento
AFTER UPDATE
AS
BEGIN
    INSERT INTO Auditoria_Cambios
        (tabla, id_registro, operacion, valor_anterior, valor_nuevo)
    SELECT
        'Seguimiento', i.id_seguimiento, 'UPDATE',
        d.estado_seguimiento, i.estado_seguimiento
    FROM inserted i
    INNER JOIN deleted d ON d.id_seguimiento = i.id_seguimiento;
END;
GO

CREATE TRIGGER tr_Evaluacion_Auditoria
ON Evaluacion
AFTER UPDATE
AS
BEGIN
    INSERT INTO Auditoria_Cambios
        (tabla, id_registro, operacion, valor_anterior, valor_nuevo)
    SELECT
        'Evaluacion', i.id_evaluacion, 'UPDATE', d.resultado, i.resultado
    FROM inserted i
    INNER JOIN deleted d ON d.id_evaluacion = i.id_evaluacion;
END;
GO

/* ================================================================
   6. INDICES BASICOS
   ================================================================ */

CREATE INDEX IX_Materia_Carrera ON Materia (id_carrera);
CREATE INDEX IX_Estudiante_Carrera ON Estudiante (id_carrera);
CREATE INDEX IX_Oferta_Estado ON Oferta (estado, fecha_cierre);
CREATE INDEX IX_OfertaCarrera_Carrera ON Oferta_Carrera (id_carrera);
CREATE INDEX IX_Postulacion_Oferta ON Postulacion (id_oferta, estado);
CREATE INDEX IX_Practica_Estado ON Practica (estado);
CREATE INDEX IX_Seguimiento_Practica ON Seguimiento (id_practica, fecha);
GO
