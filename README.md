# Nexo

Base de datos en Microsoft SQL Server para gestionar carreras, estudiantes, empresas, convenios, ofertas, postulaciones y prácticas profesionales.

## Contenido

- 18 tablas.
- 9 vistas.
- 1 función de compatibilidad.
- 13 procedimientos almacenados.
- 4 triggers de auditoría.
- 14 consultas de negocio.
- 6 pruebas de integridad.
- Un mínimo de 10 registros ficticios por tabla.

## Instalación

Ejecutar los archivos de la carpeta `sql` en este orden:

1. `00_crear_base.sql`
2. `01_estructura.sql`
3. `02_datos.sql`
4. `03_consultas.sql`
5. `04_pruebas_integridad.sql`

La instalación utiliza la base `NexoAcademico` y fue verificada en SQL Server Express.

Las instrucciones detalladas se encuentran en [INSTRUCCIONES_INSTALACION.md](INSTRUCCIONES_INSTALACION.md).

Las decisiones del modelo se encuentran en [MODELO_Y_CRITERIOS.md](MODELO_Y_CRITERIOS.md).
