/* ================================================================
   NexoAcademico - 04_pruebas_integridad.sql
   Intenta cargar datos incorrectos y comprueba que la base los rechaza
   (tipo de dato, CHECK, NULL, UNIQUE/PK, claves foráneas y reglas de los
   procedimientos). Al final hay algunos casos felices que deben funcionar.

   NO modifica datos: cada prueba va dentro de BEGIN TRANSACTION y termina
   con ROLLBACK, así la base queda igual que antes.

   Cómo leer la salida (una línea por prueba):
     OK - Prueba N: ...     la base hizo lo esperado (rechazó el dato malo
                            o aceptó el caso feliz). Si rechazó, muestra el motivo.
     FALLA - Prueba N: ...  la base NO hizo lo esperado.

   Los IDs fijos salen de 02_datos.sql, ejecutado sobre una base recién creada.
   ================================================================ */

USE NexoAcademico;
GO

SET NOCOUNT ON;
GO

/* ----------------------------------------------------------------
   1. TIPO DE DATO
   ---------------------------------------------------------------- */

-- Prueba 1: texto en un campo numérico (nivel_declarado es INT)
-- Resultado esperado: error de conversión, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- Estudiante 1 declara la competencia 1 (SQL), ver 02_datos.sql.
    UPDATE Estudiante_Competencia SET nivel_declarado = 'abc'
    WHERE id_estudiante = 1 AND id_competencia = 1;
    PRINT 'FALLA - Prueba 1: se aceptó el texto abc como nivel';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 1: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 2: texto en un campo decimal (puntaje_desempeno es DECIMAL(3,1))
-- Resultado esperado: error de conversión, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- Evaluacion 2: la hizo la empresa y tiene puntaje_desempeno.
    UPDATE Evaluacion SET puntaje_desempeno = 'alto' WHERE id_evaluacion = 2;
    PRINT 'FALLA - Prueba 2: se aceptó texto en un puntaje';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 2: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 3: texto que no es una fecha (fecha_cierre es DATE)
-- Resultado esperado: error de conversión, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Oferta SET fecha_cierre = 'no-es-una-fecha' WHERE id_oferta = 1;
    PRINT 'FALLA - Prueba 3: se aceptó un texto como fecha';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 3: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 4: número demasiado grande para DECIMAL(3,1) (máximo 99.9)
-- Resultado esperado: error de desbordamiento aritmético, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Evaluacion SET puntaje_desempeno = 100 WHERE id_evaluacion = 2;
    PRINT 'FALLA - Prueba 4: se aceptó el puntaje 100';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 4: ' + ERROR_MESSAGE();
END CATCH;
GO

/* ----------------------------------------------------------------
   2. RANGO Y COHERENCIA (restricciones CHECK)
   ---------------------------------------------------------------- */

-- Prueba 5: nivel_declarado fuera de rango (CK_EstudianteCompetencia_Nivel admite 1 a 3)
-- Resultado esperado: error, la fila no se inserta.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- El estudiante 1 todavía no declaró la competencia 5.
    INSERT INTO Estudiante_Competencia (id_estudiante, id_competencia, nivel_declarado)
    VALUES (1, 5, 4);
    PRINT 'FALLA - Prueba 5: se aceptó un nivel 4';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 5: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 6: nivel_requerido fuera de rango (CK_OfertaCompetencia_Nivel admite 1 a 3)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Oferta_Competencia SET nivel_requerido = 4
    WHERE id_oferta = 1 AND id_competencia = 1;
    PRINT 'FALLA - Prueba 6: se aceptó un nivel_requerido 4';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 6: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 7: puntaje_desempeno fuera de rango (CK_Evaluacion_Desempeno admite 1 a 5)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Evaluacion SET puntaje_desempeno = 6 WHERE id_evaluacion = 2;
    PRINT 'FALLA - Prueba 7: se aceptó un puntaje 6';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 7: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 8: horas_semanales fuera de rango (CK_Practica_Horas admite 1 a 48)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Practica SET horas_semanales = 60 WHERE id_practica = 1;
    PRINT 'FALLA - Prueba 8: se aceptaron 60 horas semanales';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 8: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 9: vacantes igual a 0 (CK_Oferta_Vacantes exige vacantes > 0)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Oferta SET vacantes = 0 WHERE id_oferta = 1;
    PRINT 'FALLA - Prueba 9: se aceptaron 0 vacantes';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 9: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 10: anio_ingreso fuera de rango (CK_EstudianteCarrera_Anio admite 1900 a 2100)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Estudiante_Carrera SET anio_ingreso = 1800
    WHERE id_estudiante = 1 AND id_carrera = 1;
    PRINT 'FALLA - Prueba 10: se aceptó el año 1800';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 10: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 11: práctica FINALIZADA sin fecha_fin_real (CK_Practica_FinReal)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La práctica 1 está EN_CURSO y su fecha_fin_real es NULL.
    UPDATE Practica SET estado = 'FINALIZADA' WHERE id_practica = 1;
    PRINT 'FALLA - Prueba 11: se aceptó una práctica FINALIZADA sin fecha de fin';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 11: ' + ERROR_MESSAGE();
