USE NexoAcademico;
GO

/* ================================================================
   CONSULTAS DE NEGOCIO
   Consultas 1 a 14: preguntas originales del TP.
   Consultas 15 a 19: preguntas nuevas (ranking, vacantes, pertinencia,
   tiempos entre etapas). Consulta 20: revisiones vencidas.
   ================================================================ */

-- 1. Cuantos estudiantes hay por carrera? (un estudiante puede estar en
--    varias carreras; incluye carreras sin estudiantes)
SELECT
    c.nombre AS carrera,
    c.plan_estudios,
    COUNT(ec.id_estudiante) AS cantidad_estudiantes,
    COUNT(CASE WHEN ec.estado = N'ACTIVO' THEN 1 END) AS estudiantes_activos
FROM Carrera c
LEFT JOIN Estudiante_Carrera ec ON ec.id_carrera = c.id_carrera
GROUP BY c.nombre, c.plan_estudios
ORDER BY cantidad_estudiantes DESC;

-- 2. Cuantas oportunidades vigentes (ofertas PUBLICADA) tiene cada carrera,
--    y cuantas son de pertinencia ALTA? (no cuenta CERRADA ni CANCELADA)
SELECT
    c.nombre AS carrera,
    c.plan_estudios,
    COUNT(o.id_oferta) AS cantidad_ofertas,
    COUNT(CASE WHEN o.id_oferta IS NOT NULL AND oc.pertinencia = N'ALTA' THEN 1 END) AS ofertas_pertinencia_alta
FROM Carrera c
LEFT JOIN Oferta_Carrera oc ON oc.id_carrera = c.id_carrera
LEFT JOIN Oferta o ON o.id_oferta = oc.id_oferta AND o.estado = N'PUBLICADA'
GROUP BY c.nombre, c.plan_estudios
ORDER BY cantidad_ofertas DESC;

-- 3. Que competencias son las mas solicitadas por las ofertas?
SELECT
    c.nombre AS competencia,
    COUNT(oc.id_oferta) AS cantidad_ofertas
FROM Competencia c
LEFT JOIN Oferta_Competencia oc
    ON oc.id_competencia = c.id_competencia
GROUP BY c.nombre
ORDER BY cantidad_ofertas DESC;

-- 4. Que competencias declara cada estudiante y con que nivel?
SELECT
    e.legajo,
    e.nombre,
    e.apellido,
    c.nombre AS competencia,
    ec.nivel_declarado,
    CASE
        WHEN ec.nivel_declarado = 1 THEN N'BASICO'
        WHEN ec.nivel_declarado = 2 THEN N'INTERMEDIO'
        WHEN ec.nivel_declarado = 3 THEN N'AVANZADO'
    END AS nivel
FROM Estudiante e
INNER JOIN Estudiante_Competencia ec
    ON ec.id_estudiante = e.id_estudiante
INNER JOIN Competencia c
    ON c.id_competencia = ec.id_competencia
ORDER BY e.apellido, e.nombre, c.nombre;

-- 5. Embudo: cuantas postulaciones hay por oferta y estado actual?
SELECT *
FROM vw_EmbudoPostulaciones
ORDER BY titulo, estado;

-- 6. Que postulaciones todavia no tienen ninguna entrevista?
SELECT
    p.id_postulacion,
    e.legajo,
    e.nombre,
    e.apellido,
    o.titulo,
    p.estado
FROM Postulacion p
INNER JOIN Estudiante e ON e.id_estudiante = p.id_estudiante
INNER JOIN Oferta o ON o.id_oferta = p.id_oferta
WHERE NOT EXISTS (
    SELECT 1
    FROM Entrevista en
    WHERE en.id_postulacion = p.id_postulacion
);

-- 7. Que practicas estan activas (PLANIFICADA o EN_CURSO)?
SELECT *
FROM vw_PracticasActivas
ORDER BY fecha_inicio;

-- 8. Que practicas requieren intervencion de la facultad (segun su ultimo
--    seguimiento)?
SELECT *
FROM vw_PracticasQueRequierenIntervencion
ORDER BY proxima_revision;

-- 9. Que resultados tiene cada empresa (practicas y promedios)?
SELECT *
FROM vw_ResultadosEmpresa
ORDER BY promedio_satisfaccion DESC;

