/* ================================================================
   PRUEBAS DE INTEGRIDAD
   ================================================================ */

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante
        (id_carrera, legajo, nombre, apellido, email, anio_ingreso, estado)
    SELECT
        id_carrera, legajo, 'Prueba', 'Duplicada',
        'prueba.duplicada@universidad.edu', anio_ingreso, 'ACTIVO'
    FROM Estudiante
    WHERE id_estudiante = 1;

    ROLLBACK TRANSACTION;
    PRINT 'ERROR: se permitio repetir el legajo.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'CORRECTO: no se permite repetir el legajo.';
END CATCH;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Oferta
    SET id_convenio = 2
    WHERE id_oferta = 1;

    ROLLBACK TRANSACTION;
    PRINT 'ERROR: se permitio asociar un convenio de otra empresa.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'CORRECTO: el convenio debe pertenecer a la empresa de la oferta.';
END CATCH;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante_Competencia
        (id_estudiante, id_competencia, nivel_declarado)
    VALUES
        (1, 1, 5);

    ROLLBACK TRANSACTION;
    PRINT 'ERROR: se permitio un nivel fuera del rango.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'CORRECTO: el nivel debe estar entre 1 y 3.';
END CATCH;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Postulacion
        (id_estudiante, id_oferta, estado, origen, observaciones)
    SELECT
        id_estudiante, id_oferta, 'RECIBIDA', 'CV', 'Prueba duplicada'
    FROM Postulacion
    WHERE id_postulacion = 1;

    ROLLBACK TRANSACTION;
    PRINT 'ERROR: se permitio una postulacion duplicada.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'CORRECTO: no se permiten postulaciones duplicadas.';
END CATCH;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Oferta
    SET vacantes = -1
    WHERE id_oferta = 1;

    ROLLBACK TRANSACTION;
    PRINT 'ERROR: se permitieron vacantes negativas.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'CORRECTO: las vacantes deben ser mayores que cero.';
END CATCH;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Evaluacion
        (id_practica, tipo_evaluador, puntaje_desempeno,
         puntaje_satisfaccion, resultado, comentarios)
    VALUES
        (1, 'UNIVERSIDAD', 8, 8, 'PRUEBA', 'Puntajes incorrectos');

    ROLLBACK TRANSACTION;
    PRINT 'ERROR: se permitieron puntajes fuera del rango.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'CORRECTO: los puntajes deben estar entre 1 y 5.';
END CATCH;
GO
