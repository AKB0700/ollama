# Windows 可攜式 AI 部署

將本目錄**內的檔案**直接複製到 `H:\AI`，再執行 `Launch-AI-FirstTime.cmd`。不需要系統管理員權限，也不會安裝或變更網咖電腦的 Windows、NVIDIA 驅動或 CUDA Toolkit；Python、Ollama、ComfyUI、模型和快取都會存放在 `H:\AI`。

初始化會檢測現有 NVIDIA 驅動。若可用，會安裝 CUDA 12.8 版 PyTorch 並使用 GPU；若不可用，會安裝 CPU 版 PyTorch。CUDA Toolkit 不需要安裝，且不會在網咖電腦上留下安裝內容。

完成後：

- 執行 `Launch-AI.cmd` 同時啟動 Ollama 和 ComfyUI。
- ComfyUI 開啟於 `http://127.0.0.1:8188`，只允許本機存取。
- Ollama 開啟於 `http://127.0.0.1:11434`。
- 執行 `Launch-WhisperJAV.cmd` 啟動 SSD 上的 WhisperJAV GUI；使用其本機字幕功能，並在翻譯選項中選擇 `Ollama`，不可選擇雲端 provider。
- 執行 `powershell -ExecutionPolicy Bypass -File .\Pull-Portable-Models.ps1 <模型名>` 下載 Ollama 模型；未指定模型時下載 `llama3.2`。
- 將 ComfyUI 模型放在 `H:\AI\models\comfyui` 對應子資料夾（例如 `checkpoints`、`vae`、`loras`）。
- `OLLAMA_MODELS` 僅在啟動腳本的程序環境中指向 SSD 的 `models\ollama`；模型不會寫進系統碟。

WhisperJAV 首次啟動時仍可能下載所選的語音辨識模型；請在 SSD 有網路時先執行一次目標模式，確認模型已快取，之後即可離線處理影片與使用 Ollama 本機翻譯。WhisperJAV 是字幕／翻譯工具，不含語音模擬功能；任何語音模擬僅應處理您本人或已取得明確授權的聲音。

首次下載會使用官方 HTTPS 來源，請只在可信任的網路環境執行。所有啟動腳本以自身所在資料夾決定根目錄，因此 Windows 指派不同磁碟代號後仍可使用。