-- 10. Que resultados tiene cada carrera (practicas y promedios)?
SELECT *
FROM vw_ResultadosCarrera
ORDER BY promedio_satisfaccion DESC;

-- 11. Cual es el avance academico de cada estudiante en cada carrera?
SELECT *
FROM vw_AvanceAcademico
ORDER BY porcentaje_avance DESC;

-- 12. Cual es la brecha de competencias (ofertas que la piden frente a
--     estudiantes que la declaran)?
SELECT *
FROM vw_BrechaCompetencias
ORDER BY ofertas_que_la_solicitan DESC;

-- 13. Cuales son los motivos de rechazo o retiro de postulaciones y quien
--     registro el cambio?
SELECT
    p.id_postulacion,
    e.legajo,
    o.titulo,
    h.estado_nuevo,
    h.motivo,
    h.usuario
FROM Postulacion_Estado_Historial h
INNER JOIN Postulacion p ON p.id_postulacion = h.id_postulacion
INNER JOIN Estudiante e ON e.id_estudiante = p.id_estudiante
INNER JOIN Oferta o ON o.id_oferta = p.id_oferta
WHERE h.estado_nuevo IN (N'RECHAZADA', N'RETIRADA')
ORDER BY p.id_postulacion;

-- 14. Que empresas no tienen convenio vigente a hoy? (se compara contra
--     la fecha sin hora: un convenio que vence hoy sigue vigente)
SELECT
    e.id_empresa,
    e.razon_social,
    e.sector
FROM Empresa e
WHERE NOT EXISTS (
    SELECT 1
    FROM Convenio c
    WHERE c.id_empresa = e.id_empresa
      AND c.estado = N'VIGENTE'
      AND c.fecha_inicio <= CAST(GETDATE() AS date)
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= CAST(GETDATE() AS date))
);

/* ----------------------------------------------------------------
   CONSULTAS NUEVAS
   ---------------------------------------------------------------- */

-- 15. Que carrera logra mayor satisfaccion en sus practicas? Ranking de
--     carreras por satisfaccion promedio (RANK: empates comparten puesto).
SELECT
    RANK() OVER (ORDER BY AVG(ev.puntaje_satisfaccion) DESC) AS puesto,
    c.nombre AS carrera,
    COUNT(DISTINCT pr.id_practica) AS practicas_evaluadas,
    CAST(AVG(ev.puntaje_satisfaccion) AS DECIMAL(3,2)) AS promedio_satisfaccion,
    CAST(AVG(ev.puntaje_desempeno) AS DECIMAL(3,2)) AS promedio_desempeno
FROM Carrera c
INNER JOIN Postulacion po ON po.id_carrera = c.id_carrera
INNER JOIN Practica pr ON pr.id_postulacion = po.id_postulacion
INNER JOIN Evaluacion ev ON ev.id_practica = pr.id_practica
GROUP BY c.id_carrera, c.nombre
ORDER BY puesto, carrera;

-- 16. Cuantas vacantes abiertas tiene cada carrera y como se reparten por
--     pertinencia (ALTA/MEDIA/BAJA)? SUM OVER da el total por carrera.
SELECT
    c.nombre AS carrera,
    oc.pertinencia,
    COUNT(o.id_oferta) AS ofertas,
    SUM(o.vacantes) AS vacantes,
    SUM(SUM(o.vacantes)) OVER (PARTITION BY c.id_carrera) AS vacantes_carrera,
    CAST(100.0 * SUM(o.vacantes)
         / SUM(SUM(o.vacantes)) OVER (PARTITION BY c.id_carrera)
         AS DECIMAL(5,1)) AS porcentaje_de_la_carrera
FROM Carrera c
INNER JOIN Oferta_Carrera oc ON oc.id_carrera = c.id_carrera
INNER JOIN Oferta o ON o.id_oferta = oc.id_oferta
WHERE o.estado = N'PUBLICADA'
GROUP BY c.id_carrera, c.nombre, oc.pertinencia
ORDER BY c.nombre,
    CASE oc.pertinencia WHEN N'ALTA' THEN 1 WHEN N'MEDIA' THEN 2 ELSE 3 END;

