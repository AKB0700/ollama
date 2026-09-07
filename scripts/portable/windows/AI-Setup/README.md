# Windows 可攜式 AI 部署

將本目錄**內的檔案**直接複製到 `H:\AI`，再以系統管理員身分執行 `Launch-AI-FirstTime.cmd`。首次執行會安裝官方 Ollama 與 CUDA Toolkit 12.8.1 到 Windows，並把 Python、ComfyUI、模型和快取存放在 `H:\AI`。

目標電腦必須先安裝相容的最新 NVIDIA Studio Driver。初始化會自動檢測 `nvidia-smi`；若缺少驅動程式，會開啟 NVIDIA 官方下載頁面並停止。請選擇 **Studio Driver**、安裝、重新開機後重試。NVIDIA 驅動的最新版本須依顯卡與 Windows 版本選擇，無法安全地以固定網址自動安裝。

完成後：

- 執行 `Launch-AI.cmd` 同時啟動 Ollama 和 ComfyUI。
- ComfyUI 開啟於 `http://127.0.0.1:8188`，只允許本機存取。
- Ollama 開啟於 `http://127.0.0.1:11434`。
- 執行 `powershell -ExecutionPolicy Bypass -File .\Pull-Portable-Models.ps1 <模型名>` 下載 Ollama 模型；未指定模型時下載 `llama3.2`。
- 將 ComfyUI 模型放在 `H:\AI\models\comfyui` 對應子資料夾（例如 `checkpoints`、`vae`、`loras`）。
- `OLLAMA_MODELS` 已寫入目前 Windows 使用者環境變數，指向 SSD 的 `models\ollama`；模型不會寫進系統碟。

首次下載會使用官方 HTTPS 來源，請只在可信任的網路環境執行。所有啟動腳本以自身所在資料夾決定根目錄，因此 Windows 指派不同磁碟代號後仍可使用。
