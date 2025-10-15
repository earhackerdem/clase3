Este comando realiza una auditoría completa del flujo de trabajo en Jira.
Combina las verificaciones de:
1. Calidad de documentación de tareas (descripciones completas)
2. Proceso de desarrollo (asignación y ramas de Git)

---

## PARTE 1: VERIFICAR DESCRIPCIONES DE TAREAS

Revisa las tareas asignadas al usuario en Jira
en caso de que estas no cuenten con descripción O que la descripción no incluya 
TODOS los siguientes elementos:
- Historia de Usuario
- Objetivo
- Criterios de Aceptación

Verifica primero los comentarios existentes de cada tarea
y SOLO si no existe un comentario similar, añade el COMENTARIO 1 (sin descripción completa)

---

## PARTE 2: VERIFICAR ASIGNACIÓN Y RAMAS DE GIT

Revisa TODAS las tareas del proyecto en Jira que NO estén en estado "Por hacer"
(es decir, tareas en progreso, en revisión, etc.)

Para cada tarea encontrada, evalúa los siguientes criterios:
1. ¿Tiene alguien asignado?
2. ¿Tiene enlaces remotos (remote links) a ramas de Git, commits o pull requests?
3. ¿Se menciona alguna rama de Git en los comentarios?

Luego aplica la siguiente lógica:

**CASO A: Tarea SIN asignado Y SIN rama**
- Verifica los comentarios existentes
- SOLO si no existe un comentario similar, añade el COMENTARIO 2A (sin asignado y sin rama)

**CASO B: Tarea SIN asignado pero CON rama**
- Verifica los comentarios existentes
- SOLO si no existe un comentario similar, añade el COMENTARIO 2B (solo sin asignado)

**CASO C: Tarea CON asignado pero SIN rama**
- Verifica los comentarios existentes
- SOLO si no existe un comentario similar, añade el COMENTARIO 2C (solo sin rama)

NOTA: Prioriza CASO A si ambos problemas existen, para generar UN SOLO comentario que documente ambos incumplimientos.

---

# COMENTARIOS A GENERAR

## COMENTARIO 1 (para tareas sin descripción completa):

Hola! 👋

Esta tarea necesita una descripción más completa para poder ser implementada correctamente.

Por favor, agrega al menos los siguientes elementos:

📖 Historia de Usuario
Como [tipo de usuario]
quiero [objetivo/funcionalidad]
para que [beneficio/razón]

🎯 Objetivo
Una descripción clara del propósito de esta tarea y qué se espera lograr.

✅ Criterios de Aceptación
Una lista detallada de los requisitos que deben cumplirse para considerar la tarea como completada. Por ejemplo:

[ ] Descripción del criterio 1

[ ] Descripción del criterio 2

[ ] etc.

Esto nos ayudará a todos a entender mejor el alcance y los requisitos de la tarea. Gracias! 🙏

---

## COMENTARIO 2A (para tareas sin asignado Y sin rama):

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

## COMENTARIO 2B (para tareas sin asignado):

¡Hola equipo! 👋

He notado que esta tarea está en un estado distinto a "Por hacer" pero **no tiene a nadie asignado**.

⚠️ Esto puede causar confusión sobre quién es responsable de completarla.

Por favor:
- Si estás trabajando en esta tarea, **asígnatela** para que el equipo sepa quién es el responsable
- Si nadie está trabajando en ella, considera **moverla de regreso a "Por hacer"**

Esto nos ayudará a mantener un mejor control del flujo de trabajo. Gracias! 🙏

---

## COMENTARIO 2C (para tareas con asignado pero sin rama):

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

---

## RESUMEN AL FINALIZAR

Al terminar de ejecutar ambas partes, presenta un resumen con:
- Total de tareas revisadas
- Tareas con descripción incompleta encontradas
- Tareas sin asignado encontradas
- Tareas sin rama encontradas
- Comentarios agregados en total

