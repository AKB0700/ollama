# Windows 可攜式 AI 部署

將本目錄**內的檔案**直接複製到 `H:\AI`，再執行 `Launch-AI-FirstTime.cmd`。首次執行會把 Python、Ollama、ComfyUI、模型和快取都存放在 `H:\AI`，不需安裝 CUDA Toolkit。

目標電腦必須先安裝相容的最新 NVIDIA 驅動程式。初始化會自動檢測 `nvidia-smi`；若缺少驅動程式，會開啟 NVIDIA 官方下載頁面並停止，待安裝與重開機後重試。

完成後：

- 執行 `Launch-AI.cmd` 同時啟動 Ollama 和 ComfyUI。
- ComfyUI 開啟於 `http://127.0.0.1:8188`，只允許本機存取。
- Ollama 開啟於 `http://127.0.0.1:11434`。
- 執行 `powershell -ExecutionPolicy Bypass -File .\Pull-Portable-Models.ps1 <模型名>` 下載 Ollama 模型；未指定模型時下載 `llama3.2`。
- 將 ComfyUI 模型放在 `H:\AI\models\comfyui` 對應子資料夾（例如 `checkpoints`、`vae`、`loras`）。

首次下載會使用官方 HTTPS 來源，請只在可信任的網路環境執行。所有啟動腳本以自身所在資料夾決定根目錄，因此 Windows 指派不同磁碟代號後仍可使用。
