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
    prueba NVARCHAR(200) NOT NULL,
    ok BIT NOT NULL,
    detalle NVARCHAR(600) NULL
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
    @prueba NVARCHAR(200),
    @esperados NVARCHAR(50),
    @patron NVARCHAR(200),
    @num INT,
    @msg NVARCHAR(4000)
AS
BEGIN
    DECLARE @ok BIT = 0, @detalle NVARCHAR(600);

    IF @esperados IS NULL
    BEGIN
        IF @num IS NULL SET @ok = 1;
        ELSE SET @detalle = CONCAT(N'esperaba exito, error ', @num, N': ', LEFT(@msg, 300));
    END
    ELSE IF @num IS NULL
        SET @detalle = CONCAT(N'esperaba error ', @esperados, N' pero la operacion se permitio');
    ELSE IF CONCAT(N',', @esperados, N',') NOT LIKE CONCAT(N'%,', @num, N',%')
        SET @detalle = CONCAT(N'esperaba error ', @esperados, N', obtuvo ', @num, N': ', LEFT(@msg, 300));
    ELSE IF @patron IS NOT NULL AND @msg NOT LIKE @patron
        SET @detalle = CONCAT(N'error ', @num, N' correcto pero el mensaje no contiene ', @patron, N': ', LEFT(@msg, 300));
    ELSE
        SET @ok = 1;

    INSERT INTO #Resultado (id, prueba, ok, detalle) VALUES (@id, @prueba, @ok, @detalle);
    PRINT CONCAT(CASE WHEN @ok = 1 THEN N'OK    ' ELSE N'FALLA ' END,
                 N'Prueba ', @id, N': ', @prueba, ISNULL(CONCAT(N' -> ', @detalle), N''));
END;
GO

