---

# 📥 yt-dlp-fnos

基于 **yt-dlp + systemd** 的全自动 YouTube 适用于的视频后台下载器，支持：

* 自动检测下载队列 (`dl.txt`)
* 自动下载原始视频
* 自动生成 *1080P 转码版*
* 自动日志输出
* 自动后台常驻服务（systemd）
* 自动开机启动
* 支持 cookies.txt（登录下载）

适用于 **Linux / Debian / Ubuntu / NAS 环境（含威联通 / 群晖自建 Debian 容器）【飞牛fnos已测试】**。

---

# 🚀 一键安装

```bash
bash <(curl -sL bash <(curl -sL https://raw.githubusercontent.com/wsng911/yt-dlp-fnos/main/install-yt-dlp.sh)
)
```

脚本将自动完成：

✔ 创建所有目录
✔ 安装依赖（python3 / ffmpeg / curl / jq）
✔ 下载最新 yt-dlp
✔ 写入 monitor.sh
✔ 写入 systemd/dlp.service
✔ 启动后台服务并设为自启

---

# 📘 yt-dlp 自动下载服务 README


---

## 📂 目录结构

最终目录结构如下：

```
/vol1/1000/
├── YouTube/
│   ├── <频道名>/
│   │   └── YYYYMMDD_标题.mp4
│   └── 1080P/
│       └── <频道名>/
│           └── YYYYMMDD_标题_1080p.mp4
└── YT-DLP/
    ├── dl.txt          # 写入待下载 URL
    ├── cookies.txt     # YouTube cookies
    └── monitor.log     # 服务日志
```

---

## ✏ 使用方法

### 1. 写入待下载视频链接

把视频 / 播放列表 / Shorts 的链接写入：

```
/vol1/1000/YT-DLP/dl.txt
```

例如：

```
https://www.youtube.com/watch?v=xxxx
https://youtu.be/yyyy
```

服务会自动处理，并在完成后从文件中删除该行。

---

### 2. 下载结果输出

原视频下载到：

```
/vol1/1000/YouTube/<频道名>/
```

自动生成的 1080P 版本输出到：

```
/vol1/1000/YouTube/1080P/<频道名>/
```

---

### 3. Cookies 设置（可选）

如需下载：

* 会员视频
* 年龄限制视频
* 登录账号数据

请将你的 cookies.txt 放置于：

```
/vol1/1000/YT-DLP/cookies.txt
```

---

## ⚙ 服务管理

### 查看运行状态

```
systemctl status dlp
```

### 重启服务

```
systemctl restart dlp
```

### 停止服务

```
systemctl stop dlp
```

### 查看日志

```
tail -f /vol1/1000/YT-DLP/monitor.log
```

---

## 🛠 monitor.sh 工作流程

1. 每 5 秒检测一次 dl.txt
2. 若发现 URL：

   * 自动获取视频频道名称
   * 分类保存原视频
   * 自动生成 1080P 版本
   * 成功后删除该 URL 条目
3. 全过程记录在 monitor.log

---

## 📌 注意事项

* 脚本目录区分大小写，必需使用 `YouTube` 不是 `Youtube`
* 下载输出路径大小写必须一致，否则 yt-dlp 无法正确写入
* 若 cookies.txt 为空，则无法下载会员限制/年龄限制视频
* monitor.sh 会自动创建空 cookies.txt，如果你没放 cookies，它会继续运行（但无法下载受限内容）

---

## 🎉 完成

部署完成后，你只需：

1. 把链接写进 `/vol1/1000/YT-DLP/dl.txt`
2. 等待自动下载
3. 去 `/vol1/1000/YouTube/` 查看结果

### 2）cookies.txt 无效？

请重新从 Chrome 导出 **Netscape 格式** cookies。

---
