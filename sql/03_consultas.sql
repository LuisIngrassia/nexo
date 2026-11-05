/* ================================================================
   CONSULTAS DE NEGOCIO
   ================================================================ */

SELECT
    c.nombre AS carrera,
    c.plan_estudios,
    COUNT(e.id_estudiante) AS cantidad_estudiantes
FROM Carrera c
LEFT JOIN Estudiante e ON e.id_carrera = c.id_carrera
GROUP BY c.nombre, c.plan_estudios
ORDER BY cantidad_estudiantes DESC;

SELECT
    carrera,
    plan_estudios,
    COUNT(id_oferta) AS cantidad_ofertas
FROM vw_OfertasPorCarrera
GROUP BY carrera, plan_estudios
ORDER BY cantidad_ofertas DESC;

SELECT
    c.nombre AS competencia,
    COUNT(oc.id_oferta) AS cantidad_ofertas
FROM Competencia c
LEFT JOIN Oferta_Competencia oc
    ON oc.id_competencia = c.id_competencia
GROUP BY c.nombre
ORDER BY cantidad_ofertas DESC;

SELECT
    e.legajo,
    e.nombre,
    e.apellido,
    c.nombre AS competencia,
    ec.nivel_declarado,
    CASE
        WHEN ec.nivel_declarado = 1 THEN 'BASICO'
        WHEN ec.nivel_declarado = 2 THEN 'INTERMEDIO'
        WHEN ec.nivel_declarado = 3 THEN 'AVANZADO'
    END AS nivel
FROM Estudiante e
INNER JOIN Estudiante_Competencia ec
    ON ec.id_estudiante = e.id_estudiante
INNER JOIN Competencia c
    ON c.id_competencia = ec.id_competencia
ORDER BY e.apellido, e.nombre, c.nombre;

SELECT *
FROM vw_EmbudoPostulaciones
ORDER BY titulo, estado;

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

SELECT *
FROM vw_PracticasActivas
ORDER BY fecha_inicio;

SELECT *
FROM vw_PracticasQueRequierenIntervencion
ORDER BY proxima_revision;

SELECT *
FROM vw_ResultadosEmpresa
ORDER BY promedio_satisfaccion DESC;

SELECT *
FROM vw_ResultadosCarrera
ORDER BY promedio_satisfaccion DESC;

SELECT *
FROM vw_AvanceAcademico
ORDER BY porcentaje_avance DESC;

SELECT *
FROM vw_BrechaCompetencias
ORDER BY ofertas_que_la_solicitan DESC;

SELECT
    p.id_postulacion,
    e.legajo,
    o.titulo,
    h.estado_nuevo,
    h.motivo
FROM Postulacion_Estado_Historial h
INNER JOIN Postulacion p ON p.id_postulacion = h.id_postulacion
INNER JOIN Estudiante e ON e.id_estudiante = p.id_estudiante
INNER JOIN Oferta o ON o.id_oferta = p.id_oferta
WHERE h.estado_nuevo IN ('RECHAZADA', 'RETIRADA')
ORDER BY p.id_postulacion;

SELECT
    e.id_empresa,
    e.razon_social,
    e.sector
FROM Empresa e
WHERE NOT EXISTS (
    SELECT 1
    FROM Convenio c
    WHERE c.id_empresa = e.id_empresa
      AND c.estado = 'VIGENTE'
      AND c.fecha_inicio <= GETDATE()
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= GETDATE())
);
