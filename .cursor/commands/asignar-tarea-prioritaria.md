Obtiene y asigna automáticamente la tarea de mayor prioridad que esté disponible.

## Flujo de trabajo:

1. **Buscar tarea prioritaria**
   - Busca tareas en estado "Por hacer" sin asignar
   - Ordena por prioridad (Highest, High, Medium, Low, Lowest)
   - Obtiene la tarea con mayor prioridad

2. **Obtener información del usuario actual**
   - Usa el MCP de Atlassian para obtener tu account ID

3. **Asignar la tarea**
   - Asigna la tarea a tu usuario
   - Cambia el estado de "Por hacer" a "En progreso"

4. **Crear rama de Git**
   - Crea una rama siguiendo la convención: `feature/{ISSUE-KEY}-descripcion-corta`
   - Usa el título de la tarea para generar la descripción
   - Sanitiza el nombre (minúsculas, guiones, sin caracteres especiales)

5. **Mostrar resumen**
   - Muestra el issue key de la tarea asignada
   - Muestra el título y descripción
   - Muestra la prioridad
   - Muestra el nombre de la rama creada
   - Si hay Historia de Usuario, Objetivos y Criterios de Aceptación, muéstralos

6. **Agregar comentario en Jira**
   - Agrega un comentario indicando:
     - Que te asignaste la tarea
     - Que cambiaste el estado a "En progreso"
     - El nombre de la rama creada

## Ejemplo de comentario:

```
🚀 Tarea asignada y en progreso

He tomado esta tarea y la he movido a "En progreso".

🌿 Rama creada: `feature/SCRUM-5-actualizar-tareas`

Comenzaré a trabajar en esto ahora.
```

## Manejo de errores:

- Si no hay tareas disponibles para asignar, informa al usuario
- Si no se puede crear la rama (ya existe), informa y sugiere nombre alternativo
- Si falla la transición de estado, informa el error

