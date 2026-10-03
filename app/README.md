# HomeLab Panel

HomeLab Panel 是 [HomeLab](../README.md) 的 Flutter 平板控制端。家庭局域网中的 HomeLab Hub 将负责设备接入、状态管理和指令执行；Panel 负责向家庭成员展示状态、接收操作，并呈现操作结果。

## 当前进度

目前是一个**可运行的工程骨架**。启动后会看到标题为「控制中枢」的占位首页，页面提示「家庭中枢尚未接入」。这条提示是固定文案，不代表应用已经尝试连接 Hub。

Hub 服务端、设备列表、网络通信、配对和控制功能均尚未实现。现在没有需要填写的服务器地址，也没有可操作的模拟设备。

## 工程结构

```text
app/
├── android/                                  Android 平台工程
├── ios/                                      iOS / iPadOS 平台工程
├── lib/
│   ├── main.dart                             Flutter 启动入口
│   ├── app/app.dart                          应用名称、主题和首页配置
│   └── features/dashboard/presentation/
│       └── dashboard_screen.dart             当前占位首页
├── analysis_options.yaml                     Dart 静态检查规则
├── pubspec.yaml                              包名、版本和依赖
└── pubspec.lock                              已解析的依赖版本
```

启动顺序是 `main.dart` 调用 `runApp`，`HomeLabPanelApp` 创建 `MaterialApp`，再显示 `DashboardScreen`。目前所有可见内容都在首页组件中；数据层和页面状态层要等 Hub API 明确后才会加入。

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
flutter build apk --debug
```

原始计数器的模板测试已经移除；目前没有针对实际业务的测试。加入 Hub 通信和设备操作后，再为有业务逻辑的部分补充测试。

## 后续如何接入 Hub

计划按「连接中枢 → 读取设备状态 → 发送控制指令」的顺序开发。页面负责展示与输入，功能状态逻辑处理加载、断线及操作结果；Repository 管理数据和刷新，Service 与 Hub 通信。Hub 是设备状态的权威来源，页面不应只因按钮被点击就显示操作成功。

接口协议、地址发现和认证方式目前尚未确定，因此工程里还没有对应的依赖、配置文件或占位实现。目录演进、参考项目和具体开发顺序见[Flutter 工程规划](../docs/flutter-app-architecture.md)。
