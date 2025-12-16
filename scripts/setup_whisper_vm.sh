#!/usr/bin/env bash
set -euo pipefail

# Usage:
# sudo ./setup_whisper_vm.sh --repo "https://github.com/you/repo.git" --domain "example.com"
# If you don't want to clone from GitHub, upload your project to ~/whisper_app and run without --repo

REPO_URL=""
DOMAIN=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --repo) REPO_URL="$2"; shift 2;;
    --domain) DOMAIN="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

APP_USER="azureuser"
APP_HOME="/home/${APP_USER}"
APP_DIR="${APP_HOME}/whisper_app"
VENV_DIR="${APP_DIR}/venv"
SERVICE_NAME="whisper_app"

echo "==> Updating apt and installing packages..."
apt update && apt upgrade -y
apt install -y python3-venv python3-pip nginx certbot python3-certbot-nginx ufw git curl build-essential

echo "==> Creating 2GB swap (if not present)..."
if ! swapon --show | grep -q '/swapfile'; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Clone repo if provided
if [[ -n "${REPO_URL}" ]]; then
  echo "==> Cloning repo ${REPO_URL} -> ${APP_DIR}"
  rm -rf "${APP_DIR}"
  sudo -u ${APP_USER} git clone "${REPO_URL}" "${APP_DIR}"
else
  echo "==> No repo URL provided – expecting you uploaded files to ${APP_DIR}"
  mkdir -p "${APP_DIR}"
  chown -R ${APP_USER}:${APP_USER} "${APP_DIR}"
fi

echo "==> Creating virtualenv and installing requirements..."
python3 -m venv "${VENV_DIR}"
# Ensure pip is latest
"${VENV_DIR}/bin/pip" install --upgrade pip
if [[ -f "${APP_DIR}/requirements.txt" ]]; then
  "${VENV_DIR}/bin/pip" install -r "${APP_DIR}/requirements.txt"
fi
# optional: faster-whisper for faster CPU inference
"${VENV_DIR}/bin/pip" install faster-whisper || true

# Create simple systemd unit
echo "==> Writing systemd service..."
cat > /etc/systemd/system/${SERVICE_NAME}.service <<'EOF'
[Unit]
Description=whisper_app (Streamlit)
After=network.target

[Service]
User=azureuser
WorkingDirectory=/home/azureuser/whisper_app
Environment="PATH=/home/azureuser/whisper_app/venv/bin"
ExecStart=/home/azureuser/whisper_app/venv/bin/streamlit run /home/azureuser/whisper_app/whisper_app.py --server.address 127.0.0.1 --server.port 8501 --server.enableCORS false --server.enableXsrfProtection false
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ${SERVICE_NAME}

# nginx site
echo "==> Configuring nginx..."
NGINX_CONF="/etc/nginx/sites-available/whisper"
cat > "${NGINX_CONF}" <<'EOF'
server {
    listen 80;
    server_name REPLACE_DOMAIN_OR_IP;
    location / {
        proxy_pass http://127.0.0.1:8501;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Replace placeholder with domain or public IP if provided; otherwise leave as '_'
if [[ -n "${DOMAIN}" ]]; then
  sed -i "s/REPLACE_DOMAIN_OR_IP/${DOMAIN}/g" "${NGINX_CONF}"
else
  PUBIP=$(curl -s http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress -H "Metadata:true" || true)
  if [[ -z "${PUBIP}" ]]; then PUBIP="_"; fi
  sed -i "s/REPLACE_DOMAIN_OR_IP/${PUBIP}/g" "${NGINX_CONF}"
fi

ln -sf "${NGINX_CONF}" /etc/nginx/sites-enabled/whisper
nginx -t
systemctl restart nginx

# UFW rules
echo "==> Configuring firewall (ufw)..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Certbot (only if DOMAIN provided)
if [[ -n "${DOMAIN}" ]]; then
  echo "==> Obtaining TLS cert with certbot for ${DOMAIN}..."
  certbot --nginx -d "${DOMAIN}" --non-interactive --agree-tos -m "admin@${DOMAIN}" || echo "certbot failed - check DNS and domain configuration"
fi

echo "==> Setup complete. Check 'systemctl status ${SERVICE_NAME}' and 'sudo journalctl -u ${SERVICE_NAME} -f' for logs."
