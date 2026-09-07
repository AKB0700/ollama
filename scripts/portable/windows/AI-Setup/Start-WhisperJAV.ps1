Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$aiRoot = $PSScriptRoot
$whisperJavRoot = Join-Path $aiRoot 'apps\WhisperJAV'
$whisperJavExe = Join-Path $whisperJavRoot 'WhisperJAV.exe'

if (-not (Test-Path $whisperJavExe)) {
  throw '找不到 WhisperJAV。請先執行 Launch-AI-FirstTime.cmd。'
}

$env:OLLAMA_MODELS = Join-Path $aiRoot 'models\ollama'
$env:HF_HOME = Join-Path $aiRoot 'cache\huggingface'
$env:TORCH_HOME = Join-Path $aiRoot 'cache\torch'
$env:XDG_CACHE_HOME = Join-Path $aiRoot 'cache'
$env:APPDATA = Join-Path $aiRoot 'cache\whisperjav\AppData\Roaming'
$env:LOCALAPPDATA = Join-Path $aiRoot 'cache\whisperjav\AppData\Local'
$env:HOME = $aiRoot
New-Item -ItemType Directory -Path $env:APPDATA, $env:LOCALAPPDATA -Force | Out-Null

Start-Process -FilePath $whisperJavExe -WorkingDirectory $whisperJavRoot
