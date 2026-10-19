# Codex Anime Launcher

一个 Windows 桌面启动动画：路飞与艾斯切入画面，索隆从小到大突进，以三刀流劈开屏幕，露出已提前启动的 Codex。

![动画预览](docs/preview.png)

## 效果

- 约 4 秒全屏片头，标题为 **Codex**。
- 双侧人物入场、速度线、火星、闪电和发光标题。
- 索隆逐渐放大，路飞与艾斯同步淡出。
- 三道绿色刀光依次切开画面，完成应用转场。
- 原创合成的重型摇滚音效：失真吉他、双踩鼓、重镲与三连斩击。
- 动画开始时提前启动应用；按 **Esc**、**Enter** 或点「跳过」立即进入。

人物采用 AI 插画配合位移、缩放、淡化和刀光特效，并非逐帧人物肢体动画。

## 环境

Windows 10 / 11，Windows PowerShell 5.1、WPF 和 Windows Script Host；已安装 Codex 桌面应用。动画播放不需要 Python、联网或视频生成服务。Windows 禁用 VBScript 时，可以直接运行下方 PowerShell 启动命令。

## 安装

1. 下载本仓库 ZIP，**完整解压到一个准备长期保留的文件夹**。
2. 在该文件夹打开 PowerShell，运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
```

3. 双击桌面新建的 **Codex Anime** 图标。

安装会自动查找 Codex 的应用 ID，并创建 `launcher.local.json`。安装器只添加本项目的快捷方式，不替换已有 Codex / ChatGPT 图标。无需管理员权限。

### 手动指定应用 ID

如果自动识别失败，先运行 `Get-StartApps` 查找 Codex 的 `AppID`，再执行：

```powershell
.\Install.ps1 -AppId '你的 Codex AppID'
```

配置后，也可以不用快捷方式直接运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\Launch-Codex.ps1
```

## 仅预览动画

下面的命令会播放完整动画和音效，不启动 Codex，也不安装快捷方式：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File .\Launch-Codex.ps1 -SmokeTest
```

## 卸载

在项目文件夹运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall.ps1
```

它只删除指向本文件夹的 **Codex Anime** 快捷方式。随后可自行删除项目文件夹。移动项目文件夹前，请先卸载快捷方式，移动后重新安装。

## 文件

```text
Launch-Codex.ps1           全屏动画、音效与应用启动逻辑
Start.vbs                 隐藏 PowerShell 控制台的启动入口
Install.ps1               检测应用并创建桌面快捷方式
Uninstall.ps1             删除本项目的快捷方式
assets/                   人物插画与 WAV 音效
docs/preview.png          GitHub 预览图
tools/make_battle_sound.py 音效合成源码
requirements.txt          重新生成音效所需的可选依赖
```

## 修改音效

直接替换 `assets/startup-sfx.wav` 即可，建议保留约 4.08 秒的长度，三次斩击对应 3.05、3.12、3.19 秒。

如需用源码重新生成音效：

```powershell
python -m pip install -r requirements.txt
python tools/make_battle_sound.py
```

## 素材说明

本项目为《航海王》角色主题的非官方同人作品，与 OpenAI 及《航海王》官方无关。角色插画使用 imagegen 生成，音效由项目内 Python 脚本原创合成，未使用原作配音或主题曲。生成提示词摘要见 [ASSETS.md](ASSETS.md)。

## 上传 GitHub

创建空仓库后，把本文件夹中的文件和子文件夹上传到仓库根目录即可。ZIP 是方便下载的打包文件；如希望 GitHub 首页展示说明和预览，应上传解压后的项目内容。

`launcher.local.json` 是本机配置，已列入 `.gitignore`，不需要上传。包内没有个人桌面路径、原快捷方式或个人账户配置。