END CATCH;
GO

/* ----------------------------------------------------------------
   3. DOMINIO (valores permitidos)
   ---------------------------------------------------------------- */

-- Prueba 12: estado de postulación inexistente (CK_Postulacion_Estado)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Postulacion SET estado = 'INEXISTENTE' WHERE id_postulacion = 1;
    PRINT 'FALLA - Prueba 12: se aceptó un estado inexistente';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 12: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 13: estado de oferta inexistente (CK_Oferta_Estado)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Oferta SET estado = 'INEXISTENTE' WHERE id_oferta = 1;
    PRINT 'FALLA - Prueba 13: se aceptó un estado inexistente';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 13: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 14: pertinencia fuera de ALTA, MEDIA o BAJA (CK_OfertaCarrera_Pertinencia)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Oferta_Carrera SET pertinencia = 'X'
    WHERE id_oferta = 1 AND id_carrera = 1;
    PRINT 'FALLA - Prueba 14: se aceptó la pertinencia X';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 14: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 15: origen de postulación inválido (CK_Postulacion_Origen)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Postulacion SET origen = 'X' WHERE id_postulacion = 1;
    PRINT 'FALLA - Prueba 15: se aceptó el origen X';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 15: ' + ERROR_MESSAGE();
END CATCH;
GO

/* ----------------------------------------------------------------
   4. NULL EN COLUMNAS OBLIGATORIAS (NOT NULL)
   ---------------------------------------------------------------- */

-- Prueba 16: titulo de oferta en NULL
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Oferta SET titulo = NULL WHERE id_oferta = 1;
    PRINT 'FALLA - Prueba 16: se aceptó un título NULL';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 16: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 17: nombre de estudiante en NULL
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    UPDATE Estudiante SET nombre = NULL WHERE id_estudiante = 1;
    PRINT 'FALLA - Prueba 17: se aceptó un nombre NULL';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 17: ' + ERROR_MESSAGE();
END CATCH;
GO

/* ----------------------------------------------------------------
   5. UNICIDAD (UNIQUE y PRIMARY KEY)
   ---------------------------------------------------------------- */

-- Prueba 18: legajo repetido (UQ_Estudiante_Legajo)
-- Resultado esperado: error, la fila no se inserta.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- El legajo 10001 ya es de Ana (estudiante 1).
    INSERT INTO Estudiante (legajo, nombre, apellido, email)
    VALUES ('10001', 'Prueba', 'Repetido', 'prueba.repetido@ejemplo.edu');
    PRINT 'FALLA - Prueba 18: se aceptó un legajo repetido';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 18: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 19: postulación repetida del mismo estudiante a la misma oferta (UQ_Postulacion_Estudiante_Oferta)
-- Resultado esperado: error, la fila no se inserta.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- El estudiante 1 ya se postuló a la oferta 1 (postulación 1).
    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    VALUES (1, 1, 1, 'RECIBIDA', 'CV');
    PRINT 'FALLA - Prueba 19: se aceptó una postulación repetida';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 19: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 20: clave primaria repetida en Estudiante_Carrera (PK_Estudiante_Carrera)
