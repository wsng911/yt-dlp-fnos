---

# 📥 yt-dlp-auto

基于 **yt-dlp + systemd** 的全自动 YouTube 视频后台下载器，支持：

* 自动检测下载队列 (`dl.txt`)
* 自动下载原始视频
* 自动生成 *1080P 转码版*
* 自动日志输出
* 自动后台常驻服务（systemd）
* 自动开机启动
* 支持 cookies.txt（登录下载）

适用于 **Linux / Debian / Ubuntu / NAS 环境（含威联通 / 群晖自建 Debian 容器）**。

---

# 🚀 一键安装

```bash
bash <(curl -sL https://github.com/wsng911/yt-dlp-fnos/blob/main/install-yt-dlp.sh)
```

脚本将自动完成：

✔ 创建所有目录
✔ 安装依赖（python3 / ffmpeg / curl / jq）
✔ 下载最新 yt-dlp
✔ 写入 monitor.sh
✔ 写入 systemd/dlp.service
✔ 启动后台服务并设为自启

---

# 📂 目录结构

安装后目录结构如下：

```
/vol1/1000/
├── YouTube/              # 原始下载视频输出
│   └── 1080P/            # 自动生成的1080P版本
└── YT-DLP/
    └── dl.txt            # 下载任务队列
/home/yt-dlp/
├── monitor.sh            # 自动监控脚本（核心）
├── bin/yt-dlp            # yt-dlp 主程序
└── logs/monitor.log      # 日志输出
```

---

# 📝 使用方式

## ① 写入下载链接

将任意 YouTube URL 写入：

```
/vol1/1000/YT-DLP/dl.txt
```

例如：

```
https://www.youtube.com/watch?v=abc123
https://www.youtube.com/watch?v=xyz999
```

脚本会自动检测，每条链接下载后自动删除队列中的行。

---

# 🎬 下载结果

| 类型             | 输出位置                        | 说明               |
| -------------- | --------------------------- | ---------------- |
| 原始格式 mp4       | `/vol1/1000/YouTube/`       | 默认 yt-dlp 下载格式   |
| 自动生成的 1080P 文件 | `/vol1/1000/YouTube/1080P/` | 自动二次下载 1080P 分辨率 |

---

# 🔧 systemd 服务说明

服务文件：

```
/etc/systemd/system/dlp.service
```

主要命令：

### 启动服务

```bash
systemctl start dlp
```

### 停止服务

```bash
systemctl stop dlp
```

### 重启服务

```bash
systemctl restart dlp
```

### 查看日志

```bash
journalctl -u dlp -f
```

### 设置开机自启

```bash
systemctl enable dlp
```

---

# 🔐 使用 cookies 下载受限视频（可选）

将浏览器导出的 `cookies.txt` 放到：

```
/home/yt-dlp/cookies.txt
```

脚本会自动加载并使用 cookies 下载受限内容（付费、会员、年龄限制等）。

---

# 📣 monitor.sh 工作逻辑

`monitor.sh` 每 5 秒执行：

1. 清理空行
2. 读取第一条 URL
3. 下载原始视频到 `/YouTube`
4. 若成功 → 自动下载 1080P 版到 `/YouTube/1080P`
5. 移除第一行 URL
6. 继续循环

完全无人值守。

---

# ⭐ 功能亮点

| 功能           | 是否支持   |
| ------------ | ------ |
| 自动后台循环任务     | ✔      |
| 自动错误检测       | ✔      |
| 1080P 自动转存   | ✔      |
| cookies 登录下载 | ✔      |
| 断点续传         | ✔      |
| 并行分片下载       | ✔（8线程） |
| 多视频自动队列      | ✔      |
| systemd 自启   | ✔      |
| 自带日志系统       | ✔      |

---

# 🆘 常见问题（FAQ）

### 1）dl.txt 写入正确但不下载？

检查 service 是否运行：

```bash
systemctl status dlp
```

### 2）cookies.txt 无效？

请重新从 Chrome 导出 **Netscape 格式** cookies。

---
