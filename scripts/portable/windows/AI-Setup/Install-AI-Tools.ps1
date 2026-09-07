Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 將 AI-Setup 內的所有檔案直接複製至 H:\AI 後執行本檔。
$aiRoot = $PSScriptRoot
$appsRoot = Join-Path $aiRoot 'apps'
$pythonRoot = Join-Path $appsRoot 'python'
$comfyRoot = Join-Path $appsRoot 'ComfyUI'
$installerRoot = Join-Path $appsRoot 'installers'

function New-AIDirectories {
  $directories = @(
    $appsRoot, $pythonRoot, $comfyRoot, $installerRoot,
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
  [Environment]::SetEnvironmentVariable('OLLAMA_MODELS', $env:OLLAMA_MODELS, 'User')
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
    Write-Host '找不到 NVIDIA Studio Driver。即將開啟 NVIDIA 官方驅動下載頁面；請選擇 Studio Driver、完成安裝與重新開機後再次執行。' -ForegroundColor Yellow
    Start-Process 'https://www.nvidia.com/Download/index.aspx'
    throw 'NVIDIA Studio Driver 是 GPU 加速的必要條件。'
  }
  $driver = & $nvidiaSmi.Source '--query-gpu=name,driver_version' '--format=csv,noheader' 2>$null
  if ($LASTEXITCODE -ne 0) { throw 'nvidia-smi 執行失敗，請更新 NVIDIA 驅動程式。' }
  Write-Host "已偵測 NVIDIA GPU：$driver"
}

function Install-NvidiaCudaToolkit {
  $nvcc = 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin\nvcc.exe'
  if (Test-Path $nvcc) {
    Write-Host "已安裝 CUDA Toolkit：$(& $nvcc --version | Select-Object -Last 1)"
    return
  }

  $installer = Join-Path $installerRoot 'cuda_12.8.1_windows.exe'
  if (-not (Test-Path $installer)) {
    Get-DownloadedFile `
      -Uri 'https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda_12.8.1_570.65_windows.exe' `
      -Destination $installer
  }
  Write-Host '安裝 CUDA Toolkit 12.8.1...'
  $process = Start-Process -FilePath $installer -ArgumentList '-s cuda_toolkit' -Wait -PassThru
  if ($process.ExitCode -ne 0) { throw "CUDA Toolkit 安裝失敗，結束代碼：$($process.ExitCode)" }
}

function Install-Ollama {
  $ollama = Get-Command ollama.exe -ErrorAction SilentlyContinue
  if ($ollama) {
    Write-Host "已安裝官方 Ollama：$($ollama.Source)"
    return
  }

  $installer = Join-Path $installerRoot 'OllamaSetup.exe'
  if (-not (Test-Path $installer)) {
    Get-DownloadedFile -Uri 'https://ollama.com/download/OllamaSetup.exe' -Destination $installer
  }
  $signature = Get-AuthenticodeSignature -FilePath $installer
  if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'O=Ollama Inc\.') {
    throw 'Ollama 安裝程式的 Authenticode 簽章無效。'
  }
  $process = Start-Process -FilePath $installer -ArgumentList '/VERYSILENT /NORESTART /SUPPRESSMSGBOXES' -Wait -PassThru
  if ($process.ExitCode -ne 0) { throw "Ollama 安裝失敗，結束代碼：$($process.ExitCode)" }
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
Install-NvidiaCudaToolkit
$python = Install-PortablePython
Install-Ollama
Install-ComfyUI

Write-Host '安裝 ComfyUI 相依套件與 CUDA 12.8 版 PyTorch，這可能需要幾分鐘...'
& $python -m pip install --upgrade pip
& $python -m pip install --no-warn-script-location -r (Join-Path $comfyRoot 'requirements.txt')
& $python -m pip install --no-warn-script-location --upgrade torch torchvision --index-url https://download.pytorch.org/whl/cu128
& $python -c 'import torch; assert torch.cuda.is_available(), "PyTorch 無法使用 CUDA"; print("PyTorch CUDA:", torch.cuda.get_device_name(0))'

Write-Host '可攜式 Ollama 與 ComfyUI 初始化完成。'
