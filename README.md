# RE4R RhyLive Face

[English](#english) | [中文](#中文)

---

## English

### What it is

A REFramework plugin for Resident Evil 4 Remake that

1. **receives RhyLive / ARKit face data** from a phone over UDP (a small native DLL, `RhyLiveFace.dll`, parses the OSC `/Face` message with 52 ARKit coefficients and exposes the latest values to Lua as the global `rhylive_native`), and
2. optionally **drives the player's face bones** from that data with a Lua panel (`RhyLiveFace.lua`; panel and receiver DLL version **0.2.0**).

The receiver is also the data source for the in-game shape-key panel: [RE4R-ShapeKey-System](https://github.com/Funnyguysmz/RE4R-ShapeKey-System) reads `rhylive_native.poll()` directly. For that route you only need to **start the receiver**; do not also enable the bone "Drive face".

### How the three repositories fit together

```
 phone (RhyLive app, ARKit 52, UDP port 9000)
        |
        v
 RE4R-RhyLive-Face      <- THIS REPO: receiver DLL (rhylive_native) + face-bone Lua panel
        |  rhylive_native.poll()  (read-only snapshot)
        v
 RE4R-ShapeKey-System   in-game panel, writes custom shape-key weights
        ^
        |  named pipe + RE4R_ShapeKeySystem_api
 RE4R-ShapeKey-Studio   desktop app (WebView2 UI) + bridge DLL + installer
```

| Repository | Role |
|---|---|
| [RE4R-RhyLive-Face](https://github.com/Funnyguysmz/RE4R-RhyLive-Face) | receiver DLL and bone-driven face panel (this repo) |
| [RE4R-ShapeKey-System](https://github.com/Funnyguysmz/RE4R-ShapeKey-System) | in-game shape-key panel |
| [RE4R-ShapeKey-Studio](https://github.com/Funnyguysmz/RE4R-ShapeKey-Studio) | desktop GUI, bridge DLL, installer (its package also contains a receiver build and an adapted copy of the panel scripts) |

### Requirements

- Resident Evil 4 Remake with [REFramework](https://github.com/praydog/REFramework).
- A phone running RhyLive with wireless sending, on the same network as the PC.
- Windows x64. Building from source needs [Zig](https://ziglang.org/) in PATH (see below); nothing is needed at run time except REFramework.

### Install (players)

1. Build the package (see "Build from source") or obtain a build you trust.
2. Merge `build/package/reframework` into the game folder (it provides `reframework/plugins/RhyLiveFace.dll` and `reframework/autorun/RhyLiveFace.lua` plus the `RhyLiveFace/` module folder). Restart the game completely.
3. If you use the Studio package, use the Studio installer instead; its bundle may contain an adapted same-name script, and overwriting it with the base script would remove the adaptation.

### Usage

1. On the phone, set the send target to the PC's Wi-Fi IPv4 address and port **9000**; enable wireless sending and keep the capture page in the foreground. (The PC-side "listen address" is normally `0.0.0.0`; it is not the phone's target address.)
2. In game: REFramework menu -> Script Generated UI -> **RhyLive Face**. Listen address `0.0.0.0`, port `9000`, click **Start**.
3. Check that the valid-frame counter increases.
4. For **bone driving**: stand in a natural idle pose, click **Capture neutral**, then enable **Drive face**.
5. For **shape keys**: stop here and use the ShapeKey System panel (source "face capture").

Panel features: Chinese / English switch, 52-channel display and per-channel gain, manual test sliders, smoothing, signal-loss protection (drive is released when input goes stale). Without a model-specific `reframework/data/RhyLiveFace_profile.json` the built-in default profile mainly drives left/right blink and mouth open (about 15 face bones). How good the result looks depends on the model's skeleton and weights; the default mapping is not claimed to suit every replacement model. Receiving 52 coefficients does not mean 52 expressions are mapped.

The packet format expected is OSC over UDP, address `/Face`, 52 float arguments. `tests/SendTestOSC.ps1` sends synthetic frames for testing without a phone.

### Build from source

Windows x64, Zig in PATH:

```powershell
.\Build.ps1
# or point to a specific Zig
.\Build.ps1 -ZigPath 'C:\Tools\zig\zig.exe'
```

Output: `build/package`. `vendor/` contains the Lua 5.4.3 sources and the REFramework API header with its license. The build downloads nothing and does not need game files.

### Testing

`tests/binding_test.c` is a small C program that links the receiver with Lua and checks the `rhylive_native` binding; `tests/SendTestOSC.ps1` sends test OSC frames to a running receiver. No automated test drives the game.

### Verified status and limitations

- The receiver DLL builds from this repository with the bundled sources (verified 2026-10-12). The documentation pass did not re-run in-game capture tests.
- Bone driving was accepted in game by the author on specific character mods; other models depend on their skeleton, weights and mapping.
- The shape-key route (ShapeKey System reading `rhylive_native`) was verified in game by the author on character mods that contain the needed keys.
- Default target is the current player only (no Ashley / NPC selection). The panel maps bone position/rotation; it does not write shape keys itself.
- Listen address, port, response, timeout, position scale and per-channel gains are saved automatically after a short delay. Language choice and model mappings are also saved. Receiver/drive activation, manual test values and the neutral pose are not restored automatically. `docs/功能说明.md` describes the 0.2.0 panel.
- Compatibility after game or REFramework updates needs re-checking (built against the REFramework API header in `vendor/`).

### License

License: MIT. Project-authored code is covered by [LICENSE](LICENSE), Copyright (c) 2026 funnyguyz. Third-party files retain their original licenses as described below.

### Third-party notices

- Lua 5.4.3 (MIT, Lua.org, PUC-Rio), linked into `RhyLiveFace.dll`.
- REFramework `API.h` (MIT, praydog) and the Dear ImGui structure definitions (MIT, Omar Cornut).
- The full texts are in `ThirdPartyNotices.txt` and `vendor/`.

This repository contains no character models, game assets, personal settings or diagnostic dumps.

---

## 中文

### 这是什么

生化危机4重制版的 REFramework 插件，包含两部分：

1. **接收手机 RhyLive / ARKit 面捕数据**：一个小型原生 DLL（`RhyLiveFace.dll`）通过 UDP 解析包含 52 个 ARKit 系数的 OSC `/Face` 消息，并以全局变量 `rhylive_native` 把最新数值提供给 Lua；
2. 可选地用 Lua 面板（`RhyLiveFace.lua`，面板与接收 DLL 版本均为 **0.2.0**）**驱动玩家的面部骨骼**。

这个接收器同时是游戏内形态键面板的数据来源：[RE4R-ShapeKey-System](https://github.com/Funnyguysmz/RE4R-ShapeKey-System) 直接读取 `rhylive_native.poll()`。走形态键路线时只需**启动接收**，不要同时开启骨骼 Drive face。

### 三个仓库如何配合

```
 手机（RhyLive，ARKit 52，UDP 端口 9000）
        |
        v
 RE4R-RhyLive-Face      <- 本仓库：接收 DLL（rhylive_native）+ 面部骨骼 Lua 面板
        |  rhylive_native.poll()（只读快照）
        v
 RE4R-ShapeKey-System   游戏内面板，写入自定义形态键权重
        ^
        |  命名管道 + RE4R_ShapeKeySystem_api
 RE4R-ShapeKey-Studio   桌面程序（WebView2 界面）+ 桥接 DLL + 安装器
```

| 仓库 | 作用 |
|---|---|
| [RE4R-RhyLive-Face](https://github.com/Funnyguysmz/RE4R-RhyLive-Face) | 接收 DLL 与骨骼驱动面板（本仓库） |
| [RE4R-ShapeKey-System](https://github.com/Funnyguysmz/RE4R-ShapeKey-System) | 游戏内形态键面板 |
| [RE4R-ShapeKey-Studio](https://github.com/Funnyguysmz/RE4R-ShapeKey-Studio) | 桌面 GUI、桥接 DLL、安装器（其安装包也含接收器构建和经过适配的面板脚本副本） |

### 需求

- 安装了 [REFramework](https://github.com/praydog/REFramework) 的生化危机4重制版。
- 手机运行 RhyLive 并开启无线发送，与电脑在同一局域网。
- Windows x64。从源码构建需要 PATH 中有 [Zig](https://ziglang.org/)（见下）；运行时除 REFramework 外不需要其他东西。

### 玩家安装

1. 构建安装包（见“从源码构建”），或使用你信任的构建。
2. 把 `build/package/reframework` 合并到游戏根目录（包含 `reframework/plugins/RhyLiveFace.dll`、`reframework/autorun/RhyLiveFace.lua` 和 `RhyLiveFace/` 模块目录），完整重启游戏。
3. 如果使用 Studio 完整包，请用 Studio 的安装器；它的包里可能带有经过适配的同名脚本，用基础脚本覆盖会丢失适配。

### 使用

1. 手机发送目标填电脑 Wi-Fi 的 IPv4 地址，端口 **9000**；开启无线发送，保持面捕页面前台。（电脑端的“监听地址”通常是 `0.0.0.0`，它不是手机的目标地址。）
2. 游戏内：REFramework 菜单 → Script Generated UI → **RhyLive Face**。监听地址 `0.0.0.0`，端口 `9000`，点击 **Start**。
3. 确认有效帧计数在增加。
4. **骨骼驱动**：角色进入自然待机姿态，点击 **Capture neutral**，再开启 **Drive face**。
5. **形态键**：到此为止，改用 ShapeKey System 面板（来源选“面捕”）。

面板功能：中英文切换、52 通道显示和单通道增益、手动测试滑条、平滑、断流保护（输入过期后释放驱动）。没有模型专用的 `reframework/data/RhyLiveFace_profile.json` 时，内置默认配置主要驱动左右眨眼和张嘴（约 15 根面部骨骼）。效果取决于模型骨骼与权重；不声明默认映射适用于所有换模。接收 52 个系数不代表映射了 52 种表情。

期望的数据包格式：UDP 上的 OSC，地址 `/Face`，52 个 float 参数。没有手机时可用 `tests/SendTestOSC.ps1` 发送合成帧测试。

### 从源码构建

Windows x64，Zig 在 PATH 中：

```powershell
.\Build.ps1
# 或指定 Zig 路径
.\Build.ps1 -ZigPath 'C:\Tools\zig\zig.exe'
```

输出 `build/package`。`vendor/` 含 Lua 5.4.3 源码以及 REFramework API 头文件及其许可。构建不下载任何东西，不需要游戏文件。

### 测试

`tests/binding_test.c` 是一个小型 C 程序，把接收器与 Lua 链接并检查 `rhylive_native` 绑定；`tests/SendTestOSC.ps1` 向运行中的接收器发送测试 OSC 帧。没有自动化测试会驱动游戏本体。

### 验证状态与限制

- 接收 DLL 可用本仓库自带源码构建成功（2026-10-12 验证）。本次文档整理没有重跑游戏内面捕测试。
- 骨骼驱动由作者在特定角色 MOD 上实机认可；其他模型取决于骨骼、权重和映射。
- 形态键路线（ShapeKey System 读取 `rhylive_native`）由作者在含所需键的角色 MOD 上实机验证过。
- 默认只驱动当前玩家（没有 Ashley / NPC 选择）。本面板映射骨骼位置/旋转，自己不写形态键。
- 监听地址、端口、响应、断流超时、位置倍率和各通道增益在修改后延迟自动保存；语言选择和模型映射也会保存。接收/驱动开关、手动测试值和中性姿态不自动恢复。`docs/功能说明.md` 描述当前 0.2.0 面板。
- 游戏或 REFramework 更新后需要重新确认兼容性（按 `vendor/` 里的 REFramework API 头文件构建）。

### 许可

License: MIT。项目自有代码适用 [LICENSE](LICENSE)，Copyright (c) 2026 funnyguyz。第三方文件继续遵守下文列出的原始许可。

### 第三方声明

- Lua 5.4.3（MIT，Lua.org, PUC-Rio），链接进 `RhyLiveFace.dll`。
- REFramework `API.h`（MIT，praydog）和 Dear ImGui 结构定义（MIT，Omar Cornut）。
- 全文见 `ThirdPartyNotices.txt` 与 `vendor/`。

本仓库不含角色模型、游戏资源、个人设置或诊断快照。
