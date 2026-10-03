# HomeLab Panel 工程规划

## 定位与现状

`app/` 是运行在家庭平板上的 Flutter 控制端。设备接入、自动化规则和状态的权威数据由局域网内的 HomeLab Hub 负责；Panel 负责展示状态、发出控制请求，以及清楚地呈现连接和操作结果。

目前已有可运行的横向分页应用桌面、底部常用应用栏、独立设置页和其他功能的占位页。常用栏位置和外观设置使用 `shared_preferences` 保存在本机。Hub、通信协议和设备模型尚未确定，因此不提前引入网络、复杂状态管理、路由或代码生成依赖。具体页面划分见[页面与交互规划](panel-page-plan.md)。

## 参考项目与取舍

| 参考 | 观察 | 在本项目中的取舍 |
| --- | --- | --- |
| [Flutter 官方架构指南](https://docs.flutter.dev/app-architecture/guide)与 [Compass 示例](https://github.com/flutter/samples/tree/main/compass_app/app/lib) | 将界面逻辑和数据访问分开，用 ViewModel、Repository、Service 表达职责；Compass 的共享数据层按类型组织，界面按功能组织。 | 沿用职责边界，但只在出现真实功能时创建类和目录。 |
| [Bloc 的 Flutter Todos 示例](https://github.com/felangel/bloc/tree/master/examples/flutter_todos/lib) | 按功能组织界面代码，入口、主题等放在应用级。 | 使用功能目录方便后续分别开发首页、设备和中枢连接；暂不因示例而引入 Bloc。 |
| [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples) | 同一应用展示多种状态管理方式，并提醒根据项目需求选择。 | 状态管理先使用 Flutter 自带能力；当异步状态和共享状态变复杂时再选型。 |

## 当前目录

目前只有一个应用桌面、设置功能和其他入口的占位页。应用级入口配置放 `app/`，每个实际功能放 `features/`，主题单独放 `theme/`：

```text
app/
├── android/                         # Android 平台工程
├── ios/                             # iOS / iPadOS 平台工程
├── lib/
│   ├── main.dart                    # 启动入口
│   ├── app.dart                     # MaterialApp、主题状态与初始页面
│   ├── app/
│   │   ├── app_feature.dart         # 入口定义与默认占位页
│   │   └── feature_catalog.dart     # 入口清单和页面连接
│   ├── theme/panel_theme.dart       # 浅色和深色主题
│   └── features/
│       ├── launcher/
│       │   ├── launcher_page.dart    # 分页、拖拽与常用栏
│       │   └── dock_storage.dart    # 常用栏本地存取
│       ├── settings/
│       │   ├── settings_page.dart   # 设置页面
│       │   └── settings_controller.dart # 外观状态与保存
│       └── placeholder/feature_placeholder_page.dart # 未完成入口
├── test/                             # 分页、拖拽、导航与设置测试
├── analysis_options.yaml
└── pubspec.yaml
```

阅读路径是 `main.dart` → `app.dart` → `feature_catalog.dart` → `launcher_page.dart` → 具体功能页。想改应用桌面，去 `features/launcher/`；想改全局配色，去 `theme/`。`android/`、`ios/` 保留给平台配置和打包，日常 Flutter 页面开发主要在 `lib/`。

## 新功能如何接入

在 `features/功能名/` 新建页面及实际需要的逻辑文件，然后在 `app/feature_catalog.dart` 注册或更新一条 `AppFeature`，给它指定 `pageBuilder`。现有入口的 `id` 不要随意修改，因为常用栏按 `id` 保存位置。设置功能已经示范了页面、状态逻辑和入口如何连接。更细的操作示例见 [App README](../app/README.md#新增一个功能)。

当前不创建尚未使用的架构层。一个功能真正需要状态、数据读取或 Hub 通信时，再在该功能目录增加对应文件；不同功能共同使用的 Hub 通信代码出现后，再建立共享 `data/`。

## 数据与交互边界

1. 页面把操作交给该功能的状态逻辑，页面自身只负责展示、输入和布局。
2. 状态逻辑从 Repository 读取数据、发出命令，并给页面提供加载、成功、失败及离线状态。
3. Repository 负责缓存、刷新和错误转换；Service 只负责与 Hub 或本地存储通信。
4. Hub 是设备状态的权威来源。控制指令需要返回结果，并在失败时让用户看见实际状态，不能仅凭按钮点击就假定设备已执行。

Hub 的 API、实时更新方式、发现机制、认证方式和版本兼容策略，应在服务器端设计时一起确定。连接地址不可写死在页面代码中。

## 开发顺序

1. **连接中枢**：确定最小 API 契约，先支持手动配置地址、连通性检查和明确的断线提示；局域网自动发现后续加入。
2. **确定控制首页与 AI 入口**：根据真实设备、高频操作和 AI Agent 的交互方式设计，再决定是否增加一级页面；现在不放空 Tab。
3. **逐个实现应用入口**：优先接入真实设备与房间状态，建立 Service → Repository → 页面状态 → UI 的完整链路。
4. **设备控制**：加入指令执行结果、超时及失败反馈，再考虑乐观更新。
5. **平板体验与质量保障**：根据实际屏幕尺寸处理布局和触控目标，为有逻辑的 Service、Repository 和页面状态补测试。

在明确真实需求前，不增加空的 `usecases/`、多环境入口、路由框架或完整状态管理框架。
