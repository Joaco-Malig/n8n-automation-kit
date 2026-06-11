# n8n-automation-kit

Kit completo para conectar Claude Code con n8n en proyectos reales. Incluye MCPs pre-configurados, skills especializadas, un subagente arquitecto de workflows, y templates listos para usar.

Creado por [Carlos Domínguez](https://github.com/Carlos-Dominguez-faber) — [Imperio Digital](https://imperiodigital.club) · VibeCoding

---

## Qué incluye

```
n8n-automation-kit/
├── .mcp.json                        ← Config de MCPs (versionada, usa ${VAR}, sin secretos)
├── .env.example                     ← Plantilla de credenciales → copiar a .env (ignorado)
├── start.ps1                        ← Lanzador Windows: carga .env y abre Claude Code
├── CLAUDE.md                        ← Cuestionario de contexto para Claude (rellenar)
├── MEMORY.md                        ← Sistema de autoaprendizaje (Claude lo actualiza solo)
├── .claude/skills/                  ← Skills a nivel proyecto (se cargan solas, no globales)
├── skills/                          ← Copia distribuible de las skills (referencia)
│   ├── n8n-coolify-fullstack/       ← Skill exclusiva del kit
│   ├── make-to-n8n/                 ← Skill para migrar escenarios Make → n8n
│   └── n8n-sdk-rules/               ← Reglas canónicas del @n8n/workflow-sdk oficial
├── agents/
│   └── workflow-architect/          ← Subagente que diseña planes completos de workflows
├── docs/
│   ├── mcp-vs-api.md                ← Cuándo usar MCP vs API REST
│   └── setup-guide.md               ← Guía de instalación detallada
├── workflows/
│   ├── README.md                    ← Instrucciones para poner tus workflows aquí
│   └── starters/
│       └── webhook-router-starter.json  ← Workflow base con sticky notes incluidas
└── workshop/
    └── index.html                   ← Workshop guide interactivo de la clase
```

---

## Inicio en 3 pasos

### Paso 1 — Obtener el kit y abrir en Claude Code

**Opción A — clonar (Windows / PowerShell):**
```powershell
git clone https://github.com/Joaco-Malig/n8n-automation-kit mi-proyecto-n8n
cd mi-proyecto-n8n
```

**Opción B — copia manual:** copia la carpeta del kit en el Explorador y renómbrala con el nombre del proyecto. A diferencia de `git clone`, la copia manual **sí incluye tu `.env`** (con la conexión a n8n ya lista).

> **Por qué trabajar desde este directorio:** Claude Code lee `.mcp.json`, `CLAUDE.md`, `MEMORY.md` y `.claude/skills/` desde la raíz del proyecto. La carpeta copiada del kit **es** la raíz del proyecto — no la metas como subcarpeta de otra carpeta.

### Paso 2 — Las skills ya vienen incluidas

Este kit trae las skills **a nivel de proyecto** en `.claude/skills/` (no globales). Se cargan solas al abrir Claude Code en esta carpeta — no hay que copiarlas a `~/.claude/skills/`.

> Las otras skills de n8n (`n8n-workflow-patterns`, etc.) vienen del marketplace de Claude Code y están disponibles de forma global.

### Paso 3 — Configurar tus credenciales

`.mcp.json` ya está versionado y usa `${VAR}` — **no contiene secretos**. Los secretos van en `.env` (ignorado por git) o en variables de usuario de Windows.

**3a. Copiar el template de entorno y rellenarlo:**

```powershell
Copy-Item .env.example .env
```

Editar `.env` y poner tu instancia:
```
N8N_API_URL=https://TU_N8N_URL/     # la / al final es obligatoria
N8N_API_KEY=TU_API_KEY
```

Para obtener tu API key: **n8n → Settings → API → Enable API → Create API Key**

**3b. Hacer que Claude Code vea esas variables.** Claude Code NO lee `.env` por sí solo; las variables deben estar en el entorno antes de lanzar `claude`. Dos formas:

- **Lanzador (por proyecto):** abre Claude con el script incluido, que carga el `.env`:
  ```powershell
  .\start.ps1
  ```
- **Variables fijas (una sola instancia de n8n para todo):** una sola vez en tu PC:
  ```powershell
  setx N8N_API_URL "https://TU_N8N_URL/"
  setx N8N_API_KEY "TU_API_KEY"
  ```
  Desde ahí, `claude` directo funciona en cualquier proyecto con este `.mcp.json`.

**3c. Rellenar `CLAUDE.md`** — las secciones 1, 2 y 3 son las más importantes:
- Sección 1: tu URL de n8n, si usas Coolify, microservicios activos
- Sección 2: nombre del proyecto, proceso que automatizas, reglas de negocio
- Sección 3: credenciales disponibles en n8n (nombres exactos), nodos que más usas

**3d. Configurar Playwright con tu perfil de Chrome** (opcional — para validación E2E con sesión activa):

Los perfiles de Chrome en Windows están en `C:\Users\TU_USUARIO\AppData\Local\Google\Chrome\User Data\`. Crea un perfil **dedicado** (recomendado, para evitar el bloqueo "perfil en uso") e indica su ruta vía la variable `CHROME_USER_DATA_DIR` en tu `.env`:

```
CHROME_USER_DATA_DIR=C:\Users\TU_USUARIO\AppData\Local\Google\Chrome\PlaywrightProfile
```

> Antes de usar Playwright: en ese perfil dedicado, inicia sesión en tu n8n y Coolify. Así Playwright ya tiene sesión activa cada vez que lo usa Claude.

---

## Verificar que todo funciona

Escribe esto en Claude Code después de configurar:

```
/mcp
```
→ Debe aparecer **n8n-mcp ✅ connected**

Luego prueba:
```
"lista mis workflows activos en n8n"
```
→ Claude debe devolver tus workflows reales via MCP.

---

## Las 6 skills de n8n

Claude las activa automáticamente — no necesitas invocarlas.

| Skill | Se activa cuando... |
|---|---|
| `n8n-workflow-patterns` | Diseñas un workflow nuevo o eliges arquitectura |
| `n8n-mcp-tools-expert` | Usas cualquier herramienta MCP de n8n |
| `n8n-node-configuration` | Configuras un nodo específico |
| `n8n-code-javascript` | Escribes código JS en un Code node |
| `n8n-expression-syntax` | Escribes expresiones `{{ }}` o hay un undefined |
| `n8n-validation-expert` | Hay errores de validación que interpretar |

Estas 6 skills se instalan desde el marketplace de Claude Code. La skill **`n8n-coolify-fullstack`** (la exclusiva de este kit) la instalaste en el Paso 2.

---

## La skill exclusiva: n8n-coolify-fullstack

Combina 5 módulos que trabajan juntos en proyectos de producción:

| Módulo | Qué hace |
|---|---|
| `coolify-microservices.md` | Gestiona microservicios en Coolify MCP desde Claude: list, get, restart, logs |
| `sticky-notes-patterns.md` | 4 zonas de documentación obligatorias con posiciones y colores estándar |
| `dual-layer-validation.md` | Validación en dos capas: MCP (estructura) + Playwright E2E (visual con sesión) |
| `sub-workflow-patterns.md` | Cuándo crear sub-workflows, cómo pasar datos, el gotcha del `type: "string"` |
| `microservice-integration.md` | Integrar microservicios Docker con n8n: patrones síncrono, callback, polling |

---

## La skill canónica: n8n-sdk-rules

Reglas de generación extraídas directamente del `@n8n/workflow-sdk` oficial de n8n (v0.12.1). El equipo de n8n escribió este contenido específicamente para guiar a agentes de IA — no es documentación de usuario.

| Módulo | Qué contiene |
|---|---|
| `workflow-rules.md` | 4 reglas estrictas: nunca `alwaysOutputData: true`, cuándo usar `executeOnce: true`, elegir el primitivo de control de flujo correcto, credenciales siempre via credentials manager |
| `expression-gotchas.md` | Los 3 contextos donde `$json` es inseguro (AI Agent subnodes, multi-branch fan-in, nodos no inmediatos) + referencia completa de variables y Luxon |
| `node-selection.md` | Selección de nodo por caso de uso, triggers, preferencia de nativos sobre Code node, patrones de AI tools y multi-agent |
| `parameter-guides.md` | Guías detalladas: IF (operadores completos), Set (tipos), Switch, Webhook (responseMode), HTTP Request (auth), Tool nodes (`$fromAI`), AI Agent (system vs user message) |
| `best-practices.md` | Patrones por categoría: chatbot (memoria compartida, session keys), notificaciones (multi-canal en paralelo), scheduling (condicional > cron complejo), human-in-the-loop (Wait node + resumeUrl) |

**Se activa automáticamente** al crear o editar cualquier workflow n8n. Previene los errores más comunes antes de que ocurran.

---

## La skill de migración: make-to-n8n

Convierte escenarios Make (Integromat) a workflows n8n. Se activa automáticamente cuando pegas un JSON exportado de Make o describes un flujo que quieres migrar.

| Módulo | Qué contiene |
|---|---|
| `SKILL.md` | Tabla de conceptos Make vs n8n, proceso paso a paso, patrones especiales (Iterator, Router, Repeater, Aggregator), ejemplo completo de migración |
| `module-mapping.md` | Mapeo de ~80 módulos Make → nodo n8n exacto, con tipo de equivalencia y snippets para módulos sin equivalente directo |
| `expression-conversion.md` | Traducción completa de sintaxis: `{{N.field}}` → `{{$node["X"].json.field}}`, todas las funciones de texto, fecha, número, array y hashing |

**Cómo usarla:**
```
"tengo este JSON de Make, conviértelo a n8n"
"migra este escenario de Make a un workflow n8n"
"cómo traduzo este módulo de Make al nodo equivalente en n8n"
```

---

## El subagente workflow-architect

Diseña planes completos de implementación en lenguaje natural:

```
"actúa como workflow-architect y diseña el plan para:
 recibir un formulario de contacto por webhook, calificar el lead
 con un Code node, guardar en Google Sheets, y enviar email con
 o sin botón de agenda según la calificación"
```

El subagente produce:
- Diagrama ASCII del flujo
- Tabla de nodos con configuración clave
- Posiciones y contenido de sticky notes por zona
- Secuencia de construcción paso a paso
- Credenciales requeridas y riesgos

---

## MCP vs API REST — cuándo usar cada uno

Ver [docs/mcp-vs-api.md](docs/mcp-vs-api.md) para la comparativa completa.

**Resumen:**
- **MCP**: para construir, editar y validar workflows. Claude entiende n8n semánticamente.
- **API REST directa**: para operar y monitorear. Scripts, CI/CD, ejecuciones en tiempo real.
- **Los dos viven en el mismo `.mcp.json`** — no son excluyentes.

---

## Tus workflows

La carpeta `workflows/` está vacía intencionalmente. Pon ahí tus propios workflows:

```bash
# Exportar desde n8n: ⋮ → Download → guardar el .json aquí
workflows/mi-workflow.json
workflows/sub-mi-proceso.json
```

Hay un workflow base en `workflows/starters/webhook-router-starter.json` — un dispatcher con sticky notes en las 4 zonas obligatorias, listo para adaptar.

---

## CLAUDE.md y MEMORY.md

**`CLAUDE.md`** — Lo rellenas tú una vez. Claude lo lee al inicio de cada sesión y sabe exactamente qué instancia de n8n usas, qué credenciales están disponibles, y qué convenciones seguir. Sin él, Claude empieza sin contexto cada vez.

**`MEMORY.md`** — Lo actualiza Claude solo. Cada vez que encuentra y resuelve un error, descubre un gotcha, o valida un patrón que funciona, agrega una entrada. Con el tiempo acumula el conocimiento específico de tu proyecto.

---

## Coolify MCP (opcional)

Si usas Coolify para alojar n8n y tus microservicios, ya hay un bloque `coolify` listo en `.mcp.json.example` (forma Windows, `cmd /c npx`). Cópialo a tu `.mcp.json` y agrega las variables al `.env`:

```
COOLIFY_ACCESS_TOKEN=TU_TOKEN
COOLIFY_BASE_URL=https://coolify.tudominio.com/
```

El bloque en `.mcp.json` las referencia con `${COOLIFY_ACCESS_TOKEN}` / `${COOLIFY_BASE_URL}` — sin secretos en el archivo.

Token en: **Coolify → Profile → API Tokens → Create**

Con Coolify MCP puedes pedirle a Claude cosas como:
- `"verifica que todos mis microservicios están corriendo"`
- `"reinicia el servicio X"`
- `"muéstrame los últimos logs del servicio Y"`

---

## Requisitos

- **n8n self-hosted** corriendo y accesible (Coolify, Docker, o local)
- **Claude Code** instalado: `npm install -g @anthropic-ai/claude-code`
- **Node.js 18+** (para npx)
- **Chrome** instalado (para Playwright con sesión persistente)

Ver [docs/setup-guide.md](docs/setup-guide.md) para instalación paso a paso.

---

## Licencia

MIT — Úsalo, modifícalo, compártelo.

---

*Creado con Claude Code + [La Forja v3.2.0](https://github.com/Carlos-Dominguez-faber/forge) · Imperio Digital 2026*
