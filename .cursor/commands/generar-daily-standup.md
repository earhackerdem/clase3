Genera un resumen de las actividades del equipo en las últimas 24 horas, ideal para daily standup meetings.

## Flujo de trabajo:

1. **Buscar tareas actualizadas recientemente**
   - Usa JQL: `updated >= -24h AND project = {PROJECT_KEY}`
   - Ordena por fecha de actualización (más recientes primero)
   - Obtén hasta 50 tareas

2. **Agrupar por persona**
   - Agrupa las tareas por asignado
   - Para cada persona, lista:
     - Tareas completadas (cambiadas a "Done" o "Completada")
     - Tareas en progreso (estado actual)
     - Tareas nuevas que tomaron

3. **Identificar bloqueadores**
   - Busca tareas con etiquetas: "bloqueada", "blocked", "impedimento"
   - Busca comentarios que mencionen: "bloqueado", "blocked", "impedimento"
   - Lista estas tareas separadamente

4. **Generar resumen en formato Daily Standup**

## Formato del resumen:

```markdown
# Daily Standup - {Fecha}

## 📊 Resumen General
- Total de tareas actualizadas: X
- Personas activas: Y
- Tareas completadas: Z
- Bloqueadores identificados: W

---

## 👤 {Nombre de Persona 1}

### ✅ Completó:
- [SCRUM-1] Título de la tarea

### 🔄 En progreso:
- [SCRUM-2] Título de la tarea (estado: En progreso)
- [SCRUM-3] Título de la tarea (estado: En revisión)

### 🆕 Comenzó:
- [SCRUM-4] Título de la tarea

---

## 👤 {Nombre de Persona 2}

...

---

## ⚠️ Bloqueadores Identificados

1. **[SCRUM-X] Título**
   - Asignado a: {Persona}
   - Razón: {Comentario o etiqueta}
   - Tiempo bloqueado: X días

---

## 📈 Métricas del día
- Velocity: X puntos completados
- Tareas por estado:
  - Por hacer: X
  - En progreso: Y
  - En revisión: Z
  - Completadas: W
```

## Notas:
- Si no hay actividad en las últimas 24 horas, informa que no hay actualizaciones
- Considera solo días laborables (opcional: excluir fines de semana)
- Resalta en negrita las tareas de alta prioridad