-- Resultado esperado: error, la fila no se inserta.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- El estudiante 1 ya cursa la carrera 1.
    INSERT INTO Estudiante_Carrera (id_estudiante, id_carrera, anio_ingreso, estado)
    VALUES (1, 1, 2024, 'ACTIVO');
    PRINT 'FALLA - Prueba 20: se aceptó una clave primaria repetida';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 20: ' + ERROR_MESSAGE();
END CATCH;
GO

/* ----------------------------------------------------------------
   6. CLAVES FORÁNEAS
   ---------------------------------------------------------------- */

-- Prueba 21: estudiante inexistente (FK_EstudianteCompetencia_Estudiante)
-- Resultado esperado: error, la fila no se inserta.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- No existe el estudiante 9999.
    INSERT INTO Estudiante_Competencia (id_estudiante, id_competencia, nivel_declarado)
    VALUES (9999, 1, 1);
    PRINT 'FALLA - Prueba 21: se aceptó un estudiante inexistente';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 21: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 22: convenio de otra empresa en una oferta (FK_Oferta_Convenio_Empresa)
-- Resultado esperado: error, la fila no se modifica.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La oferta 1 es de la empresa 1 y el convenio 2 es de la empresa 2.
    UPDATE Oferta SET id_convenio = 2 WHERE id_oferta = 1;
    PRINT 'FALLA - Prueba 22: se aceptó el convenio de otra empresa';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 22: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 23: postulación a una carrera que el estudiante no cursa (FK_Postulacion_EstudianteCarrera)
-- Resultado esperado: error, la fila no se inserta.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- El estudiante 1 no cursa la carrera 3; la oferta 3 sí está dirigida a ella.
    INSERT INTO Postulacion (id_estudiante, id_oferta, id_carrera, estado, origen)
    VALUES (1, 3, 3, 'RECIBIDA', 'CV');
    PRINT 'FALLA - Prueba 23: se aceptó una carrera que el estudiante no cursa';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 23: ' + ERROR_MESSAGE();
END CATCH;
GO

/* ----------------------------------------------------------------
   7. REGLAS DE LOS PROCEDIMIENTOS (errores THROW 50001 a 50011)
   ---------------------------------------------------------------- */

-- Prueba 24: transición ilegal de estado: RECHAZADA -> EN_REVISION (error 50003)
-- Resultado esperado: error, la postulación no cambia.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La postulación 12 está RECHAZADA.
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = 12, @estado_nuevo = 'EN_REVISION', @motivo = 'Prueba';
    PRINT 'FALLA - Prueba 24: se permitió la transición';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 24: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 25: transición ilegal de estado: RECIBIDA -> SELECCIONADA, salta etapas (error 50003)
-- Resultado esperado: error, la postulación no cambia.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La postulación 16 está RECIBIDA.
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = 16, @estado_nuevo = 'SELECCIONADA', @motivo = 'Prueba';
    PRINT 'FALLA - Prueba 25: se permitió la transición';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 25: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 26: postulación a una carrera que no corresponde al estudiante (error 50005)
-- Resultado esperado: error, no se crea la postulación.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- El estudiante 1 cursa las carreras 1 y 2, no la 3.
    EXEC usp_RegistrarPostulacion @id_estudiante = 1, @id_oferta = 1, @id_carrera = 3,
        @origen = 'PORTAL', @observaciones = 'Prueba';
    PRINT 'FALLA - Prueba 26: se permitió una carrera que no corresponde';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 26: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 27: publicar una oferta sin convenio vigente (error 50006)
-- Resultado esperado: error, la oferta sigue en BORRADOR.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La oferta 12 es un BORRADOR de una empresa ACTIVA; le quitamos el convenio.
    UPDATE Oferta SET id_convenio = NULL WHERE id_oferta = 12;
    EXEC usp_PublicarOferta @id_oferta = 12;
    PRINT 'FALLA - Prueba 27: se publicó una oferta sin convenio';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 27: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 28: seleccionar una postulación sin vacantes (error 50007)
