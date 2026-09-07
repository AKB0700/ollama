Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$aiRoot = $PSScriptRoot
$ollama = Join-Path $aiRoot 'apps\ollama\ollama.exe'
$env:OLLAMA_MODELS = Join-Path $aiRoot 'models\ollama'

if (-not (Test-Path $ollama)) { throw '找不到可攜式 Ollama。請先執行 Launch-AI-FirstTime.cmd。' }

$model = if ($args.Count -gt 0) { $args[0] } else { 'llama3.2' }
& $ollama pull $model
