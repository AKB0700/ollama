# Ollama Automatic Installer for Windows
# Usage: irm https://ollama.com/auto-install.ps1 | iex
# Or: powershell -ExecutionPolicy Bypass -File auto-install.ps1

$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message)
    Write-Host ">>> $Message" -ForegroundColor Green
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-OllamaInstallPath {
    # Check if Ollama is already installed
    $defaultPath = "$env:LOCALAPPDATA\Programs\Ollama"
    if (Test-Path $defaultPath) {
        return $defaultPath
    }
    return $null
}

function Download-OllamaSetup {
    param([string]$TempDir)
    
    $setupUrl = "https://ollama.com/download/OllamaSetup.exe"
    $setupPath = Join-Path $TempDir "OllamaSetup.exe"
    
    Write-Status "Downloading Ollama installer..."
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $setupUrl -OutFile $setupPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        if (-not (Test-Path $setupPath)) {
            throw "Download failed: Setup file not found"
        }
        
        Write-Status "Download complete!"
        return $setupPath
    }
    catch {
        Write-Error-Message "Failed to download Ollama: $_"
        throw "Download failed"
    }
}

function Install-Ollama {
    param([string]$SetupPath, [string]$InstallPath)
    
    Write-Status "Installing Ollama..."
    
    $installArgs = @("/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART")
    
    if ($InstallPath) {
        $installArgs += "/DIR=`"$InstallPath`""
    }
    
    try {
        $process = Start-Process -FilePath $SetupPath -ArgumentList $installArgs -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Status "✓ Ollama successfully installed!"
            return $true
        }
        else {
            Write-Error-Message "Installation failed with exit code: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        Write-Error-Message "Installation error: $_"
        return $false
    }
}

function Wait-ForOllamaService {
    Write-Status "Waiting for Ollama service to start..."
    
    $maxAttempts = 30
    $attempt = 0
    
    while ($attempt -lt $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:11434/" -Method GET -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Status "✓ Ollama service is running!"
                return $true
            }
        }
        catch {
            # Service not ready yet
        }
        
        $attempt++
        Start-Sleep -Seconds 2
    }
    
    Write-Warning-Message "Could not verify Ollama service status. It may need to be started manually."
    return $false
}

function Test-OllamaInstallation {
    Write-Status "Verifying installation..."
    
    # Check if ollama.exe exists in PATH or default location
    $ollamaPath = Get-Command ollama -ErrorAction SilentlyContinue
    
    if (-not $ollamaPath) {
        # Try default installation path
        $defaultPath = "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
        if (Test-Path $defaultPath) {
            Write-Status "Ollama installed at: $defaultPath"
            return $true
        }
        return $false
    }
    
    Write-Status "Ollama installed at: $($ollamaPath.Source)"
    return $true
}

function Main {
    Write-Host ""
    Write-Status "Ollama Automatic Installer for Windows"
    Write-Status "======================================="
    Write-Host ""
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-Error-Message "Windows 10 or newer is required"
        throw "Unsupported Windows version"
    }
    
    # Check if already installed
    $existingPath = Get-OllamaInstallPath
    if ($existingPath) {
        Write-Warning-Message "Ollama appears to be already installed at: $existingPath"
        $response = Read-Host "Do you want to reinstall? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            Write-Status "Installation cancelled."
            return
        }
    }
    
    # Create temp directory
    $tempDir = Join-Path $env:TEMP "ollama_install_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        # Download installer
        $setupPath = Download-OllamaSetup -TempDir $tempDir
        
        # Run installer
        $installSuccess = Install-Ollama -SetupPath $setupPath
        
        if (-not $installSuccess) {
            throw "Installation failed"
        }
        
        # Wait a moment for installation to complete
        Start-Sleep -Seconds 3
        
        # Verify installation
        if (Test-OllamaInstallation) {
            Write-Status "✓ Installation verified successfully!"
        }
        else {
            Write-Warning-Message "Could not verify installation. Please check manually."
        }
        
        # Try to wait for service
        Wait-ForOllamaService
        
        Write-Host ""
        Write-Status "Installation Complete!"
        Write-Status "======================"
        Write-Host ""
        Write-Status "Next steps:"
        Write-Status "1. Open a new terminal/PowerShell window"
        Write-Status "2. Run: ollama run gemma3"
        Write-Status "3. Visit https://ollama.com/library for more models"
        Write-Status "4. Check https://docs.ollama.com for documentation"
        Write-Host ""
        
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    catch {
        Write-Error-Message "Installation failed: $_"
        throw
    }
    finally {
        # Cleanup temp directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# Run main function
try {
    Main
}
catch {
    Write-Host ""
    Write-Error-Message "Fatal error: $_"
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