-- Resultado esperado: error, la postulación no queda SELECCIONADA.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La oferta 10 ya tiene 1 seleccionado (postulación 10); la dejamos con 1 vacante.
    -- La postulación 14 es de la oferta 10 y está en ENTREVISTA.
    UPDATE Oferta SET vacantes = 1 WHERE id_oferta = 10;
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = 14, @estado_nuevo = 'SELECCIONADA', @motivo = 'Prueba';
    PRINT 'FALLA - Prueba 28: se seleccionó sin vacantes';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 28: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 29: cerrar una práctica sin evaluación FINAL (error 50009)
-- Resultado esperado: error, la práctica sigue EN_CURSO.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La práctica 1 está EN_CURSO y solo tiene evaluaciones PARCIAL.
    EXEC usp_CerrarPractica @id_practica = 1, @fecha_fin_real = '2027-01-15', @motivo_cierre = 'Prueba';
    PRINT 'FALLA - Prueba 29: se cerró una práctica sin evaluación FINAL';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'OK - Prueba 29: ' + ERROR_MESSAGE();
END CATCH;
GO

/* ----------------------------------------------------------------
   8. CASOS FELICES (deben funcionar)
   ---------------------------------------------------------------- */

-- Prueba 30: registrar una postulación válida
-- Resultado esperado: se ejecuta sin error y el dato queda como se pide.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- El estudiante 4 está ACTIVO en la carrera 5 y la oferta 10 (PUBLICADA) está dirigida a ella.
    EXEC usp_RegistrarPostulacion @id_estudiante = 4, @id_oferta = 10, @id_carrera = 5,
        @origen = 'PORTAL', @observaciones = 'Prueba';
    IF EXISTS (
    SELECT 1 FROM Postulacion WHERE id_estudiante = 4 AND id_oferta = 10 AND estado = 'RECIBIDA'
    )
        PRINT 'OK - Prueba 30: registrar una postulación válida';
    ELSE
        PRINT 'FALLA - Prueba 30: la postulación no quedó registrada';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'FALLA - Prueba 30: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 31: transición legal RECIBIDA -> EN_REVISION
-- Resultado esperado: se ejecuta sin error y el dato queda como se pide.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La postulación 16 está RECIBIDA.
    EXEC usp_CambiarEstadoPostulacion @id_postulacion = 16, @estado_nuevo = 'EN_REVISION', @motivo = 'Prueba';
    IF EXISTS (
    SELECT 1 FROM Postulacion WHERE id_postulacion = 16 AND estado = 'EN_REVISION'
    )
        PRINT 'OK - Prueba 31: transición legal RECIBIDA -> EN_REVISION';
    ELSE
        PRINT 'FALLA - Prueba 31: la postulación no pasó a EN_REVISION';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'FALLA - Prueba 31: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prueba 32: cerrar una práctica que tiene las evaluaciones FINAL
-- Resultado esperado: se ejecuta sin error y el dato queda como se pide.
BEGIN TRY
    -- El ROLLBACK deja los datos como estaban.
    BEGIN TRANSACTION;
    -- La práctica 1 ya tiene seguimientos; le cargamos las dos evaluaciones FINAL.
    INSERT INTO Evaluacion (id_practica, tipo_evaluador, instancia, resultado)
    VALUES (1, 'ESTUDIANTE', 'FINAL', 'SATISFACTORIA'),
           (1, 'EMPRESA', 'FINAL', 'SATISFACTORIA');
    EXEC usp_CerrarPractica @id_practica = 1, @fecha_fin_real = '2027-01-15', @motivo_cierre = 'Prueba';
    IF EXISTS (
    SELECT 1 FROM Practica WHERE id_practica = 1 AND estado = 'FINALIZADA'
    )
        PRINT 'OK - Prueba 32: cerrar una práctica que tiene las evaluaciones FINAL';
    ELSE
        PRINT 'FALLA - Prueba 32: la práctica no quedó FINALIZADA';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'FALLA - Prueba 32: ' + ERROR_MESSAGE();
END CATCH;
GO
