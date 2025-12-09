#!/bin/bash

echo "=== 创建必要目录 ==="
mkdir -p /vol1/1000/YouTube
mkdir -p /vol1/1000/Youtube/1080P
mkdir -p /vol1/1000/YT-DLP
mkdir -p /home/yt-dlp
mkdir -p /home/yt-dlp/bin
mkdir -p /home/yt-dlp/logs

echo "=== 安装依赖 (python3 / ffmpeg / curl / jq) ==="
apt update
apt install -y python3 python3-pip ffmpeg curl jq

echo "=== 安装最新版 yt-dlp 到 /home/yt-dlp/bin ==="
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /home/yt-dlp/bin/yt-dlp
chmod +x /home/yt-dlp/bin/yt-dlp

echo "=== 创建 monitor.sh ==="
cat > /home/yt-dlp/monitor.sh << 'EOF'
#!/bin/bash

BASE="/home/yt-dlp"
LOG_DIR="/vol1/1000/YT-DLP"
URL_FILE="$LOG_DIR/dl.txt"
COOKIE="$LOG_DIR/cookies.txt"
DOWNLOAD_DIR="/vol1/1000/YouTube"
DOWNLOAD_1080P_DIR="/vol1/1000/YouTube/1080P"
YTDLP_BIN="/home/yt-dlp/bin/yt-dlp"

mkdir -p "$LOG_DIR"
mkdir -p "$DOWNLOAD_1080P_DIR"

LOG_FILE="$LOG_DIR/monitor.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🟢 monitor.sh 正在运行..."

[ ! -f "$URL_FILE" ] && touch "$URL_FILE"
[ ! -f "$COOKIE" ] && { log "⚠ 未找到 cookies.txt"; touch "$COOKIE"; }

while true; do
    sed -i 's/ //g' "$URL_FILE"
    sed -i '/^$/d' "$URL_FILE"

    if [ -s "$URL_FILE" ]; then
        URL=$(head -n 1 "$URL_FILE")
        log "📌 待下载：$URL"

        CHANNEL=$("$YTDLP_BIN" --cookies "$COOKIE" -o "%(channel)s" --print "%(channel)s" "$URL" 2>/dev/null)
        [ -z "$CHANNEL" ] && CHANNEL="Unknown"

        mkdir -p "$DOWNLOAD_DIR/$CHANNEL"
        mkdir -p "$DOWNLOAD_1080P_DIR/$CHANNEL"

        "$YTDLP_BIN" \
            --ignore-errors \
            --no-warnings \
            --cookies "$COOKIE" \
            --concurrent-fragments 8 \
            --merge-output-format mp4 \
            -o "$DOWNLOAD_DIR/$CHANNEL/%(upload_date)s_%(title)s.%(ext)s" \
            "$URL" 2>&1 | tee -a "$LOG_FILE"

        RET=$?
        if [ $RET -ne 0 ]; then
            log "❌ 下载失败（$RET）"
        else
            log "✅ 下载完成"
        fi

        log "🎬 开始生成 1080P 视频..."
        "$YTDLP_BIN" \
            --cookies "$COOKIE" \
            -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
            -o "$DOWNLOAD_1080P_DIR/$CHANNEL/%(upload_date)s_%(title)s_1080p.%(ext)s" \
            "$URL" 2>&1 | tee -a "$LOG_FILE"

        if [ $? -eq 0 ]; then
            log "🎉 1080P 生成成功"
        else
            log "⚠ 1080P 生成失败"
        fi

        sed -i '1d' "$URL_FILE"
        log "🧹 已处理并移除：$URL"
    fi

    sleep 5
done
EOF

chmod +x /home/yt-dlp/monitor.sh

echo "=== 创建 systemd 服务 dlp.service ==="
cat > /etc/systemd/system/dlp.service <<EOF
[Unit]
Description=YouTube Downloader Monitor
After=network.target

[Service]
Type=simple
ExecStart=/home/yt-dlp/monitor.sh
WorkingDirectory=/home/yt-dlp
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "=== 启动 dlp.service 并设置开机自启 ==="
systemctl daemon-reload
systemctl enable dlp
systemctl start dlp

echo "=== 安装完成 ==="
echo "📌 把链接写入：/vol1/1000/YT-DLP/dl.txt"
echo "📥 下载输出：/vol1/1000/YouTube/"
echo "🎬 自动生成 1080P：/vol1/1000/YouTube/1080P/"