-- 17. Cual es la oferta mas demandada de cada carrera y con que pertinencia
--     la clasifica esa carrera? (ROW_NUMBER por carrera; desempata por id)
WITH demanda AS (
    SELECT
        oc.id_carrera,
        o.id_oferta,
        o.titulo,
        oc.pertinencia,
        COUNT(po.id_postulacion) AS postulaciones,
        ROW_NUMBER() OVER (
            PARTITION BY oc.id_carrera
            ORDER BY COUNT(po.id_postulacion) DESC, o.id_oferta
        ) AS orden
    FROM Oferta_Carrera oc
    INNER JOIN Oferta o ON o.id_oferta = oc.id_oferta
    LEFT JOIN Postulacion po
        ON po.id_oferta = oc.id_oferta AND po.id_carrera = oc.id_carrera
    GROUP BY oc.id_carrera, o.id_oferta, o.titulo, oc.pertinencia
)
SELECT
    c.nombre AS carrera,
    d.titulo AS oferta_mas_demandada,
    d.pertinencia,
    d.postulaciones
FROM demanda d
INNER JOIN Carrera c ON c.id_carrera = d.id_carrera
WHERE d.orden = 1
ORDER BY d.postulaciones DESC, c.nombre;

-- 18. Cuanto tarda en promedio una postulacion en pasar de una etapa a la
--     siguiente? (LAG sobre el historial de estados, en dias)
WITH h AS (
    SELECT
        estado_anterior,
        estado_nuevo,
        fecha_cambio,
        LAG(fecha_cambio) OVER (
            PARTITION BY id_postulacion
            ORDER BY fecha_cambio, id_historial
        ) AS fecha_previa
    FROM Postulacion_Estado_Historial
)
SELECT
    estado_anterior,
    estado_nuevo,
    COUNT(*) AS transiciones,
    CAST(AVG(CAST(DATEDIFF(HOUR, fecha_previa, fecha_cambio) AS DECIMAL(10,2))) / 24.0
         AS DECIMAL(8,2)) AS dias_promedio
FROM h
WHERE fecha_previa IS NOT NULL
GROUP BY estado_anterior, estado_nuevo
ORDER BY dias_promedio DESC;

-- 19. Cuanto tarda en promedio una practica en pasar de un estado al
--     siguiente (por ejemplo PLANIFICADA a EN_CURSO, EN_CURSO a FINALIZADA)?
WITH h AS (
    SELECT
        estado_anterior,
        estado_nuevo,
        fecha_cambio,
        LAG(fecha_cambio) OVER (
            PARTITION BY id_practica
            ORDER BY fecha_cambio, id_historial
        ) AS fecha_previa
    FROM Historial_Practica
)
SELECT
    estado_anterior,
    estado_nuevo,
    COUNT(*) AS transiciones,
    CAST(AVG(CAST(DATEDIFF(HOUR, fecha_previa, fecha_cambio) AS DECIMAL(10,2))) / 24.0
         AS DECIMAL(8,2)) AS dias_promedio
FROM h
WHERE fecha_previa IS NOT NULL
GROUP BY estado_anterior, estado_nuevo
ORDER BY dias_promedio DESC;

-- 20. Que practicas EN_CURSO tienen la revision de seguimiento vencida?
--     (se toma el ultimo seguimiento de cada practica)
WITH ultimo AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY s.id_practica
            ORDER BY s.fecha DESC, s.id_seguimiento DESC
        ) AS orden
    FROM Seguimiento s
)
SELECT
    pr.id_practica,
    e.legajo,
    e.nombre,
    e.apellido,
    em.razon_social AS empresa,
    u.estado_seguimiento,
    u.proxima_revision,
    DATEDIFF(DAY, u.proxima_revision, CAST(GETDATE() AS date)) AS dias_de_atraso
FROM ultimo u
INNER JOIN Practica pr ON pr.id_practica = u.id_practica
INNER JOIN Postulacion po ON po.id_postulacion = pr.id_postulacion
INNER JOIN Estudiante e ON e.id_estudiante = po.id_estudiante
INNER JOIN Oferta o ON o.id_oferta = po.id_oferta
INNER JOIN Empresa em ON em.id_empresa = o.id_empresa
WHERE u.orden = 1
  AND pr.estado = N'EN_CURSO'
  AND u.proxima_revision < CAST(GETDATE() AS date)
ORDER BY dias_de_atraso DESC;
