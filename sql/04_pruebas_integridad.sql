USE NexoAcademico;
GO

/* ================================================================
   PRUEBAS DE INTEGRIDAD
   Cada prueba corre en BEGIN TRAN ... ROLLBACK y no deja datos.
   Se valida el numero de error esperado (547 CHECK/FK, 2627/2601 UQ/PK,
   245/241/8114/8115/8152/2628 conversion y tamano, 515 NULL, 50001+ THROW) y,
   cuando se indica, que el mensaje nombre la restriccion esperada.
   Los IDs se obtienen de los datos (SELECT TOP 1), nunca son fijos.
   Resultado: una linea OK / FALLA por prueba y un resumen al final.
   ================================================================ */

SET NOCOUNT ON;
GO

IF OBJECT_ID('tempdb..#Resultado') IS NOT NULL DROP TABLE #Resultado;
IF OBJECT_ID('tempdb..#Conteo') IS NOT NULL DROP TABLE #Conteo;
IF OBJECT_ID('tempdb..#Reg') IS NOT NULL DROP PROCEDURE #Reg;
GO

CREATE TABLE #Resultado (
    id INT NOT NULL PRIMARY KEY,
    prueba VARCHAR(200) NOT NULL,
    ok BIT NOT NULL,
    detalle VARCHAR(600) NULL
);

-- Foto de filas por tabla para comprobar al final que nada cambio.
SELECT t.name AS tabla, SUM(p.rows) AS filas
INTO #Conteo
FROM sys.tables t
INNER JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name;
GO

-- Registra el resultado de una prueba.
-- @esperados: lista de numeros de error aceptados; NULL = se espera exito.
-- @num / @msg: error capturado (NULL si no hubo error).
CREATE PROCEDURE #Reg
    @id INT,
    @prueba VARCHAR(200),
    @esperados VARCHAR(50),
    @patron VARCHAR(200),
    @num INT,
    @msg VARCHAR(4000)
AS
BEGIN
    DECLARE @ok BIT = 0, @detalle VARCHAR(600);

    IF @esperados IS NULL
    BEGIN
        IF @num IS NULL SET @ok = 1;
        ELSE SET @detalle = CONCAT('esperaba exito, error ', @num, ': ', LEFT(@msg, 300));
    END
    ELSE IF @num IS NULL
        SET @detalle = CONCAT('esperaba error ', @esperados, ' pero la operacion se permitio');
    ELSE IF CONCAT(',', @esperados, ',') NOT LIKE CONCAT('%,', @num, ',%')
        SET @detalle = CONCAT('esperaba error ', @esperados, ', obtuvo ', @num, ': ', LEFT(@msg, 300));
    ELSE IF @patron IS NOT NULL AND @msg NOT LIKE @patron
        SET @detalle = CONCAT('error ', @num, ' correcto pero el mensaje no contiene ', @patron, ': ', LEFT(@msg, 300));
    ELSE
        SET @ok = 1;

    INSERT INTO #Resultado (id, prueba, ok, detalle) VALUES (@id, @prueba, @ok, @detalle);
    PRINT CONCAT(CASE WHEN @ok = 1 THEN 'OK    ' ELSE 'FALLA ' END,
                 'Prueba ', @id, ': ', @prueba, ISNULL(CONCAT(' -> ', @detalle), ''));
END;
GO

