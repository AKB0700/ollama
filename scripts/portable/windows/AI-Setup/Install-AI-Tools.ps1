Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 將 AI-Setup 內的所有檔案直接複製至 H:\AI 後執行本檔。
$aiRoot = $PSScriptRoot
$appsRoot = Join-Path $aiRoot 'apps'
$pythonRoot = Join-Path $appsRoot 'python'
$ollamaRoot = Join-Path $appsRoot 'ollama'
$comfyRoot = Join-Path $appsRoot 'ComfyUI'

function New-AIDirectories {
  $directories = @(
    $appsRoot, $pythonRoot, $ollamaRoot, $comfyRoot,
    (Join-Path $aiRoot 'models\ollama'),
    (Join-Path $aiRoot 'models\comfyui'),
    (Join-Path $aiRoot 'cache\huggingface'),
    (Join-Path $aiRoot 'cache\torch'),
    (Join-Path $aiRoot 'cache\comfyui'),
    (Join-Path $aiRoot 'input'), (Join-Path $aiRoot 'output')
  )
  foreach ($directory in $directories) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
  }
}

function Set-PortableEnvironment {
  $env:OLLAMA_MODELS = Join-Path $aiRoot 'models\ollama'
  $env:HF_HOME = Join-Path $aiRoot 'cache\huggingface'
  $env:TORCH_HOME = Join-Path $aiRoot 'cache\torch'
  $env:COMFYUI_TEMP_DIRECTORY = Join-Path $aiRoot 'cache\comfyui'
}

function Get-DownloadedFile {
  param([Parameter(Mandatory)][string]$Uri, [Parameter(Mandatory)][string]$Destination)

  Write-Host "下載：$Uri"
  Invoke-WebRequest -Uri $Uri -OutFile $Destination
}

function Install-ZipIfMissing {
  param(
    [Parameter(Mandatory)][string]$TargetFile,
    [Parameter(Mandatory)][string]$Uri,
    [Parameter(Mandatory)][string]$Destination
  )

  if (Test-Path $TargetFile) { return }
  $archive = Join-Path $env:TEMP ([IO.Path]::GetRandomFileName() + '.zip')
  try {
    Get-DownloadedFile -Uri $Uri -Destination $archive
    Expand-Archive -Path $archive -DestinationPath $Destination -Force
  } finally {
    Remove-Item $archive -Force -ErrorAction SilentlyContinue
  }
  if (-not (Test-Path $TargetFile)) {
    throw "安裝後仍找不到預期檔案：$TargetFile"
  }
}

function Install-PortablePython {
  $python = Join-Path $pythonRoot 'python.exe'
  Install-ZipIfMissing -TargetFile $python `
    -Uri 'https://www.python.org/ftp/python/3.12.10/python-3.12.10-embed-amd64.zip' `
    -Destination $pythonRoot

  $pth = Join-Path $pythonRoot 'python312._pth'
  if (Test-Path $pth) {
    (Get-Content -Path $pth) -replace '^#import site$', 'import site' | Set-Content -Path $pth -Encoding ascii
  }

  if (-not (Test-Path (Join-Path $pythonRoot 'Scripts\pip.exe'))) {
    $getPip = Join-Path $env:TEMP 'get-pip.py'
    try {
      Get-DownloadedFile -Uri 'https://bootstrap.pypa.io/get-pip.py' -Destination $getPip
      & $python $getPip --no-warn-script-location
    } finally {
      Remove-Item $getPip -Force -ErrorAction SilentlyContinue
    }
  }
  return $python
}

function Test-NvidiaDriver {
  $nvidiaSmi = Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue
  if (-not $nvidiaSmi) {
    Write-Host '找不到 NVIDIA 驅動程式。即將開啟 NVIDIA 官方下載頁面；安裝與重新開機後請再次執行。' -ForegroundColor Yellow
    Start-Process 'https://www.nvidia.com/Download/index.aspx'
    throw 'NVIDIA 驅動程式是 GPU 加速的必要條件。'
  }
  $driver = & $nvidiaSmi.Source '--query-gpu=name,driver_version' '--format=csv,noheader' 2>$null
  if ($LASTEXITCODE -ne 0) { throw 'nvidia-smi 執行失敗，請更新 NVIDIA 驅動程式。' }
  Write-Host "已偵測 NVIDIA GPU：$driver"
}

function Install-Ollama {
  Install-ZipIfMissing -TargetFile (Join-Path $ollamaRoot 'ollama.exe') `
    -Uri 'https://ollama.com/download/ollama-windows-amd64.zip' -Destination $ollamaRoot
}

function Install-ComfyUI {
  $mainPy = Join-Path $comfyRoot 'main.py'
  if (-not (Test-Path $mainPy)) {
    $archive = Join-Path $env:TEMP ([IO.Path]::GetRandomFileName() + '.zip')
    $extractRoot = Join-Path $env:TEMP ([IO.Path]::GetRandomFileName())
    try {
      Get-DownloadedFile -Uri 'https://github.com/Comfy-Org/ComfyUI/archive/refs/heads/master.zip' -Destination $archive
      Expand-Archive -Path $archive -DestinationPath $extractRoot -Force
      $source = Get-ChildItem -Path $extractRoot -Directory | Select-Object -First 1
      if (-not $source) { throw 'ComfyUI 壓縮檔內容無效。' }
      Get-ChildItem -Path $source.FullName -Force | Move-Item -Destination $comfyRoot -Force
    } finally {
      Remove-Item $archive -Force -ErrorAction SilentlyContinue
      Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
  }

  @"
ollama:
  base_path: $aiRoot
  checkpoints: models/comfyui/checkpoints
  vae: models/comfyui/vae
  loras: models/comfyui/loras
  controlnet: models/comfyui/controlnet
  clip: models/comfyui/text_encoders
  diffusion_models: models/comfyui/diffusion_models
"@ | Set-Content -Path (Join-Path $comfyRoot 'extra_model_paths.yaml') -Encoding utf8
}

New-AIDirectories
Set-PortableEnvironment
Test-NvidiaDriver
$python = Install-PortablePython
Install-Ollama
Install-ComfyUI

Write-Host '安裝 ComfyUI 相依套件與 CUDA 12.8 版 PyTorch，這可能需要幾分鐘...'
& $python -m pip install --upgrade pip
& $python -m pip install --no-warn-script-location -r (Join-Path $comfyRoot 'requirements.txt')
& $python -m pip install --no-warn-script-location --upgrade torch torchvision --index-url https://download.pytorch.org/whl/cu128
& $python -c 'import torch; assert torch.cuda.is_available(), "PyTorch 無法使用 CUDA"; print("PyTorch CUDA:", torch.cuda.get_device_name(0))'

Write-Host '可攜式 Ollama 與 ComfyUI 初始化完成。'
