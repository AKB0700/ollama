# Ollama 自動安裝指南 / Automatic Installation Guide

[English](#english) | [繁體中文](#traditional-chinese) | [简体中文](#simplified-chinese)

---

## <a name="traditional-chinese"></a>繁體中文

### 一鍵自動安裝

Ollama 提供完全自動化的安裝腳本，可以自動檢測您的作業系統並完成安裝。

#### Linux / macOS

在終端機中執行：

```bash
curl -fsSL https://ollama.com/auto-install.sh | sh
```

這個腳本會：
- 自動檢測您的作業系統（Linux 或 macOS）
- 下載適合的 Ollama 版本
- 完成所有安裝步驟
- 設定系統服務（Linux）或應用程式（macOS）
- 自動啟動 Ollama

#### Windows

在 PowerShell 中執行（以管理員身份）：

```powershell
irm https://ollama.com/auto-install.ps1 | iex
```

或者下載並執行：

```powershell
powershell -ExecutionPolicy Bypass -File auto-install.ps1
```

這個腳本會：
- 自動下載 OllamaSetup.exe
- 靜默安裝到您的電腦
- 驗證安裝是否成功
- 啟動 Ollama 服務

### 安裝後使用

安裝完成後，您可以立即開始使用：

```bash
ollama run gemma3
```

### 支援的系統

- **Linux**: Ubuntu, Debian, CentOS, RHEL, Fedora 等
- **macOS**: macOS Sonoma (v14) 或更新版本
- **Windows**: Windows 10 22H2 或更新版本

### 故障排除

如果自動安裝遇到問題，請參考手動安裝指南：
- Linux: https://docs.ollama.com/linux
- macOS: https://docs.ollama.com/macos
- Windows: https://docs.ollama.com/windows

---

## <a name="simplified-chinese"></a>简体中文

### 一键自动安装

Ollama 提供完全自动化的安装脚本，可以自动检测您的操作系统并完成安装。

#### Linux / macOS

在终端中执行：

```bash
curl -fsSL https://ollama.com/auto-install.sh | sh
```

这个脚本会：
- 自动检测您的操作系统（Linux 或 macOS）
- 下载适合的 Ollama 版本
- 完成所有安装步骤
- 设置系统服务（Linux）或应用程序（macOS）
- 自动启动 Ollama

#### Windows

在 PowerShell 中执行（以管理员身份）：

```powershell
irm https://ollama.com/auto-install.ps1 | iex
```

或者下载并执行：

```powershell
powershell -ExecutionPolicy Bypass -File auto-install.ps1
```

这个脚本会：
- 自动下载 OllamaSetup.exe
- 静默安装到您的电脑
- 验证安装是否成功
- 启动 Ollama 服务

### 安装后使用

安装完成后，您可以立即开始使用：

```bash
ollama run gemma3
```

### 支持的系统

- **Linux**: Ubuntu, Debian, CentOS, RHEL, Fedora 等
- **macOS**: macOS Sonoma (v14) 或更新版本
- **Windows**: Windows 10 22H2 或更新版本

### 故障排除

如果自动安装遇到问题，请参考手动安装指南：
- Linux: https://docs.ollama.com/linux
- macOS: https://docs.ollama.com/macos
- Windows: https://docs.ollama.com/windows

---

## <a name="english"></a>English

### One-Click Automatic Installation

Ollama provides fully automated installation scripts that automatically detect your operating system and complete the installation.

#### Linux / macOS

Run in your terminal:

```bash
curl -fsSL https://ollama.com/auto-install.sh | sh
```

This script will:
- Automatically detect your operating system (Linux or macOS)
- Download the appropriate Ollama version
- Complete all installation steps
- Set up system services (Linux) or application (macOS)
- Automatically start Ollama

#### Windows

Run in PowerShell (as Administrator):

```powershell
irm https://ollama.com/auto-install.ps1 | iex
```

Or download and run:

```powershell
powershell -ExecutionPolicy Bypass -File auto-install.ps1
```

This script will:
- Automatically download OllamaSetup.exe
- Silently install to your computer
- Verify the installation was successful
- Start the Ollama service

### Using After Installation

After installation is complete, you can start using immediately:

```bash
ollama run gemma3
```

### Supported Systems

- **Linux**: Ubuntu, Debian, CentOS, RHEL, Fedora, and more
- **macOS**: macOS Sonoma (v14) or newer
- **Windows**: Windows 10 22H2 or newer

### Troubleshooting

If you encounter issues with automatic installation, please refer to the manual installation guides:
- Linux: https://docs.ollama.com/linux
- macOS: https://docs.ollama.com/macos
- Windows: https://docs.ollama.com/windows

---

## Additional Features

### Custom Installation Location

#### Windows
```powershell
# Specify custom installation directory
$env:OLLAMA_INSTALL_DIR = "D:\Programs\Ollama"
irm https://ollama.com/auto-install.ps1 | iex
```

#### macOS
The automatic installer will install to `/Applications` by default. To use a custom location, use the manual installation method.

### Environment Variables

After installation, you can customize Ollama behavior with environment variables:

- `OLLAMA_MODELS`: Directory where models are stored
- `OLLAMA_HOST`: The host:port to bind to (default: 127.0.0.1:11434)
- `OLLAMA_ORIGINS`: Allowed origins for cross-origin requests

### Uninstallation

To uninstall Ollama:

**Linux:**
```bash
sudo systemctl stop ollama
sudo systemctl disable ollama
sudo rm /etc/systemd/system/ollama.service
sudo rm $(which ollama)
sudo rm -rf /usr/local/lib/ollama
sudo userdel ollama
sudo groupdel ollama
rm -rf ~/.ollama
```

**macOS:**
```bash
sudo rm -rf /Applications/Ollama.app
sudo rm /usr/local/bin/ollama
rm -rf ~/.ollama
```

**Windows:**
Use "Add or remove programs" in Windows Settings to uninstall Ollama.

---

## Getting Help

- Documentation: https://docs.ollama.com
- GitHub: https://github.com/ollama/ollama
- Discord: https://discord.gg/ollama
- Reddit: https://reddit.com/r/ollama