-- Prueba 1: Tipo: texto en nivel_declarado (INT)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Competencia SET nivel_declarado = 'abc';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 1, @prueba = 'Tipo: texto en nivel_declarado (INT)', @esperados = '245', @patron = '%abc%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 1, @prueba = 'Tipo: texto en nivel_declarado (INT)', @esperados = '245', @patron = '%abc%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 2: Tipo: texto en vacantes (INT)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET vacantes = 'muchas';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 2, @prueba = 'Tipo: texto en vacantes (INT)', @esperados = '245', @patron = '%muchas%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 2, @prueba = 'Tipo: texto en vacantes (INT)', @esperados = '245', @patron = '%muchas%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 3: Tipo: texto en horas_semanales (INT)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET horas_semanales = 'veinte';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 3, @prueba = 'Tipo: texto en horas_semanales (INT)', @esperados = '245', @patron = '%veinte%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 3, @prueba = 'Tipo: texto en horas_semanales (INT)', @esperados = '245', @patron = '%veinte%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 4: Tipo: texto en puntaje_desempeno (DECIMAL)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_desempeno = 'alto';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 4, @prueba = 'Tipo: texto en puntaje_desempeno (DECIMAL)', @esperados = '8114,245', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 4, @prueba = 'Tipo: texto en puntaje_desempeno (DECIMAL)', @esperados = '8114,245', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 5: Tipo: puntaje 100 desborda DECIMAL(3,1)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_desempeno = 100;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 5, @prueba = 'Tipo: puntaje 100 desborda DECIMAL(3,1)', @esperados = '8115', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 5, @prueba = 'Tipo: puntaje 100 desborda DECIMAL(3,1)', @esperados = '8115', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 6: Tipo: texto que no es fecha en fecha_cierre (DATE)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET fecha_cierre = 'no-es-una-fecha';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 6, @prueba = 'Tipo: texto que no es fecha en fecha_cierre (DATE)', @esperados = '241,242,295', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 6, @prueba = 'Tipo: texto que no es fecha en fecha_cierre (DATE)', @esperados = '241,242,295', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 7: Tipo: texto demasiado largo en nombre
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante SET nombre = REPLICATE('x', 4000);

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 7, @prueba = 'Tipo: texto demasiado largo en nombre', @esperados = '8152,2628', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 7, @prueba = 'Tipo: texto demasiado largo en nombre', @esperados = '8152,2628', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 8: Rango: nivel_declarado 4
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Competencia SET nivel_declarado = 4;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 8, @prueba = 'Rango: nivel_declarado 4', @esperados = '547', @patron = '%CK_EstudianteCompetencia_Nivel%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 8, @prueba = 'Rango: nivel_declarado 4', @esperados = '547', @patron = '%CK_EstudianteCompetencia_Nivel%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 9: Rango: nivel_declarado 0
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Competencia SET nivel_declarado = 0;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 9, @prueba = 'Rango: nivel_declarado 0', @esperados = '547', @patron = '%CK_EstudianteCompetencia_Nivel%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 9, @prueba = 'Rango: nivel_declarado 0', @esperados = '547', @patron = '%CK_EstudianteCompetencia_Nivel%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 10: Rango: nivel_requerido 4
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta_Competencia SET nivel_requerido = 4;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 10, @prueba = 'Rango: nivel_requerido 4', @esperados = '547', @patron = '%CK_OfertaCompetencia_Nivel%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 10, @prueba = 'Rango: nivel_requerido 4', @esperados = '547', @patron = '%CK_OfertaCompetencia_Nivel%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 11: Rango: puntaje_desempeno 6
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_desempeno = 6;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 11, @prueba = 'Rango: puntaje_desempeno 6', @esperados = '547', @patron = '%CK_Evaluacion_Desempeno%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 11, @prueba = 'Rango: puntaje_desempeno 6', @esperados = '547', @patron = '%CK_Evaluacion_Desempeno%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 12: Rango: puntaje_satisfaccion 6
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_satisfaccion = 6;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 12, @prueba = 'Rango: puntaje_satisfaccion 6', @esperados = '547', @patron = '%CK_Evaluacion_Satisfaccion%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 12, @prueba = 'Rango: puntaje_satisfaccion 6', @esperados = '547', @patron = '%CK_Evaluacion_Satisfaccion%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 13: Rango: horas_semanales 60
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET horas_semanales = 60;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 13, @prueba = 'Rango: horas_semanales 60', @esperados = '547', @patron = '%CK_Practica_Horas%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 13, @prueba = 'Rango: horas_semanales 60', @esperados = '547', @patron = '%CK_Practica_Horas%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 14: Rango: horas_semanales 0
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET horas_semanales = 0;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 14, @prueba = 'Rango: horas_semanales 0', @esperados = '547', @patron = '%CK_Practica_Horas%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 14, @prueba = 'Rango: horas_semanales 0', @esperados = '547', @patron = '%CK_Practica_Horas%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 15: Rango: vacantes 0
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET vacantes = 0;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 15, @prueba = 'Rango: vacantes 0', @esperados = '547', @patron = '%CK_Oferta_Vacantes%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 15, @prueba = 'Rango: vacantes 0', @esperados = '547', @patron = '%CK_Oferta_Vacantes%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 16: Rango: vacantes -1
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET vacantes = -1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 16, @prueba = 'Rango: vacantes -1', @esperados = '547', @patron = '%CK_Oferta_Vacantes%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 16, @prueba = 'Rango: vacantes -1', @esperados = '547', @patron = '%CK_Oferta_Vacantes%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 17: Rango: anio_ingreso 1800 en Estudiante_Carrera
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Carrera SET anio_ingreso = 1800;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 17, @prueba = 'Rango: anio_ingreso 1800 en Estudiante_Carrera', @esperados = '547', @patron = '%anio_ingreso%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 17, @prueba = 'Rango: anio_ingreso 1800 en Estudiante_Carrera', @esperados = '547', @patron = '%anio_ingreso%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 18: Dominio: estado de postulacion inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Postulacion SET estado = 'INEXISTENTE';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 18, @prueba = 'Dominio: estado de postulacion inexistente', @esperados = '547', @patron = '%CK_Postulacion_Estado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 18, @prueba = 'Dominio: estado de postulacion inexistente', @esperados = '547', @patron = '%CK_Postulacion_Estado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 19: Dominio: estado de oferta inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET estado = 'INEXISTENTE' WHERE fecha_publicacion IS NOT NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 19, @prueba = 'Dominio: estado de oferta inexistente', @esperados = '547', @patron = '%CK_Oferta_Estado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 19, @prueba = 'Dominio: estado de oferta inexistente', @esperados = '547', @patron = '%CK_Oferta_Estado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 20: Dominio: estado de Estudiante_Carrera inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Carrera SET estado = 'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 20, @prueba = 'Dominio: estado de Estudiante_Carrera inexistente', @esperados = '547', @patron = '%Estado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 20, @prueba = 'Dominio: estado de Estudiante_Carrera inexistente', @esperados = '547', @patron = '%Estado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 21: Dominio: pertinencia 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta_Carrera SET pertinencia = 'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 21, @prueba = 'Dominio: pertinencia ''X''', @esperados = '547', @patron = '%pertinencia%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 21, @prueba = 'Dominio: pertinencia ''X''', @esperados = '547', @patron = '%pertinencia%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 22: Dominio: origen de postulacion 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Postulacion SET origen = 'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 22, @prueba = 'Dominio: origen de postulacion ''X''', @esperados = '547', @patron = '%origen%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 22, @prueba = 'Dominio: origen de postulacion ''X''', @esperados = '547', @patron = '%origen%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 23: Dominio: etapa de entrevista 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Entrevista SET etapa = 'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 23, @prueba = 'Dominio: etapa de entrevista ''X''', @esperados = '547', @patron = '%etapa%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 23, @prueba = 'Dominio: etapa de entrevista ''X''', @esperados = '547', @patron = '%etapa%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 24: Dominio: instancia de evaluacion 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET instancia = 'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 24, @prueba = 'Dominio: instancia de evaluacion ''X''', @esperados = '547', @patron = '%instancia%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 24, @prueba = 'Dominio: instancia de evaluacion ''X''', @esperados = '547', @patron = '%instancia%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 25: Dominio: resultado de evaluacion 'PRUEBA'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET resultado = 'PRUEBA';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 25, @prueba = 'Dominio: resultado de evaluacion ''PRUEBA''', @esperados = '547', @patron = '%resultado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 25, @prueba = 'Dominio: resultado de evaluacion ''PRUEBA''', @esperados = '547', @patron = '%resultado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 26: Coherencia: practica FINALIZADA sin fecha_fin_real
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET estado = 'FINALIZADA', fecha_fin_real = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 26, @prueba = 'Coherencia: practica FINALIZADA sin fecha_fin_real', @esperados = '547', @patron = '%CK_Practica%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 26, @prueba = 'Coherencia: practica FINALIZADA sin fecha_fin_real', @esperados = '547', @patron = '%CK_Practica%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 27: Coherencia: oferta PUBLICADA sin fecha_publicacion
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET estado = 'PUBLICADA', fecha_publicacion = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 27, @prueba = 'Coherencia: oferta PUBLICADA sin fecha_publicacion', @esperados = '547', @patron = '%CK_Oferta%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 27, @prueba = 'Coherencia: oferta PUBLICADA sin fecha_publicacion', @esperados = '547', @patron = '%CK_Oferta%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 28: Dominio: estado_nuevo de Historial_Practica inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_practica FROM Practica);
    IF @p IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    INSERT INTO Historial_Practica (id_practica, estado_nuevo) VALUES (@p, 'INEXISTENTE');

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 28, @prueba = 'Dominio: estado_nuevo de Historial_Practica inexistente', @esperados = '547', @patron = '%Historial%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 28, @prueba = 'Dominio: estado_nuevo de Historial_Practica inexistente', @esperados = '547', @patron = '%Historial%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 29: NULL: titulo de oferta
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET titulo = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 29, @prueba = 'NULL: titulo de oferta', @esperados = '515', @patron = '%titulo%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 29, @prueba = 'NULL: titulo de oferta', @esperados = '515', @patron = '%titulo%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 30: NULL: nombre de estudiante
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante SET nombre = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 30, @prueba = 'NULL: nombre de estudiante', @esperados = '515', @patron = '%nombre%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 30, @prueba = 'NULL: nombre de estudiante', @esperados = '515', @patron = '%nombre%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 31: UQ: legajo repetido
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante (legajo, nombre, apellido, email)
    SELECT TOP (1) legajo, 'Prueba', 'Duplicado', 'prueba.duplicado@universidad.edu'
    FROM Estudiante;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 31, @prueba = 'UQ: legajo repetido', @esperados = '2627,2601', @patron = '%UQ_Estudiante_Legajo%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 31, @prueba = 'UQ: legajo repetido', @esperados = '2627,2601', @patron = '%UQ_Estudiante_Legajo%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 32: UQ: postulacion duplicada (estudiante, oferta)
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    SELECT TOP (1) id_estudiante, id_oferta, id_carrera, 'RECIBIDA', 'CV'
    FROM Postulacion;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 32, @prueba = 'UQ: postulacion duplicada (estudiante, oferta)', @esperados = '2627,2601', @patron = '%UQ_Postulacion_Estudiante_Oferta%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 32, @prueba = 'UQ: postulacion duplicada (estudiante, oferta)', @esperados = '2627,2601', @patron = '%UQ_Postulacion_Estudiante_Oferta%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 33: UQ: evaluacion repetida (practica, evaluador, instancia)
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Evaluacion (id_practica, tipo_evaluador, instancia, resultado)
    SELECT TOP (1) id_practica, tipo_evaluador, instancia, 'SATISFACTORIA'
    FROM Evaluacion;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 33, @prueba = 'UQ: evaluacion repetida (practica, evaluador, instancia)', @esperados = '2627,2601', @patron = '%UQ_Evaluacion%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 33, @prueba = 'UQ: evaluacion repetida (practica, evaluador, instancia)', @esperados = '2627,2601', @patron = '%UQ_Evaluacion%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 34: PK: Estudiante_Carrera repetida
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado)
    SELECT TOP (1) id_estudiante, id_carrera, anio_ingreso, estado
    FROM Estudiante_Carrera;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 34, @prueba = 'PK: Estudiante_Carrera repetida', @esperados = '2627,2601', @patron = '%Estudiante_Carrera%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 34, @prueba = 'PK: Estudiante_Carrera repetida', @esperados = '2627,2601', @patron = '%Estudiante_Carrera%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 35: FK: convenio de otra empresa en una oferta
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @o INT, @c INT;
    SELECT TOP (1) @o = o.id_oferta, @c = c.id_convenio
    FROM Oferta o
    INNER JOIN Convenio c ON c.id_empresa <> o.id_empresa;
    IF @o IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Oferta SET id_convenio = @c WHERE id_oferta = @o;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 35, @prueba = 'FK: convenio de otra empresa en una oferta', @esperados = '547', @patron = '%FK_Oferta_Convenio_Empresa%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 35, @prueba = 'FK: convenio de otra empresa en una oferta', @esperados = '547', @patron = '%FK_Oferta_Convenio_Empresa%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 36: FK: estudiante inexistente en Estudiante_Competencia
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante_Competencia (id_estudiante, id_competencia, nivel_declarado)
    SELECT (SELECT MAX(id_estudiante) + 1000 FROM Estudiante), MIN(id_competencia), 1
    FROM Competencia;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 36, @prueba = 'FK: estudiante inexistente en Estudiante_Competencia', @esperados = '547', @patron = '%FK_EstudianteCompetencia_Estudiante%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 36, @prueba = 'FK: estudiante inexistente en Estudiante_Competencia', @esperados = '547', @patron = '%FK_EstudianteCompetencia_Estudiante%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 37: FK compuesta: postulacion a carrera que el estudiante no cursa
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @e INT, @o INT, @c INT;
    SELECT TOP (1) @e = e.id_estudiante, @o = o.id_oferta, @c = c.id_carrera
    FROM Estudiante e CROSS JOIN Oferta o CROSS JOIN Carrera c
    WHERE NOT EXISTS (SELECT 1 FROM Postulacion p WHERE p.id_estudiante = e.id_estudiante AND p.id_oferta = o.id_oferta)
      AND NOT EXISTS (SELECT 1 FROM Estudiante_Carrera x WHERE x.id_estudiante = e.id_estudiante AND x.id_carrera = c.id_carrera);
    IF @e IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    VALUES (@e, @o, @c, 'RECIBIDA', 'CV');

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 37, @prueba = 'FK compuesta: postulacion a carrera que el estudiante no cursa', @esperados = '547', @patron = '%Carrera%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 37, @prueba = 'FK compuesta: postulacion a carrera que el estudiante no cursa', @esperados = '547', @patron = '%Carrera%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 38: Proc: transicion ilegal RECHAZADA -> EN_REVISION
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_postulacion FROM Postulacion);
    IF @p IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = 'RECHAZADA' WHERE id_postulacion = @p;
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = 'EN_REVISION', @motivo = 'Prueba transicion ilegal';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 38, @prueba = 'Proc: transicion ilegal RECHAZADA -> EN_REVISION', @esperados = '50003', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 38, @prueba = 'Proc: transicion ilegal RECHAZADA -> EN_REVISION', @esperados = '50003', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 39: Proc: transicion ilegal RECIBIDA -> SELECCIONADA (salta etapas)
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_postulacion FROM Postulacion);
    IF @p IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = 'RECIBIDA' WHERE id_postulacion = @p;
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = 'SELECCIONADA', @motivo = 'Prueba salto de etapas';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 39, @prueba = 'Proc: transicion ilegal RECIBIDA -> SELECCIONADA (salta etapas)', @esperados = '50003', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 39, @prueba = 'Proc: transicion ilegal RECIBIDA -> SELECCIONADA (salta etapas)', @esperados = '50003', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 40: Proc: cambiar estado de postulacion inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    EXEC usp_CambiarEstadoPostulacion @id_postulacion = -1, @estado_nuevo = 'EN_REVISION', @motivo = 'Prueba inexistente';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 40, @prueba = 'Proc: cambiar estado de postulacion inexistente', @esperados = '50001', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 40, @prueba = 'Proc: cambiar estado de postulacion inexistente', @esperados = '50001', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 41: Proc: postulacion a carrera que no corresponde al estudiante
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @e INT, @o INT, @c INT;
    SELECT TOP (1) @e = e.id_estudiante, @o = o.id_oferta, @c = c.id_carrera
    FROM Estudiante e CROSS JOIN Oferta o CROSS JOIN Carrera c
    WHERE NOT EXISTS (SELECT 1 FROM Postulacion p WHERE p.id_estudiante = e.id_estudiante AND p.id_oferta = o.id_oferta)
      AND NOT EXISTS (SELECT 1 FROM Estudiante_Carrera x WHERE x.id_estudiante = e.id_estudiante AND x.id_carrera = c.id_carrera);
    IF @e IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Oferta
    SET estado = 'PUBLICADA',
        fecha_publicacion = DATEADD(DAY, -30, CAST(GETDATE() AS date)),
        fecha_cierre = DATEADD(YEAR, 1, CAST(GETDATE() AS date))
    WHERE id_oferta = @o;
    EXEC usp_RegistrarPostulacion @id_estudiante = @e, @id_oferta = @o, @id_carrera = @c, @origen = 'PORTAL', @observaciones = 'Prueba carrera incorrecta';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 41, @prueba = 'Proc: postulacion a carrera que no corresponde al estudiante', @esperados = '50005,547', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 41, @prueba = 'Proc: postulacion a carrera que no corresponde al estudiante', @esperados = '50005,547', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 42: Proc: materia aprobada de una carrera que el estudiante no cursa
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @e INT, @mat INT, @hoy DATE = CAST(GETDATE() AS date);
    SELECT TOP (1) @e = e.id_estudiante, @mat = m.id_materia
    FROM Estudiante e CROSS JOIN Materia m
    WHERE NOT EXISTS (SELECT 1 FROM Estudiante_Carrera x WHERE x.id_estudiante = e.id_estudiante AND x.id_carrera = m.id_carrera);
    IF @e IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    EXEC usp_RegistrarMateriaAprobada @id_estudiante = @e, @id_materia = @mat, @fecha_aprobacion = @hoy;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 42, @prueba = 'Proc: materia aprobada de una carrera que el estudiante no cursa', @esperados = '50005', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 42, @prueba = 'Proc: materia aprobada de una carrera que el estudiante no cursa', @esperados = '50005', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 43: Proc: publicar oferta sin convenio
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @o INT;
    SELECT TOP (1) @o = o.id_oferta
    FROM Oferta o
    INNER JOIN Empresa em ON em.id_empresa = o.id_empresa
    WHERE em.estado_vinculo = 'ACTIVA'
      AND EXISTS (SELECT 1 FROM Oferta_Carrera oc WHERE oc.id_oferta = o.id_oferta)
      AND EXISTS (SELECT 1 FROM Oferta_Competencia oc WHERE oc.id_oferta = o.id_oferta);
    IF @o IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Oferta SET estado = 'BORRADOR', id_convenio = NULL WHERE id_oferta = @o;
    EXEC usp_PublicarOferta @id_oferta = @o;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 43, @prueba = 'Proc: publicar oferta sin convenio', @esperados = '50006', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 43, @prueba = 'Proc: publicar oferta sin convenio', @esperados = '50006', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 44: Proc: seleccionar sin vacantes
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT, @o INT, @c INT, @e INT;
    SELECT TOP (1) @p = id_postulacion, @o = id_oferta, @c = id_carrera FROM Postulacion;
    IF @p IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = 'ENTREVISTA' WHERE id_postulacion = @p;
    UPDATE Oferta SET vacantes = 1 WHERE id_oferta = @o;
    INSERT INTO Estudiante (legajo, nombre, apellido, email)
    VALUES (CONCAT('T-', LEFT(CONVERT(VARCHAR(36), NEWID()), 8)), 'Prueba', 'Temporal',
            CONCAT('prueba.', LEFT(CONVERT(VARCHAR(36), NEWID()), 8), '@universidad.edu'));
    SET @e = SCOPE_IDENTITY();
    INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado) VALUES (@e, @c, 2024, 'ACTIVO');
    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    VALUES (@e, @o, @c, 'SELECCIONADA', 'PORTAL');
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = 'SELECCIONADA', @motivo = 'Prueba sin vacantes';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 44, @prueba = 'Proc: seleccionar sin vacantes', @esperados = '50007', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 44, @prueba = 'Proc: seleccionar sin vacantes', @esperados = '50007', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 45: Proc: cerrar practica sin evaluacion FINAL
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT, @f DATE;
    SELECT TOP (1) @p = id_practica, @f = fecha_inicio FROM Practica;
    IF @p IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Practica SET estado = 'EN_CURSO', fecha_fin_real = NULL WHERE id_practica = @p;
    DELETE FROM Evaluacion WHERE id_practica = @p AND instancia = 'FINAL';
    EXEC usp_CerrarPractica @id_practica = @p, @fecha_fin_real = @f, @motivo_cierre = 'Prueba sin evaluacion final';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 45, @prueba = 'Proc: cerrar practica sin evaluacion FINAL', @esperados = '50009', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 45, @prueba = 'Proc: cerrar practica sin evaluacion FINAL', @esperados = '50009', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 46: Proc: postulacion duplicada
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @e INT, @o INT, @c INT;
    SELECT TOP (1) @e = id_estudiante, @o = id_oferta, @c = id_carrera FROM Postulacion;
    IF @e IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Oferta
    SET estado = 'PUBLICADA',
        fecha_publicacion = DATEADD(DAY, -30, CAST(GETDATE() AS date)),
        fecha_cierre = DATEADD(YEAR, 1, CAST(GETDATE() AS date))
    WHERE id_oferta = @o;
    UPDATE Estudiante_Carrera SET estado = 'ACTIVO' WHERE id_estudiante = @e AND id_carrera = @c;
    EXEC usp_RegistrarPostulacion @id_estudiante = @e, @id_oferta = @o, @id_carrera = @c, @origen = 'PORTAL', @observaciones = 'Prueba duplicada';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 46, @prueba = 'Proc: postulacion duplicada', @esperados = '50010,2627', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 46, @prueba = 'Proc: postulacion duplicada', @esperados = '50010,2627', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 47: Feliz: registrar postulacion y dejar historial
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @o INT, @c INT, @e INT, @p INT;
    SELECT TOP (1) @o = id_oferta, @c = id_carrera FROM Oferta_Carrera;
    IF @o IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Oferta
    SET estado = 'PUBLICADA',
        fecha_publicacion = DATEADD(DAY, -30, CAST(GETDATE() AS date)),
        fecha_cierre = DATEADD(YEAR, 1, CAST(GETDATE() AS date))
    WHERE id_oferta = @o;
    INSERT INTO Estudiante (legajo, nombre, apellido, email)
    VALUES (CONCAT('T-', LEFT(CONVERT(VARCHAR(36), NEWID()), 8)), 'Prueba', 'Temporal',
            CONCAT('prueba.', LEFT(CONVERT(VARCHAR(36), NEWID()), 8), '@universidad.edu'));
    SET @e = SCOPE_IDENTITY();
    INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado)
    VALUES (@e, @c, 2024, 'ACTIVO');
    EXEC usp_RegistrarPostulacion @id_estudiante = @e, @id_oferta = @o, @id_carrera = @c, @origen = 'PORTAL', @observaciones = 'Prueba caso feliz';
    SELECT @p = id_postulacion FROM Postulacion WHERE id_estudiante = @e AND id_oferta = @o;
    IF @p IS NULL OR NOT EXISTS (SELECT 1 FROM Postulacion_Estado_Historial WHERE id_postulacion = @p AND estado_nuevo = 'RECIBIDA')
        THROW 59998, 'La postulacion o su historial no quedaron registrados.', 1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 47, @prueba = 'Feliz: registrar postulacion y dejar historial', @esperados = NULL, @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 47, @prueba = 'Feliz: registrar postulacion y dejar historial', @esperados = NULL, @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 48: Feliz: transicion legal RECIBIDA -> EN_REVISION
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_postulacion FROM Postulacion);
    IF @p IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = 'RECIBIDA' WHERE id_postulacion = @p;
    DECLARE @antes INT = (SELECT COUNT(*) FROM Postulacion_Estado_Historial WHERE id_postulacion = @p);
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = 'EN_REVISION', @motivo = 'Prueba caso feliz';
    IF NOT EXISTS (SELECT 1 FROM Postulacion WHERE id_postulacion = @p AND estado = 'EN_REVISION')
       OR (SELECT COUNT(*) FROM Postulacion_Estado_Historial WHERE id_postulacion = @p) <> @antes + 1
        THROW 59998, 'El estado o el historial no se actualizaron.', 1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 48, @prueba = 'Feliz: transicion legal RECIBIDA -> EN_REVISION', @esperados = NULL, @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 48, @prueba = 'Feliz: transicion legal RECIBIDA -> EN_REVISION', @esperados = NULL, @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 49: Feliz: cerrar practica con seguimiento y evaluaciones FINAL
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT, @f DATE;
    SELECT TOP (1) @p = id_practica, @f = fecha_inicio FROM Practica;
    IF @p IS NULL THROW 59999, 'Sin datos para armar la prueba.', 1;
    UPDATE Practica SET estado = 'EN_CURSO', fecha_fin_real = NULL WHERE id_practica = @p;
    DELETE FROM Evaluacion WHERE id_practica = @p AND instancia = 'FINAL';
    INSERT INTO Evaluacion (id_practica, tipo_evaluador, instancia, resultado)
    VALUES (@p, 'ESTUDIANTE', 'FINAL', 'SATISFACTORIA'), (@p, 'EMPRESA', 'FINAL', 'SATISFACTORIA');
    IF NOT EXISTS (SELECT 1 FROM Seguimiento WHERE id_practica = @p)
        INSERT INTO Seguimiento (id_practica, tipo_seguimiento, origen_feedback, estado_seguimiento, observaciones)
        VALUES (@p, 'CIERRE', 'AMBOS', 'SIN_NOVEDADES', 'Prueba caso feliz');
    EXEC usp_CerrarPractica @id_practica = @p, @fecha_fin_real = @f, @motivo_cierre = 'Prueba caso feliz';
    IF NOT EXISTS (SELECT 1 FROM Practica WHERE id_practica = @p AND estado = 'FINALIZADA' AND fecha_fin_real IS NOT NULL)
       OR NOT EXISTS (SELECT 1 FROM Historial_Practica WHERE id_practica = @p AND estado_nuevo = 'FINALIZADA')
        THROW 59998, 'La practica no quedo FINALIZADA con su historial.', 1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 49, @prueba = 'Feliz: cerrar practica con seguimiento y evaluaciones FINAL', @esperados = NULL, @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m VARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 49, @prueba = 'Feliz: cerrar practica con seguimiento y evaluaciones FINAL', @esperados = NULL, @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

/* ================================================================
   RESUMEN
   ================================================================ */
DECLARE @pend INT = @@TRANCOUNT;
DECLARE @dif INT = (
    SELECT COUNT(*)
    FROM #Conteo c
    INNER JOIN (
        SELECT t.name AS tabla, SUM(p.rows) AS filas
        FROM sys.tables t
        INNER JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
        GROUP BY t.name
    ) a ON a.tabla = c.tabla
    WHERE a.filas <> c.filas
);

SELECT id AS prueba, CASE WHEN ok = 1 THEN 'OK' ELSE 'FALLA' END AS resultado, prueba AS descripcion, detalle
FROM #Resultado
ORDER BY id;

DECLARE @total INT = (SELECT COUNT(*) FROM #Resultado),
        @ok INT = (SELECT COUNT(*) FROM #Resultado WHERE ok = 1);
PRINT CONCAT('Pruebas: ', @total, ' | OK: ', @ok, ' | FALLA: ', @total - @ok);
PRINT CONCAT('Transacciones abiertas: ', @pend, ' | Tablas con filas distintas a las iniciales: ', @dif,
             ' (ambos deben ser 0; los huecos de IDENTITY por el ROLLBACK son esperables)');

DROP TABLE #Resultado;
DROP TABLE #Conteo;
DROP PROCEDURE #Reg;
GO