-- Prueba 1: Tipo: texto en nivel_declarado (INT)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Competencia SET nivel_declarado = 'abc';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 1, @prueba = N'Tipo: texto en nivel_declarado (INT)', @esperados = N'245', @patron = N'%abc%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 1, @prueba = N'Tipo: texto en nivel_declarado (INT)', @esperados = N'245', @patron = N'%abc%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 2: Tipo: texto en vacantes (INT)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET vacantes = 'muchas';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 2, @prueba = N'Tipo: texto en vacantes (INT)', @esperados = N'245', @patron = N'%muchas%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 2, @prueba = N'Tipo: texto en vacantes (INT)', @esperados = N'245', @patron = N'%muchas%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 3: Tipo: texto en horas_semanales (INT)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET horas_semanales = 'veinte';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 3, @prueba = N'Tipo: texto en horas_semanales (INT)', @esperados = N'245', @patron = N'%veinte%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 3, @prueba = N'Tipo: texto en horas_semanales (INT)', @esperados = N'245', @patron = N'%veinte%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 4: Tipo: texto en puntaje_desempeno (DECIMAL)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_desempeno = 'alto';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 4, @prueba = N'Tipo: texto en puntaje_desempeno (DECIMAL)', @esperados = N'8114,245', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 4, @prueba = N'Tipo: texto en puntaje_desempeno (DECIMAL)', @esperados = N'8114,245', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 5: Tipo: puntaje 100 desborda DECIMAL(3,1)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_desempeno = 100;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 5, @prueba = N'Tipo: puntaje 100 desborda DECIMAL(3,1)', @esperados = N'8115', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 5, @prueba = N'Tipo: puntaje 100 desborda DECIMAL(3,1)', @esperados = N'8115', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 6: Tipo: texto que no es fecha en fecha_cierre (DATE)
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET fecha_cierre = 'no-es-una-fecha';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 6, @prueba = N'Tipo: texto que no es fecha en fecha_cierre (DATE)', @esperados = N'241,242,295', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 6, @prueba = N'Tipo: texto que no es fecha en fecha_cierre (DATE)', @esperados = N'241,242,295', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 7: Tipo: texto demasiado largo en nombre
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante SET nombre = REPLICATE(N'x', 4000);

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 7, @prueba = N'Tipo: texto demasiado largo en nombre', @esperados = N'8152,2628', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 7, @prueba = N'Tipo: texto demasiado largo en nombre', @esperados = N'8152,2628', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 8: Rango: nivel_declarado 4
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Competencia SET nivel_declarado = 4;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 8, @prueba = N'Rango: nivel_declarado 4', @esperados = N'547', @patron = N'%CK_EstudianteCompetencia_Nivel%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 8, @prueba = N'Rango: nivel_declarado 4', @esperados = N'547', @patron = N'%CK_EstudianteCompetencia_Nivel%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 9: Rango: nivel_declarado 0
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Competencia SET nivel_declarado = 0;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 9, @prueba = N'Rango: nivel_declarado 0', @esperados = N'547', @patron = N'%CK_EstudianteCompetencia_Nivel%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 9, @prueba = N'Rango: nivel_declarado 0', @esperados = N'547', @patron = N'%CK_EstudianteCompetencia_Nivel%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 10: Rango: nivel_requerido 4
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta_Competencia SET nivel_requerido = 4;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 10, @prueba = N'Rango: nivel_requerido 4', @esperados = N'547', @patron = N'%CK_OfertaCompetencia_Nivel%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 10, @prueba = N'Rango: nivel_requerido 4', @esperados = N'547', @patron = N'%CK_OfertaCompetencia_Nivel%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 11: Rango: puntaje_desempeno 6
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_desempeno = 6;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 11, @prueba = N'Rango: puntaje_desempeno 6', @esperados = N'547', @patron = N'%CK_Evaluacion_Desempeno%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 11, @prueba = N'Rango: puntaje_desempeno 6', @esperados = N'547', @patron = N'%CK_Evaluacion_Desempeno%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 12: Rango: puntaje_satisfaccion 6
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET puntaje_satisfaccion = 6;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 12, @prueba = N'Rango: puntaje_satisfaccion 6', @esperados = N'547', @patron = N'%CK_Evaluacion_Satisfaccion%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 12, @prueba = N'Rango: puntaje_satisfaccion 6', @esperados = N'547', @patron = N'%CK_Evaluacion_Satisfaccion%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 13: Rango: horas_semanales 60
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET horas_semanales = 60;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 13, @prueba = N'Rango: horas_semanales 60', @esperados = N'547', @patron = N'%CK_Practica_Horas%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 13, @prueba = N'Rango: horas_semanales 60', @esperados = N'547', @patron = N'%CK_Practica_Horas%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 14: Rango: horas_semanales 0
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET horas_semanales = 0;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 14, @prueba = N'Rango: horas_semanales 0', @esperados = N'547', @patron = N'%CK_Practica_Horas%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 14, @prueba = N'Rango: horas_semanales 0', @esperados = N'547', @patron = N'%CK_Practica_Horas%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 15: Rango: vacantes 0
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET vacantes = 0;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 15, @prueba = N'Rango: vacantes 0', @esperados = N'547', @patron = N'%CK_Oferta_Vacantes%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 15, @prueba = N'Rango: vacantes 0', @esperados = N'547', @patron = N'%CK_Oferta_Vacantes%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 16: Rango: vacantes -1
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET vacantes = -1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 16, @prueba = N'Rango: vacantes -1', @esperados = N'547', @patron = N'%CK_Oferta_Vacantes%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 16, @prueba = N'Rango: vacantes -1', @esperados = N'547', @patron = N'%CK_Oferta_Vacantes%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 17: Rango: anio_ingreso 1800 en Estudiante_Carrera
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Carrera SET anio_ingreso = 1800;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 17, @prueba = N'Rango: anio_ingreso 1800 en Estudiante_Carrera', @esperados = N'547', @patron = N'%anio_ingreso%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 17, @prueba = N'Rango: anio_ingreso 1800 en Estudiante_Carrera', @esperados = N'547', @patron = N'%anio_ingreso%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 18: Dominio: estado de postulacion inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Postulacion SET estado = N'INEXISTENTE';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 18, @prueba = N'Dominio: estado de postulacion inexistente', @esperados = N'547', @patron = N'%CK_Postulacion_Estado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 18, @prueba = N'Dominio: estado de postulacion inexistente', @esperados = N'547', @patron = N'%CK_Postulacion_Estado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 19: Dominio: estado de oferta inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET estado = N'INEXISTENTE' WHERE fecha_publicacion IS NOT NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 19, @prueba = N'Dominio: estado de oferta inexistente', @esperados = N'547', @patron = N'%CK_Oferta_Estado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 19, @prueba = N'Dominio: estado de oferta inexistente', @esperados = N'547', @patron = N'%CK_Oferta_Estado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 20: Dominio: estado de Estudiante_Carrera inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante_Carrera SET estado = N'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 20, @prueba = N'Dominio: estado de Estudiante_Carrera inexistente', @esperados = N'547', @patron = N'%Estado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 20, @prueba = N'Dominio: estado de Estudiante_Carrera inexistente', @esperados = N'547', @patron = N'%Estado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 21: Dominio: pertinencia 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta_Carrera SET pertinencia = N'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 21, @prueba = N'Dominio: pertinencia ''X''', @esperados = N'547', @patron = N'%pertinencia%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 21, @prueba = N'Dominio: pertinencia ''X''', @esperados = N'547', @patron = N'%pertinencia%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 22: Dominio: origen de postulacion 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Postulacion SET origen = N'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 22, @prueba = N'Dominio: origen de postulacion ''X''', @esperados = N'547', @patron = N'%origen%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 22, @prueba = N'Dominio: origen de postulacion ''X''', @esperados = N'547', @patron = N'%origen%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 23: Dominio: etapa de entrevista 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Entrevista SET etapa = N'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 23, @prueba = N'Dominio: etapa de entrevista ''X''', @esperados = N'547', @patron = N'%etapa%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 23, @prueba = N'Dominio: etapa de entrevista ''X''', @esperados = N'547', @patron = N'%etapa%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 24: Dominio: instancia de evaluacion 'X'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET instancia = N'X';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 24, @prueba = N'Dominio: instancia de evaluacion ''X''', @esperados = N'547', @patron = N'%instancia%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 24, @prueba = N'Dominio: instancia de evaluacion ''X''', @esperados = N'547', @patron = N'%instancia%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 25: Dominio: resultado de evaluacion 'PRUEBA'
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Evaluacion SET resultado = N'PRUEBA';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 25, @prueba = N'Dominio: resultado de evaluacion ''PRUEBA''', @esperados = N'547', @patron = N'%resultado%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 25, @prueba = N'Dominio: resultado de evaluacion ''PRUEBA''', @esperados = N'547', @patron = N'%resultado%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 26: Coherencia: practica FINALIZADA sin fecha_fin_real
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Practica SET estado = N'FINALIZADA', fecha_fin_real = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 26, @prueba = N'Coherencia: practica FINALIZADA sin fecha_fin_real', @esperados = N'547', @patron = N'%CK_Practica%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 26, @prueba = N'Coherencia: practica FINALIZADA sin fecha_fin_real', @esperados = N'547', @patron = N'%CK_Practica%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 27: Coherencia: oferta PUBLICADA sin fecha_publicacion
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET estado = N'PUBLICADA', fecha_publicacion = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 27, @prueba = N'Coherencia: oferta PUBLICADA sin fecha_publicacion', @esperados = N'547', @patron = N'%CK_Oferta%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 27, @prueba = N'Coherencia: oferta PUBLICADA sin fecha_publicacion', @esperados = N'547', @patron = N'%CK_Oferta%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 28: Dominio: estado_nuevo de Historial_Practica inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_practica FROM Practica);
    IF @p IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    INSERT INTO Historial_Practica (id_practica, estado_nuevo) VALUES (@p, N'INEXISTENTE');

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 28, @prueba = N'Dominio: estado_nuevo de Historial_Practica inexistente', @esperados = N'547', @patron = N'%Historial%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 28, @prueba = N'Dominio: estado_nuevo de Historial_Practica inexistente', @esperados = N'547', @patron = N'%Historial%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 29: NULL: titulo de oferta
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Oferta SET titulo = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 29, @prueba = N'NULL: titulo de oferta', @esperados = N'515', @patron = N'%titulo%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 29, @prueba = N'NULL: titulo de oferta', @esperados = N'515', @patron = N'%titulo%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 30: NULL: nombre de estudiante
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE TOP (1) Estudiante SET nombre = NULL;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 30, @prueba = N'NULL: nombre de estudiante', @esperados = N'515', @patron = N'%nombre%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 30, @prueba = N'NULL: nombre de estudiante', @esperados = N'515', @patron = N'%nombre%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 31: UQ: legajo repetido
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante (legajo, nombre, apellido, email)
    SELECT TOP (1) legajo, N'Prueba', N'Duplicado', N'prueba.duplicado@universidad.edu'
    FROM Estudiante;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 31, @prueba = N'UQ: legajo repetido', @esperados = N'2627,2601', @patron = N'%UQ_Estudiante_Legajo%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 31, @prueba = N'UQ: legajo repetido', @esperados = N'2627,2601', @patron = N'%UQ_Estudiante_Legajo%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 32: UQ: postulacion duplicada (estudiante, oferta)
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    SELECT TOP (1) id_estudiante, id_oferta, id_carrera, N'RECIBIDA', N'CV'
    FROM Postulacion;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 32, @prueba = N'UQ: postulacion duplicada (estudiante, oferta)', @esperados = N'2627,2601', @patron = N'%UQ_Postulacion_Estudiante_Oferta%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 32, @prueba = N'UQ: postulacion duplicada (estudiante, oferta)', @esperados = N'2627,2601', @patron = N'%UQ_Postulacion_Estudiante_Oferta%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 33: UQ: evaluacion repetida (practica, evaluador, instancia)
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Evaluacion (id_practica, tipo_evaluador, instancia, resultado)
    SELECT TOP (1) id_practica, tipo_evaluador, instancia, N'SATISFACTORIA'
    FROM Evaluacion;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 33, @prueba = N'UQ: evaluacion repetida (practica, evaluador, instancia)', @esperados = N'2627,2601', @patron = N'%UQ_Evaluacion%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 33, @prueba = N'UQ: evaluacion repetida (practica, evaluador, instancia)', @esperados = N'2627,2601', @patron = N'%UQ_Evaluacion%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 34: PK: Estudiante_Carrera repetida
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado)
    SELECT TOP (1) id_estudiante, id_carrera, anio_ingreso, estado
    FROM Estudiante_Carrera;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 34, @prueba = N'PK: Estudiante_Carrera repetida', @esperados = N'2627,2601', @patron = N'%Estudiante_Carrera%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 34, @prueba = N'PK: Estudiante_Carrera repetida', @esperados = N'2627,2601', @patron = N'%Estudiante_Carrera%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 35: FK: convenio de otra empresa en una oferta
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @o INT, @c INT;
    SELECT TOP (1) @o = o.id_oferta, @c = c.id_convenio
    FROM Oferta o
    INNER JOIN Convenio c ON c.id_empresa <> o.id_empresa;
    IF @o IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Oferta SET id_convenio = @c WHERE id_oferta = @o;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 35, @prueba = N'FK: convenio de otra empresa en una oferta', @esperados = N'547', @patron = N'%FK_Oferta_Convenio_Empresa%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 35, @prueba = N'FK: convenio de otra empresa en una oferta', @esperados = N'547', @patron = N'%FK_Oferta_Convenio_Empresa%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 36: FK: estudiante inexistente en Estudiante_Competencia
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Estudiante_Competencia (id_estudiante, id_competencia, nivel_declarado)
    SELECT (SELECT MAX(id_estudiante) + 1000 FROM Estudiante), MIN(id_competencia), 1
    FROM Competencia;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 36, @prueba = N'FK: estudiante inexistente en Estudiante_Competencia', @esperados = N'547', @patron = N'%FK_EstudianteCompetencia_Estudiante%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 36, @prueba = N'FK: estudiante inexistente en Estudiante_Competencia', @esperados = N'547', @patron = N'%FK_EstudianteCompetencia_Estudiante%', @num = @n, @msg = @m;
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
    IF @e IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    VALUES (@e, @o, @c, N'RECIBIDA', N'CV');

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 37, @prueba = N'FK compuesta: postulacion a carrera que el estudiante no cursa', @esperados = N'547', @patron = N'%Carrera%', @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 37, @prueba = N'FK compuesta: postulacion a carrera que el estudiante no cursa', @esperados = N'547', @patron = N'%Carrera%', @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 38: Proc: transicion ilegal RECHAZADA -> EN_REVISION
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_postulacion FROM Postulacion);
    IF @p IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = N'RECHAZADA' WHERE id_postulacion = @p;
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = N'EN_REVISION', @motivo = N'Prueba transicion ilegal';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 38, @prueba = N'Proc: transicion ilegal RECHAZADA -> EN_REVISION', @esperados = N'50003', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 38, @prueba = N'Proc: transicion ilegal RECHAZADA -> EN_REVISION', @esperados = N'50003', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 39: Proc: transicion ilegal RECIBIDA -> SELECCIONADA (salta etapas)
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_postulacion FROM Postulacion);
    IF @p IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = N'RECIBIDA' WHERE id_postulacion = @p;
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = N'SELECCIONADA', @motivo = N'Prueba salto de etapas';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 39, @prueba = N'Proc: transicion ilegal RECIBIDA -> SELECCIONADA (salta etapas)', @esperados = N'50003', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 39, @prueba = N'Proc: transicion ilegal RECIBIDA -> SELECCIONADA (salta etapas)', @esperados = N'50003', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 40: Proc: cambiar estado de postulacion inexistente
BEGIN TRY
    BEGIN TRANSACTION;

    EXEC usp_CambiarEstadoPostulacion @id_postulacion = -1, @estado_nuevo = N'EN_REVISION', @motivo = N'Prueba inexistente';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 40, @prueba = N'Proc: cambiar estado de postulacion inexistente', @esperados = N'50001', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 40, @prueba = N'Proc: cambiar estado de postulacion inexistente', @esperados = N'50001', @patron = NULL, @num = @n, @msg = @m;
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
    IF @e IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Oferta
    SET estado = N'PUBLICADA',
        fecha_publicacion = DATEADD(DAY, -30, CAST(GETDATE() AS date)),
        fecha_cierre = DATEADD(YEAR, 1, CAST(GETDATE() AS date))
    WHERE id_oferta = @o;
    EXEC usp_RegistrarPostulacion @id_estudiante = @e, @id_oferta = @o, @id_carrera = @c, @origen = N'PORTAL', @observaciones = N'Prueba carrera incorrecta';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 41, @prueba = N'Proc: postulacion a carrera que no corresponde al estudiante', @esperados = N'50005,547', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 41, @prueba = N'Proc: postulacion a carrera que no corresponde al estudiante', @esperados = N'50005,547', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 42: Proc: materia aprobada de una carrera que el estudiante no cursa
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @e INT, @mat INT, @hoy DATE = CAST(GETDATE() AS date);
    SELECT TOP (1) @e = e.id_estudiante, @mat = m.id_materia
    FROM Estudiante e CROSS JOIN Materia m
    WHERE NOT EXISTS (SELECT 1 FROM Estudiante_Carrera x WHERE x.id_estudiante = e.id_estudiante AND x.id_carrera = m.id_carrera);
    IF @e IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    EXEC usp_RegistrarMateriaAprobada @id_estudiante = @e, @id_materia = @mat, @fecha_aprobacion = @hoy;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 42, @prueba = N'Proc: materia aprobada de una carrera que el estudiante no cursa', @esperados = N'50005', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 42, @prueba = N'Proc: materia aprobada de una carrera que el estudiante no cursa', @esperados = N'50005', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 43: Proc: publicar oferta sin convenio
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @o INT;
    SELECT TOP (1) @o = o.id_oferta
    FROM Oferta o
    INNER JOIN Empresa em ON em.id_empresa = o.id_empresa
    WHERE em.estado_vinculo = N'ACTIVA'
      AND EXISTS (SELECT 1 FROM Oferta_Carrera oc WHERE oc.id_oferta = o.id_oferta)
      AND EXISTS (SELECT 1 FROM Oferta_Competencia oc WHERE oc.id_oferta = o.id_oferta);
    IF @o IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Oferta SET estado = N'BORRADOR', id_convenio = NULL WHERE id_oferta = @o;
    EXEC usp_PublicarOferta @id_oferta = @o;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 43, @prueba = N'Proc: publicar oferta sin convenio', @esperados = N'50006', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 43, @prueba = N'Proc: publicar oferta sin convenio', @esperados = N'50006', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 44: Proc: seleccionar sin vacantes
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT, @o INT, @c INT, @e INT;
    SELECT TOP (1) @p = id_postulacion, @o = id_oferta, @c = id_carrera FROM Postulacion;
    IF @p IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = N'ENTREVISTA' WHERE id_postulacion = @p;
    UPDATE Oferta SET vacantes = 1 WHERE id_oferta = @o;
    INSERT INTO Estudiante (legajo, nombre, apellido, email)
    VALUES (CONCAT(N'T-', LEFT(CONVERT(NVARCHAR(36), NEWID()), 8)), N'Prueba', N'Temporal',
            CONCAT(N'prueba.', LEFT(CONVERT(NVARCHAR(36), NEWID()), 8), N'@universidad.edu'));
    SET @e = SCOPE_IDENTITY();
    INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado) VALUES (@e, @c, 2024, N'ACTIVO');
    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    VALUES (@e, @o, @c, N'SELECCIONADA', N'PORTAL');
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = N'SELECCIONADA', @motivo = N'Prueba sin vacantes';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 44, @prueba = N'Proc: seleccionar sin vacantes', @esperados = N'50007', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 44, @prueba = N'Proc: seleccionar sin vacantes', @esperados = N'50007', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 45: Proc: cerrar practica sin evaluacion FINAL
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT, @f DATE;
    SELECT TOP (1) @p = id_practica, @f = fecha_inicio FROM Practica;
    IF @p IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Practica SET estado = N'EN_CURSO', fecha_fin_real = NULL WHERE id_practica = @p;
    DELETE FROM Evaluacion WHERE id_practica = @p AND instancia = N'FINAL';
    EXEC usp_CerrarPractica @id_practica = @p, @fecha_fin_real = @f, @motivo_cierre = N'Prueba sin evaluacion final';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 45, @prueba = N'Proc: cerrar practica sin evaluacion FINAL', @esperados = N'50009', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 45, @prueba = N'Proc: cerrar practica sin evaluacion FINAL', @esperados = N'50009', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 46: Proc: postulacion duplicada
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @e INT, @o INT, @c INT;
    SELECT TOP (1) @e = id_estudiante, @o = id_oferta, @c = id_carrera FROM Postulacion;
    IF @e IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Oferta
    SET estado = N'PUBLICADA',
        fecha_publicacion = DATEADD(DAY, -30, CAST(GETDATE() AS date)),
        fecha_cierre = DATEADD(YEAR, 1, CAST(GETDATE() AS date))
    WHERE id_oferta = @o;
    UPDATE Estudiante_Carrera SET estado = N'ACTIVO' WHERE id_estudiante = @e AND id_carrera = @c;
    EXEC usp_RegistrarPostulacion @id_estudiante = @e, @id_oferta = @o, @id_carrera = @c, @origen = N'PORTAL', @observaciones = N'Prueba duplicada';

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 46, @prueba = N'Proc: postulacion duplicada', @esperados = N'50010,2627', @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 46, @prueba = N'Proc: postulacion duplicada', @esperados = N'50010,2627', @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 47: Feliz: registrar postulacion y dejar historial
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @o INT, @c INT, @e INT, @p INT;
    SELECT TOP (1) @o = id_oferta, @c = id_carrera FROM Oferta_Carrera;
    IF @o IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Oferta
    SET estado = N'PUBLICADA',
        fecha_publicacion = DATEADD(DAY, -30, CAST(GETDATE() AS date)),
        fecha_cierre = DATEADD(YEAR, 1, CAST(GETDATE() AS date))
    WHERE id_oferta = @o;
    INSERT INTO Estudiante (legajo, nombre, apellido, email)
    VALUES (CONCAT(N'T-', LEFT(CONVERT(NVARCHAR(36), NEWID()), 8)), N'Prueba', N'Temporal',
            CONCAT(N'prueba.', LEFT(CONVERT(NVARCHAR(36), NEWID()), 8), N'@universidad.edu'));
    SET @e = SCOPE_IDENTITY();
    INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado)
    VALUES (@e, @c, 2024, N'ACTIVO');
    EXEC usp_RegistrarPostulacion @id_estudiante = @e, @id_oferta = @o, @id_carrera = @c, @origen = N'PORTAL', @observaciones = N'Prueba caso feliz';
    SELECT @p = id_postulacion FROM Postulacion WHERE id_estudiante = @e AND id_oferta = @o;
    IF @p IS NULL OR NOT EXISTS (SELECT 1 FROM Postulacion_Estado_Historial WHERE id_postulacion = @p AND estado_nuevo = N'RECIBIDA')
        THROW 59998, N'La postulacion o su historial no quedaron registrados.', 1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 47, @prueba = N'Feliz: registrar postulacion y dejar historial', @esperados = NULL, @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 47, @prueba = N'Feliz: registrar postulacion y dejar historial', @esperados = NULL, @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 48: Feliz: transicion legal RECIBIDA -> EN_REVISION
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT = (SELECT TOP (1) id_postulacion FROM Postulacion);
    IF @p IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Postulacion SET estado = N'RECIBIDA' WHERE id_postulacion = @p;
    DECLARE @antes INT = (SELECT COUNT(*) FROM Postulacion_Estado_Historial WHERE id_postulacion = @p);
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = @p, @estado_nuevo = N'EN_REVISION', @motivo = N'Prueba caso feliz';
    IF NOT EXISTS (SELECT 1 FROM Postulacion WHERE id_postulacion = @p AND estado = N'EN_REVISION')
       OR (SELECT COUNT(*) FROM Postulacion_Estado_Historial WHERE id_postulacion = @p) <> @antes + 1
        THROW 59998, N'El estado o el historial no se actualizaron.', 1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 48, @prueba = N'Feliz: transicion legal RECIBIDA -> EN_REVISION', @esperados = NULL, @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 48, @prueba = N'Feliz: transicion legal RECIBIDA -> EN_REVISION', @esperados = NULL, @patron = NULL, @num = @n, @msg = @m;
END CATCH;
GO

-- Prueba 49: Feliz: cerrar practica con seguimiento y evaluaciones FINAL
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @p INT, @f DATE;
    SELECT TOP (1) @p = id_practica, @f = fecha_inicio FROM Practica;
    IF @p IS NULL THROW 59999, N'Sin datos para armar la prueba.', 1;
    UPDATE Practica SET estado = N'EN_CURSO', fecha_fin_real = NULL WHERE id_practica = @p;
    DELETE FROM Evaluacion WHERE id_practica = @p AND instancia = N'FINAL';
    INSERT INTO Evaluacion (id_practica, tipo_evaluador, instancia, resultado)
    VALUES (@p, N'ESTUDIANTE', N'FINAL', N'SATISFACTORIA'), (@p, N'EMPRESA', N'FINAL', N'SATISFACTORIA');
    IF NOT EXISTS (SELECT 1 FROM Seguimiento WHERE id_practica = @p)
        INSERT INTO Seguimiento (id_practica, tipo_seguimiento, origen_feedback, estado_seguimiento, observaciones)
        VALUES (@p, N'CIERRE', N'AMBOS', N'SIN_NOVEDADES', N'Prueba caso feliz');
    EXEC usp_CerrarPractica @id_practica = @p, @fecha_fin_real = @f, @motivo_cierre = N'Prueba caso feliz';
    IF NOT EXISTS (SELECT 1 FROM Practica WHERE id_practica = @p AND estado = N'FINALIZADA' AND fecha_fin_real IS NOT NULL)
       OR NOT EXISTS (SELECT 1 FROM Historial_Practica WHERE id_practica = @p AND estado_nuevo = N'FINALIZADA')
        THROW 59998, N'La practica no quedo FINALIZADA con su historial.', 1;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 49, @prueba = N'Feliz: cerrar practica con seguimiento y evaluaciones FINAL', @esperados = NULL, @patron = NULL, @num = NULL, @msg = NULL;
END TRY
BEGIN CATCH
    DECLARE @n INT = ERROR_NUMBER(), @m NVARCHAR(4000) = ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    EXEC #Reg @id = 49, @prueba = N'Feliz: cerrar practica con seguimiento y evaluaciones FINAL', @esperados = NULL, @patron = NULL, @num = @n, @msg = @m;
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

SELECT id AS prueba, CASE WHEN ok = 1 THEN N'OK' ELSE N'FALLA' END AS resultado, prueba AS descripcion, detalle
FROM #Resultado
ORDER BY id;

DECLARE @total INT = (SELECT COUNT(*) FROM #Resultado),
        @ok INT = (SELECT COUNT(*) FROM #Resultado WHERE ok = 1);
PRINT CONCAT(N'Pruebas: ', @total, N' | OK: ', @ok, N' | FALLA: ', @total - @ok);
PRINT CONCAT(N'Transacciones abiertas: ', @pend, N' | Tablas con filas distintas a las iniciales: ', @dif,
             N' (ambos deben ser 0; los huecos de IDENTITY por el ROLLBACK son esperables)');

DROP TABLE #Resultado;
DROP TABLE #Conteo;
DROP PROCEDURE #Reg;
GO
