# Scripts de Monitoreo y Utilidades

Este directorio contiene scripts útiles para monitoreo y mantenimiento del proyecto.

## mysql-monitor.sh

Script completo de monitoreo de MySQL que proporciona análisis de rendimiento, slow queries, y estadísticas de conexiones.

### Uso

```bash
# Ejecutar todos los reportes
./scripts/mysql-monitor.sh all

# O usar el comando Make
make mysql-monitor

# Opciones individuales
./scripts/mysql-monitor.sh slow      # Ver slow query log
./scripts/mysql-monitor.sh perf      # Análisis de performance
./scripts/mysql-monitor.sh conn      # Estadísticas de conexiones
./scripts/mysql-monitor.sh tables    # Estadísticas de tablas
./scripts/mysql-monitor.sh innodb    # Estadísticas de InnoDB
./scripts/mysql-monitor.sh noindex   # Queries sin índices
./scripts/mysql-monitor.sh help      # Mostrar ayuda
```

### Características

- **Slow Query Log**: Muestra las últimas 50 entradas del log de queries lentas (>1 segundo)
- **Performance Analysis**: Top 10 queries más lentas usando Performance Schema
- **Queries sin Índices**: Detecta queries que no usan índices o usan índices ineficientes
- **Connection Stats**: Estadísticas de conexiones activas y totales
- **Table Statistics**: Tamaño de tablas, número de filas, y uso de espacio
- **InnoDB Buffer Pool**: Estadísticas del buffer pool de InnoDB

### Requisitos

- Docker y Docker Compose configurados
- Contenedor MySQL en ejecución
- Performance Schema habilitado (ya está configurado en `docker/development/mysql/my.cnf`)

### Salida con Colores

El script utiliza códigos de color ANSI para mejor legibilidad:
- 🔵 Azul: Encabezados de secciones
- 🟢 Verde: Mensajes de éxito
- 🟡 Amarillo: Advertencias
- 🔴 Rojo: Errores

### Integración con Makefile

El script está integrado con el Makefile del proyecto:

```bash
make mysql-monitor     # Ejecuta el análisis completo
make mysql-slow        # Solo slow query log (comando básico)
make mysql-perf        # Solo performance stats (comando básico)
```

## Agregar Nuevos Scripts

Para agregar nuevos scripts de utilidad:

1. Crea el script en este directorio
2. Hazlo ejecutable: `chmod +x scripts/tu-script.sh`
3. Documenta su uso en este README
4. (Opcional) Agrega un comando Make en el Makefile para facilitar su ejecución
