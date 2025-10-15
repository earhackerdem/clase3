Genera un reporte completo de las actividades del equipo durante la semana laboral (lunes a viernes).

## Flujo de trabajo:

1. **Calcular el rango de fechas**
   - Identifica el lunes y viernes de la semana actual
   - Si hoy es fin de semana, usa la semana pasada
   - Formato: De {Fecha Inicio} a {Fecha Fin}

2. **Buscar tareas de la semana**
   - Usa JQL: `updated >= startOfWeek() AND updated <= endOfWeek() AND project = {PROJECT_KEY}`
   - Obtén todas las tareas que tuvieron actividad en la semana

3. **Agrupar información por:**
   - **Tareas completadas:** Transicionaron a "Done" o "Completada" en la semana
   - **Tareas iniciadas:** Cambiaron de "Por hacer" a otro estado
   - **Tareas en progreso:** Siguen activas al final de la semana
   - **Personas activas:** Usuarios que actualizaron/trabajaron en tareas

4. **Calcular métricas:**
   - Total de tareas completadas
   - Total de story points completados (si está disponible)
   - Distribución de tareas por persona
   - Tareas creadas vs tareas completadas
   - Promedio de tiempo de resolución

5. **Generar reporte**

## Formato del reporte:

```markdown
# 📊 Reporte Semanal - Semana del {Fecha Inicio} al {Fecha Fin}

## 📈 Resumen Ejecutivo

- **Tareas completadas:** X
- **Story points completados:** Y
- **Tareas iniciadas:** Z
- **Personas activas:** W
- **Tareas creadas esta semana:** N
- **Promedio de tiempo de resolución:** M días

---

## ✅ Tareas Completadas

### Alto Impacto / Alta Prioridad
- **[SCRUM-1]** Título de la tarea
  - Asignado: {Persona}
  - Tipo: Story/Task/Bug
  - Story Points: X (si aplica)

### Otras Tareas
- **[SCRUM-2]** Título
  - Asignado: {Persona}
  - Tipo: Task

---

## 🔄 Tareas en Progreso

- **[SCRUM-3]** Título
  - Asignado: {Persona}
  - Estado: En progreso
  - Días en progreso: X

---

## 🆕 Tareas Iniciadas esta Semana

- **[SCRUM-4]** Título
  - Asignado: {Persona}
  - Fecha de inicio: {Fecha}

---

## 👥 Contribución por Persona

### {Nombre Persona 1}
- Tareas completadas: X
- Story points: Y
- Tareas activas: Z

### {Nombre Persona 2}
- Tareas completadas: X
- Story points: Y
- Tareas activas: Z

---

## 📊 Métricas de Productividad

### Distribución por Tipo
- Stories: X
- Tasks: Y
- Bugs: Z

### Distribución por Prioridad
- High: X
- Medium: Y
- Low: Z

### Velocidad del Equipo
- Story points completados: X
- Promedio por día: Y

---

## 🎯 Estado del Backlog

- Tareas en "Por hacer": X
- Tareas en "En progreso": Y
- Tareas en "En revisión": Z
- Tareas "Bloqueadas": W

---

## 💡 Observaciones

[Agrega aquí notas automáticas basadas en los datos:]
- Si hay muchas tareas bloqueadas, mencionarlo
- Si hay tareas sin actualizar por más de 3 días
- Si alguien tiene sobrecarga de trabajo (muchas tareas asignadas)
- Si hay aumento/disminución significativa en velocity
```

## Opciones adicionales:

- **Incluir gráficos de tendencia:** Comparar con semanas anteriores
- **Resaltar bloqueadores:** Tareas que estuvieron bloqueadas en la semana
- **Sugerencias:** Basadas en patrones detectados

## Formato de salida:

- Por defecto: Markdown formateado
- Opcional: Tabla resumen al principio
- Opcional: Exportar a PDF o enviar por email

