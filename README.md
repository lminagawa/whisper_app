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
