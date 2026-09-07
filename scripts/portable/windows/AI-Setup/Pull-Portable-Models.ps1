Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$aiRoot = $PSScriptRoot
$ollama = Get-Command ollama.exe -ErrorAction SilentlyContinue
$ollamaExe = if ($ollama) {
  $ollama.Source
} else {
  Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama.exe'
}
$env:OLLAMA_MODELS = Join-Path $aiRoot 'models\ollama'

if (-not (Test-Path $ollamaExe)) { throw '找不到官方 Ollama。請先執行 Launch-AI-FirstTime.cmd。' }

$model = if ($args.Count -gt 0) { $args[0] } else { 'llama3.2' }
& $ollamaExe pull $model
