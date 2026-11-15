# Nexo SQL Server

## Orden de ejecución

1. Ejecutar `00_crear_base.sql` para crear y seleccionar la base de datos.
2. Ejecutar `01_estructura.sql` para crear tablas, restricciones, vistas, función, procedimientos, triggers e índices.
3. Ejecutar `02_datos.sql` para cargar los datos ficticios de la entrega.
4. Verificar que la base activa sea `NexoAcademico` (`SELECT DB_NAME();`).
5. Ejecutar `03_consultas.sql` para obtener los resultados del proyecto.
6. Ejecutar `04_pruebas_integridad.sql` para comprobar restricciones y reglas de los procedimientos.

## Entidades

- `Estudiante_Carrera`: un estudiante puede cursar varias carreras; guarda `anio_ingreso` y `estado` (ACTIVO, EGRESADO, INACTIVO) por carrera.
- `Oferta_Carrera`: relaciona oferta y carrera e incluye `pertinencia` (ALTA, MEDIA, BAJA) con su `criterio_pertinencia`.
- `Postulacion`: guarda `id_carrera`; las claves foráneas compuestas exigen que el estudiante pertenezca a esa carrera y que la oferta esté dirigida a ella.
- `Postulacion_Estado_Historial` e `Historial_Practica`: trazabilidad de estados, con motivo y `usuario` (`ORIGINAL_LOGIN()`). Los motivos de rechazo son texto libre.
- `Evaluacion`: tiene `instancia` (PARCIAL o FINAL); hay una evaluación por práctica, evaluador e instancia.

## Criterios del modelo

- Las competencias y sus niveles son declarados por el estudiante en su CV; la universidad no los valida ni certifica.
- Los niveles de competencia son 1 básico, 2 intermedio y 3 avanzado.
- El matching es dinámico y orientativo: no se guarda, no rechaza postulaciones y `fn_PorcentajeCompatibilidad` no excluye por competencias obligatorias.
- El avance académico se calcula por estudiante y carrera mediante materias aprobadas.
- Una oferta solo puede usar un convenio de su misma empresa.
- La pertinencia (ALTA, MEDIA, BAJA) indica qué tan adecuada es una oferta para cada carrera.
- El seguimiento registra la situación general de la práctica, sin controlar tareas internas de la empresa.

## Reglas que aplican los procedimientos

Los procedimientos usan `THROW` con estos códigos: 50001 entidad inexistente, 50002 estado no válido, 50003 transición no permitida, 50004 conflicto de concurrencia, 50005 la carrera no corresponde, 50006 convenio no vigente, 50007 sin vacantes, 50008 fechas incoherentes, 50009 faltan requisitos de cierre, 50010 duplicado.

- Publicar una oferta exige convenio VIGENTE y al menos una carrera asociada.
- Postularse exige estar ACTIVO en la carrera indicada.
- Pasar una postulación a SELECCIONADA controla las vacantes; las transiciones de estado siguen una máquina de estados.
- Crear una práctica exige estudiante ACTIVO en la carrera, que termine dentro del convenio y que no tenga otra práctica activa.
- Cerrar una práctica exige fecha de fin real y evaluaciones FINAL de estudiante y empresa.
- Registrar una materia aprobada exige que la materia sea de una carrera del estudiante.

## Limitaciones conocidas

- Los huecos en los valores IDENTITY que dejan las pruebas con ROLLBACK son inherentes a SQL Server y no afectan los datos.

Las consultas producen información sobre oportunidades por carrera, resultados por empresa y carrera, brechas de competencias, rankings, vacantes por pertinencia, tiempos entre etapas, motivos de rechazo o retiro, prácticas que requieren intervención y revisiones vencidas.
