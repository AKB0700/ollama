Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$aiRoot = $PSScriptRoot
$ollamaExe = Join-Path $aiRoot 'apps\ollama\ollama.exe'
$env:OLLAMA_MODELS = Join-Path $aiRoot 'models\ollama'

if (-not (Test-Path $ollamaExe)) { throw '找不到可攜式 Ollama。請先執行 Launch-AI-FirstTime.cmd。' }

$model = if ($args.Count -gt 0) { $args[0] } else { 'llama3.2' }
& $ollamaExe pull $model
