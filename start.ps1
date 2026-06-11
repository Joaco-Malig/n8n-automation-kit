# ============================================================
#  start.ps1 — Lanza Claude Code conectado a tu instancia n8n
# ------------------------------------------------------------
#  Lee el archivo .env, carga las variables en el entorno del
#  proceso, y abre Claude Code. Claude Code expande ${VAR} en
#  .mcp.json usando estas variables (no carga .env por sí solo).
#
#  Uso:   .\start.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$envFile = Join-Path $PSScriptRoot ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "[ERROR] No existe .env" -ForegroundColor Red
    Write-Host "        Copia .env.example a .env y rellena tus credenciales:" -ForegroundColor Yellow
    Write-Host "        Copy-Item .env.example .env" -ForegroundColor Yellow
    exit 1
}

$loaded = 0
foreach ($raw in Get-Content $envFile) {
    $line = $raw.Trim()
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) { continue }
    $idx = $line.IndexOf("=")
    if ($idx -le 0) { continue }
    $key = $line.Substring(0, $idx).Trim()
    $val = $line.Substring($idx + 1).Trim()
    if ($val.StartsWith('"') -and $val.EndsWith('"') -and $val.Length -ge 2) {
        $val = $val.Substring(1, $val.Length - 2)
    }
    [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
    $loaded++
}

Write-Host "[OK] $loaded variables cargadas desde .env" -ForegroundColor Green

if ([string]::IsNullOrWhiteSpace($env:N8N_API_URL) -or $env:N8N_API_URL -like "*TU_N8N_URL*") {
    Write-Host "[AVISO] N8N_API_URL aun tiene el valor de ejemplo. Edita .env antes de usar n8n-mcp." -ForegroundColor Yellow
}

Write-Host "[..] Lanzando Claude Code..." -ForegroundColor Cyan
claude
