# Instrucciones de instalación de Nexo

## Requisitos

- Microsoft SQL Server.
- SQL Server Management Studio.
- Una conexión con permiso para crear bases de datos.
- Los archivos de la carpeta `output\sql`.

## Conexión

1. Abrir SQL Server Management Studio.
2. En Nombre del servidor escribir `.\SQLEXPRESS`.
3. Seleccionar Autenticación de Windows.
4. Presionar Conectar.

## Instalación

### Paso 1 Crear la base

1. Presionar `Ctrl + O`.
2. Abrir `00_crear_base.sql`.
3. Ejecutar con `F5`.

Este archivo crea y selecciona la base `NexoAcademico`. Si la base ya existe, no volver a ejecutarlo.

### Paso 2 Crear la estructura

1. Presionar `Ctrl + O`.
2. Abrir `01_estructura.sql`.
3. Verificar que la base seleccionada sea `NexoAcademico`.
4. Ejecutar con `F5`.

Este archivo crea las tablas, restricciones, vistas, función, procedimientos, triggers e índices.

### Paso 3 Cargar los datos

1. Presionar `Ctrl + O`.
2. Abrir `02_datos.sql`.
3. Verificar que la base seleccionada sea `NexoAcademico`.
4. Ejecutar con `F5`.

Este archivo debe ejecutarse una sola vez. Volver a ejecutarlo produciría registros duplicados.

### Paso 4 Ejecutar las consultas

1. Presionar `Ctrl + O`.
2. Abrir `03_consultas.sql`.
3. Ejecutar con `F5`.

Las consultas muestran oportunidades por carrera, competencias solicitadas, estados de postulación, prácticas activas, resultados y brechas de competencias.

### Paso 5 Ejecutar las pruebas

1. Presionar `Ctrl + O`.
2. Abrir `04_pruebas_integridad.sql`.
3. Ejecutar con `F5`.

El resultado esperado son seis mensajes que comienzan con `CORRECTO`. Las pruebas revierten sus cambios y no modifican los datos instalados.

## Verificación

Ejecutar en una consulta nueva:

```sql
USE NexoAcademico;
GO

SELECT
    (SELECT COUNT(*) FROM sys.tables) AS tablas,
    (SELECT COUNT(*) FROM sys.views) AS vistas,
    (SELECT COUNT(*) FROM sys.procedures) AS procedimientos,
    (SELECT COUNT(*) FROM sys.triggers WHERE parent_class = 1) AS triggers,
    (SELECT COUNT(*) FROM sys.objects WHERE type = 'FN') AS funciones;
```

El resultado esperado es:

- 18 tablas.
- 9 vistas.
- 13 procedimientos.
- 4 triggers.
- 1 función.

Para verificar la cantidad de registros:

```sql
SELECT
    t.name AS tabla,
    SUM(p.rows) AS cantidad_registros
FROM sys.tables t
INNER JOIN sys.partitions p
    ON p.object_id = t.object_id
   AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
```

Cada tabla debe tener al menos 10 registros.

## Archivos

1. `00_crear_base.sql`: crea la base.
2. `01_estructura.sql`: crea la estructura.
3. `02_datos.sql`: carga los datos ficticios.
4. `03_consultas.sql`: ejecuta las consultas del proyecto.
5. `04_pruebas_integridad.sql`: comprueba las restricciones.

## Base existente

Si `NexoAcademico` ya aparece en SQL Server, no ejecutar nuevamente los pasos 1, 2 y 3. Para revisar la instalación existente, ejecutar solamente las consultas y las pruebas.

No eliminar ni reemplazar una base existente sin realizar antes una copia de seguridad o confirmar que sus datos pueden descartarse.
