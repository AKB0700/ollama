Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$aiRoot = $PSScriptRoot
$ollamaRoot = Join-Path $aiRoot 'apps\ollama'
$comfyRoot = Join-Path $aiRoot 'apps\ComfyUI'
$python = Join-Path $aiRoot 'apps\python\python.exe'
$ollama = Join-Path $ollamaRoot 'ollama.exe'

$env:OLLAMA_MODELS = Join-Path $aiRoot 'models\ollama'
$env:HF_HOME = Join-Path $aiRoot 'cache\huggingface'
$env:TORCH_HOME = Join-Path $aiRoot 'cache\torch'
$env:COMFYUI_TEMP_DIRECTORY = Join-Path $aiRoot 'cache\comfyui'
$env:PATH = "$ollamaRoot;$python;$env:PATH"

if (-not (Test-Path $ollama) -or -not (Test-Path $python) -or -not (Test-Path (Join-Path $comfyRoot 'main.py'))) {
  throw '找不到可攜式元件。請先以系統管理員身分執行 Launch-AI-FirstTime.cmd。'
}

try {
  $null = Invoke-WebRequest -Uri 'http://127.0.0.1:11434/api/tags' -UseBasicParsing -TimeoutSec 2
} catch {
  Start-Process -FilePath $ollama -ArgumentList 'serve' -WorkingDirectory $ollamaRoot -WindowStyle Hidden
}

Start-Process -FilePath $python `
  -ArgumentList 'main.py --listen 127.0.0.1 --port 8188 --output-directory', (Join-Path $aiRoot 'output') `
  -WorkingDirectory $comfyRoot

Start-Process 'http://127.0.0.1:8188'
Write-Host 'Ollama 已在 http://127.0.0.1:11434，ComfyUI 已在 http://127.0.0.1:8188 啟動。'
