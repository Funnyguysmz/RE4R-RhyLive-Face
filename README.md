# RE4R RhyLive Face

用于生化危机4重制版 REFramework 的 RhyLive / ARKit 接收与面部骨骼驱动插件。当前 Lua 面板版本 **0.2.0**；DLL 内部版本号独立维护。

## 安装与使用
1. 安装 REFramework。
2. 构建后把 build/package/reframework 合并到游戏根目录，完整重启游戏。
3. 手机发送目标填写电脑 Wi-Fi IPv4，端口默认 9000；开启无线发送，保持面捕页面前台。
4. REFramework → Script Generated UI → RhyLive Face：监听地址通常为 0.0.0.0，端口 9000，点击 Start。
5. 确认有效帧增加，进入自然待机后 Capture neutral，再开启 Drive face。

支持中英文切换、52 通道显示和幅度调节、手动测试、平滑和断流保护。表情效果取决于模型骨骼与权重。没有角色专用 reframework/data/RhyLiveFace_profile.json 时，默认主要驱动左右眨眼和张嘴。

## 相关仓库
- [形态键系统](https://github.com/Funnyguysmz/RE4R-ShapeKey-System) 可读取接收 DLL 的 rhylive_native 数据。
- [独立 Studio](https://github.com/Funnyguysmz/RE4R-ShapeKey-Studio) 维护桌面界面、桥接 DLL 和 GUI 适配层。
- 仅驱动形态键时不要同时开启骨骼 Drive face，避免竞争。
- Studio 完整包可能包含经过适配的同名脚本；使用对应 Studio 版本的运行文件，避免覆盖其适配层。

## 构建
Windows x64，安装 Zig 并加入 PATH，执行：
~~~powershell
.\Build.ps1
# 或指定工具
.\Build.ps1 -ZigPath 'C:\Tools\zig\zig.exe'
~~~
输出 build/package。vendor 包含 Lua 5.4.3 源码及 REFramework API 头和许可。构建不下载依赖，不需要游戏资源。

仓库不包含个人字体工具、模型资产或用户配置。项目自有代码尚未另行声明开源许可；第三方许可保留在 vendor 与 ThirdPartyNotices.txt。
