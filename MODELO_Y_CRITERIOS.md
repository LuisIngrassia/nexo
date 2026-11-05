# Nexo SQL Server

## Orden de ejecución

1. Ejecutar `00_crear_base.sql` para crear y seleccionar la base de datos.
2. Ejecutar `01_estructura.sql` para crear tablas, restricciones, vistas, función, procedimientos, triggers e índices.
3. Ejecutar `02_datos.sql` para cargar los datos ficticios de la entrega.
4. Ejecutar `03_consultas.sql` para obtener los resultados del proyecto.
5. Ejecutar `04_pruebas_integridad.sql` para comprobar las restricciones principales.

## Criterios del modelo

- Las competencias y sus niveles provienen del CV del estudiante.
- La universidad no valida ni certifica los niveles declarados.
- Los niveles de competencia son 1 básico, 2 intermedio y 3 avanzado.
- El matching es orientativo y no rechaza automáticamente postulaciones.
- El avance académico se calcula mediante materias aprobadas.
- Una oferta puede relacionarse con una o varias carreras mediante `Oferta_Carrera`.
- Una oferta solo puede usar un convenio perteneciente a la misma empresa.
- La función `fn_PorcentajeCompatibilidad` calcula el porcentaje orientativo entre un estudiante y una oferta.
- El procedimiento `usp_InterrumpirPractica` registra una interrupción con fecha y motivo.
- El seguimiento registra la situación general de la práctica, sin controlar tareas internas de la empresa.

Las consultas producen información sobre oportunidades por carrera, resultados por empresa y carrera, brechas de competencias, estados de postulación, motivos de rechazo o retiro y prácticas que requieren intervención.
