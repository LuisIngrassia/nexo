# Nexo SQL Server

## Entidades

- `Estudiante_Carrera`: carreras que cursa cada estudiante, con `anio_ingreso` y `estado` (ACTIVO, EGRESADO, INACTIVO).
- `Oferta_Carrera`: relaciona oferta y carrera e incluye `pertinencia` (ALTA, MEDIA, BAJA) con su `criterio_pertinencia`.
- `Postulacion`: indica la carrera por la que se postula; las claves foráneas compuestas exigen que el estudiante curse esa carrera y que la oferta esté dirigida a ella.
- `Postulacion_Estado_Historial` e `Historial_Practica`: trazabilidad de estados, con motivo y `usuario` (`ORIGINAL_LOGIN()`). Los motivos de rechazo son texto libre.
- `Evaluacion`: una por práctica, evaluador e instancia (PARCIAL o FINAL).

## Criterios del modelo

- Las competencias y sus niveles son declarados por el estudiante en su CV; la universidad no los valida ni certifica.
- Los niveles de competencia son 1 básico, 2 intermedio y 3 avanzado.
- El matching es dinámico y orientativo: no se guarda, no rechaza postulaciones y `fn_PorcentajeCompatibilidad` no excluye por competencias obligatorias.
- El avance académico se calcula por estudiante y carrera mediante materias aprobadas.
- Una oferta solo puede usar un convenio de su misma empresa.
- La pertinencia (ALTA, MEDIA, BAJA) indica qué tan adecuada es una oferta para cada carrera.
- El seguimiento registra la situación general de la práctica, sin controlar tareas internas de la empresa.

## Reglas que aplican los procedimientos

Los procedimientos controlan las reglas antes de guardar: si una no se cumple, muestran el motivo con `PRINT` y terminan con `RETURN`, sin guardar nada.

- Publicar una oferta exige convenio VIGENTE y al menos una carrera asociada.
- Postularse exige estar ACTIVO en la carrera indicada.
- Pasar una postulación a SELECCIONADA controla las vacantes; las transiciones de estado siguen una máquina de estados.
- Crear una práctica exige estudiante ACTIVO en la carrera, que termine dentro del convenio y que no tenga otra práctica activa.
- Cerrar una práctica exige fecha de fin real y evaluaciones FINAL de estudiante y empresa.
- Registrar una materia aprobada exige que la materia sea de una carrera del estudiante.

Las consultas producen información sobre oportunidades por carrera, resultados por empresa y carrera, brechas de competencias, rankings, vacantes por pertinencia, tiempos entre etapas, motivos de rechazo o retiro, prácticas que requieren intervención y revisiones vencidas.
