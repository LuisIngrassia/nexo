# Instrucciones de instalación de Nexo

## Requisitos

- Microsoft SQL Server.
- SQL Server Management Studio.
- Una conexión con permiso para crear bases de datos.
- Los archivos de la carpeta `sql`.

## Conexión

1. Abrir SQL Server Management Studio.
2. En Nombre del servidor escribir `.\SQLEXPRESS`.
3. Seleccionar Autenticación de Windows.
4. Presionar Conectar.

## Instalación

Para cada archivo de la carpeta `sql`, en este orden:

1. Presionar `Ctrl + O` y abrir el archivo.
2. Verificar que la base seleccionada sea `NexoAcademico` (salvo en `00`, que la crea).
3. Ejecutar con `F5`.

| Archivo | Qué hace |
|---|---|
| `00_crear_base.sql` | Crea la base `NexoAcademico`. |
| `01_estructura.sql` | Crea tablas, restricciones, vistas, función, procedimientos, triggers e índices. |
| `02_datos.sql` | Carga los datos ficticios. Se ejecuta una sola vez. |
| `03_consultas.sql` | Ejecuta las 20 consultas de negocio. |
| `04_pruebas_integridad.sql` | Ejecuta 26 pruebas; se esperan 26 líneas `OK -`. No modifica los datos. |

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

- 20 tablas.
- 9 vistas.
- 14 procedimientos.
- 2 triggers.
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

## Base existente

Si `NexoAcademico` ya aparece en SQL Server, no ejecutar nuevamente `00`, `01` y `02`. Para revisar la instalación existente, ejecutar solamente las consultas y las pruebas.

No eliminar ni reemplazar una base existente sin realizar antes una copia de seguridad o confirmar que sus datos pueden descartarse.
