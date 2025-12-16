# Whisper App

音声認識アプリケーション（Whisper API利用）



# Whisper App

[![Python](https://img.shields.io/badge/python-3.8%2B-blue.svg)](https://www.python.org/downloads/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Speech-to-text application using OpenAI Whisper and Streamlit.

---

## Quick Start

1. **Install Python 3.8 or higher.**
2. **Install required Python packages:**

	```bash
	pip install -r requirements.txt
	```

3. **Install ffmpeg on your system:**
	- **macOS:**
		```bash
		brew install ffmpeg
		```
	- **Ubuntu/Debian:**
		```bash
		sudo apt update && sudo apt install ffmpeg
		```
	- **Windows:**
		Download from [ffmpeg.org](https://ffmpeg.org/download.html) and add to PATH.

4. **Start the application:**

	```bash
	python whisper_app.py
	# or
	sh startup.sh
	```

---

## About `startup.sh`

`startup.sh` launches the Streamlit server. If you need to specify a port, set the `$PORT` environment variable before running.

## Environment Variables

- `PORT`: Port number for the Streamlit server (default is used if unset)

## File Structure

- `whisper_app.py`: Main application
- `requirements.txt`: Required Python packages
- `startup.sh`: Startup shell script
- `samples/`: (Optional) Folder for sample audio files

## Deploy to Linux VM (Ubuntu — recommended: B2)

You can use the provided automation script to prepare an Ubuntu VM for running this Streamlit app (systemd service, nginx reverse proxy, swap, ufw, optional certbot). The script is located at `scripts/setup_whisper_vm.sh`.

Quick usage (replace `<VM_IP>` and `--repo`/`--domain` as needed):

1. Ensure your SSH private key is local and has safe permissions (rename if it contains spaces):

```bash
mv "~/Downloads/hmin0149 (2).pem" ~/.ssh/hmin0149.pem
chmod 600 ~/.ssh/hmin0149.pem
```

2. Transfer the setup script and run it on the VM:

```bash
scp -i ~/.ssh/hmin0149.pem scripts/setup_whisper_vm.sh azureuser@<VM_IP>:~
ssh -i ~/.ssh/hmin0149.pem azureuser@<VM_IP>
chmod +x setup_whisper_vm.sh
# Option A: clone repo and configure domain
sudo ./setup_whisper_vm.sh --repo "https://github.com/yourname/yourrepo.git" --domain "example.com"
# Option B: upload project files and run without --repo
sudo ./setup_whisper_vm.sh
```

Notes:

- For the Azure free tier, choose **Standard_B2** (2 vCPU, 1 GiB) for improved CPU-bound performance; the script adds a 2GB swap by default to help memory-limited instances.
- If you don't have a domain yet, run the script without `--domain` and test the app via the VM public IP; configure `certbot` later when you add a DNS name.
- The script installs `faster-whisper` to improve CPU inference speed and creates a `systemd` service (`whisper_app`) and an `nginx` site that proxies to `127.0.0.1:8501`.

  Note: If you see Streamlit warnings in `journalctl` about CORS or XSRF (server.enableCORS being overridden), the systemd unit is configured to start Streamlit with `--server.enableXsrfProtection false` so nginx proxying works correctly. Disabling XSRF reduces protection against cross-site attacks; ensure you expose the app only over HTTPS and via trusted domains.

  Note on transcription backend: The app now prefers `faster-whisper` (faster on CPU, supports quantized compute types) when installed, and falls back to `openai-whisper`'s `whisper.load_model()` if not. Ensure you have either `faster-whisper` or `openai-whisper` installed in the VM's virtual environment. See `requirements.txt`.

- After setup, check the service with `sudo systemctl status whisper_app` and logs with `sudo journalctl -u whisper_app -f`.

## Continuous Integration & Deployment

This repository includes a GitHub Actions workflow for automatic deployment to Azure Web Apps. See `.github/workflows/main_whisper-transcriber-luca.yml` for details.

## Sample Data

You can add sample audio files to the `samples/` folder for testing and demonstration purposes. (Folder is empty by default)

## Notes

- ffmpeg is not a Python package; it must be installed on your system.
- Manage API keys and credentials using environment variables.
- For security, do not upload personal or confidential information.
- Tested on macOS. Should work on Linux and Windows with proper ffmpeg installation.

## License

This project is licensed under the MIT License.
## Continuous Integration & Deployment
This repository includes a GitHub Actions workflow for automatic deployment to Azure Web Apps. See `.github/workflows/main_whisper-transcriber-luca.yml` for details.

## Sample Data
You can add sample audio files to the `samples/` folder for testing and demonstration purposes. (Folder is empty by default)

## Notes
- ffmpeg is not a Python package; it must be installed on your system.
- Manage API keys and credentials using environment variables.
- For security, do not upload personal or confidential information.
- Tested on macOS. Should work on Linux and Windows with proper ffmpeg installation.

## License

This project is licensed under the MIT License.
