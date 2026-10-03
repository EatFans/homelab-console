# HomeLab Panel

HomeLab Panel 是 [HomeLab](../README.md) 的 Flutter 平板控制终端。家庭局域网中的 HomeLab Hub 将负责设备接入、状态管理和指令执行；Panel 负责向家庭成员展示状态、接收操作，并呈现操作结果。当前的图标是终端内的功能入口，后续控制能力需要通过 Hub 接入。

## 当前进度

目前只有**一个应用桌面**：左右滑动切换图标页，底部固定常用应用栏。长按上方图标可拖入常用栏；常用栏内拖动可交换位置，拖回上方页面可移出。常用栏的排列保存在本机，重启后恢复。其他一级页面和 AI Agent 入口尚未确定。

点击任一应用图标会进入对应标题的占位功能页，并可返回应用列表。入口和页首的「中枢未连接」提示均为界面骨架：Hub 服务端、网络通信、配对和设备控制尚未实现，当前没有真实设备数据。

## 工程结构

先只看 `lib/`：这里是你日常修改界面和交互的地方。`android/`、`ios/` 是 Flutter 调用原生平台能力和打包时使用的工程，普通页面开发通常不用进入。

```text
app/
├── android/                         Android 平台工程
├── ios/                             iOS / iPadOS 平台工程
├── lib/
│   ├── main.dart                    程序启动入口
│   ├── app.dart                     应用名称、主题和初始页面
│   ├── theme/
│   │   └── panel_theme.dart         浅色/深色颜色配置
│   └── pages/
│       ├── apps_page.dart           横向分页、拖拽与常用应用栏
│       └── feature_placeholder_page.dart  点击入口后的占位页
├── test/                            页面交互测试
├── pubspec.yaml                     包名、版本和依赖
└── analysis_options.yaml            Dart 静态检查规则
```

启动顺序：`main.dart` → `app.dart` → `pages/apps_page.dart`。点击入口时，再打开 `pages/feature_placeholder_page.dart`。

| 你想改什么 | 去哪个文件 |
| --- | --- |
| 应用启动、系统浅色/深色跟随 | `lib/app.dart` |
| 颜色和主题 | `lib/theme/panel_theme.dart` |
| 应用图标、横向分页、底部常用栏和顶部状态提示 | `lib/pages/apps_page.dart` |
| 入口点击后的临时页面 | `lib/pages/feature_placeholder_page.dart` |

刚接触 Flutter 时，按上面的启动顺序读源码即可。`Widget` 是界面组件，`build` 返回组件树；`StatefulWidget` 用于保存会变化的值，调用 `setState` 后 Flutter 会重新构建相关界面。应用入口通过 `Navigator.push` 打开功能页，功能页通过 `Navigator.pop` 返回。关键位置有中文注释。

目前页面少，所以先集中放在 `pages/`。Hub API 和具体功能确定后，再把变大的功能拆成独立目录；现在不放空的 `models/`、`services/` 或 `repositories/`。

`pubspec.yaml` 中的 `homelab_panel` 是 Dart 包名；设备桌面上显示的是 **HomeLab Panel**。Android 和 iOS 当前的应用标识符仍是 `cn.eatfan.app`，正式分发前需要确认是否更换；它与显示名称是两回事。

## 本地运行与检查

先安装 Flutter SDK，以及目标平台对应的 Android 或 Apple 开发工具。在本目录执行：

```sh
flutter pub get
flutter run
```

如果连接了多台设备，先用 `flutter devices` 查看设备 ID，再用 `flutter run -d 设备ID` 选择目标设备。Android 与 iOS 平台目录目前都保留。

静态检查和 Android 调试构建：

```sh
flutter analyze
flutter test
flutter build apk --debug
```

需要安装包给 Android 设备测试时，执行 `flutter build apk --release`，产物位于 `build/app/outputs/flutter-apk/app-release.apk`。常用栏的图标排列通过 Flutter 官方 `shared_preferences` 插件保存在设备本机；这份配置目前不会与 Hub 同步。

现有测试检查左右翻页、功能入口打开和返回、长按拖拽，以及常用栏的本地保存。加入 Hub 通信和设备操作后，再为实际业务逻辑补充测试。

## 后续如何接入 Hub

计划按「连接中枢 → 读取设备状态 → 发送控制指令」的顺序开发。页面负责展示与输入，功能状态逻辑处理加载、断线及操作结果；Repository 管理数据和刷新，Service 与 Hub 通信。Hub 是设备状态的权威来源，页面不应只因按钮被点击就显示操作成功。

接口协议、地址发现和认证方式目前尚未确定，因此工程里还没有对应的依赖、配置文件或占位实现。界面规范见[视觉主题](../docs/panel-theme.md)，页面划分见[页面与交互规划](../docs/panel-page-plan.md)，目录演进和开发顺序见[Flutter 工程规划](../docs/flutter-app-architecture.md)。
