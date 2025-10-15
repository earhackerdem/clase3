Revisa TODAS las tareas del proyecto en Jira que NO estén en estado "Por hacer"
(es decir, tareas en progreso, en revisión, etc.)

Para cada tarea encontrada, evalúa los siguientes criterios:
1. ¿Tiene alguien asignado?
2. ¿Tiene enlaces remotos (remote links) a ramas de Git, commits o pull requests?
3. ¿Se menciona alguna rama de Git en los comentarios?

Luego aplica la siguiente lógica:

**CASO 1: Tarea SIN asignado Y SIN rama**
- Verifica los comentarios existentes
- SOLO si no existe un comentario similar, añade el COMENTARIO C (sin asignado y sin rama)

**CASO 2: Tarea SIN asignado pero CON rama**
- Verifica los comentarios existentes
- SOLO si no existe un comentario similar, añade el COMENTARIO A (solo sin asignado)

**CASO 3: Tarea CON asignado pero SIN rama**
- Verifica los comentarios existentes
- SOLO si no existe un comentario similar, añade el COMENTARIO B (solo sin rama)

NOTA: Prioriza CASO 1 si ambos problemas existen, para generar UN SOLO comentario que documente ambos incumplimientos.

---

## COMENTARIO C (para tareas sin asignado Y sin rama):

¡Hola equipo! 👋

He notado que esta tarea está en un estado distinto a "Por hacer" pero tiene **dos problemas importantes**:

⚠️ **1. No tiene a nadie asignado**
- Esto causa confusión sobre quién es responsable de completarla

🌿 **2. No tiene una rama de Git asociada**
- No se puede hacer seguimiento del código ni realizar code review

Por favor:

**Sobre la asignación:**
- Si estás trabajando en esta tarea, **asígnatela** para que el equipo sepa quién es el responsable
- Si nadie está trabajando en ella, considera **moverla de regreso a "Por hacer"**

**Sobre la rama de Git:**
- Crea una rama siguiendo la convención: `feature/{ISSUE-KEY}-descripcion-corta`
- Asocia la rama mediante commits que incluyan el ticket (ej: `[SCRUM-5] Implementar endpoint`)
- O menciona la rama en un comentario

Esto nos ayudará a mantener un mejor control del flujo de trabajo y del código. Gracias! 🙏

---

## COMENTARIO A (para tareas sin asignado):

¡Hola equipo! 👋

He notado que esta tarea está en un estado distinto a "Por hacer" pero **no tiene a nadie asignado**.

⚠️ Esto puede causar confusión sobre quién es responsable de completarla.

Por favor:
- Si estás trabajando en esta tarea, **asígnatela** para que el equipo sepa quién es el responsable
- Si nadie está trabajando en ella, considera **moverla de regreso a "Por hacer"**

Esto nos ayudará a mantener un mejor control del flujo de trabajo. Gracias! 🙏

---

## COMENTARIO B (para tareas con asignado pero sin rama):

Hola! 👋

He notado que esta tarea está en progreso pero aún no tiene una rama de Git asociada.

Para mantener un mejor control del trabajo y facilitar el code review, por favor:

🌿 **Crea una rama** siguiendo la convención:
```
feature/{ISSUE-KEY}-descripcion-corta
```

Por ejemplo:
```
feature/SCRUM-5-actualizar-tareas
```

📝 **Asocia la rama** a este ticket mediante:
- Un commit que incluya el número del ticket en el mensaje (ej: `[SCRUM-5] Implementar endpoint`)
- Un comentario mencionando la rama creada
- O vinculando el pull request cuando esté listo

Esto nos ayudará a todos a hacer seguimiento del progreso y facilitar la integración del código. 

Gracias por tu colaboración! 🙏

