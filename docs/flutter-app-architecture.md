# HomeLab Panel 工程规划

## 定位与现状

`app/` 是运行在家庭平板上的 Flutter 控制端。设备接入、自动化规则和状态的权威数据由局域网内的 HomeLab Hub 负责；Panel 负责展示状态、发出控制请求，以及清楚地呈现连接和操作结果。

目前已有可运行的双 Tab 外壳、可滚动的应用入口和占位功能页。Hub、通信协议和设备模型尚未确定，因此不提前引入网络、状态管理、路由或代码生成依赖。具体页面划分见[页面与交互规划](panel-page-plan.md)。

## 参考项目与取舍

| 参考 | 观察 | 在本项目中的取舍 |
| --- | --- | --- |
| [Flutter 官方架构指南](https://docs.flutter.dev/app-architecture/guide)与 [Compass 示例](https://github.com/flutter/samples/tree/main/compass_app/app/lib) | 将界面逻辑和数据访问分开，用 ViewModel、Repository、Service 表达职责；Compass 的共享数据层按类型组织，界面按功能组织。 | 沿用职责边界，但只在出现真实功能时创建类和目录。 |
| [Bloc 的 Flutter Todos 示例](https://github.com/felangel/bloc/tree/master/examples/flutter_todos/lib) | 按功能组织界面代码，入口、主题等放在应用级。 | 使用功能目录方便后续分别开发首页、设备和中枢连接；暂不因示例而引入 Bloc。 |
| [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples) | 同一应用展示多种状态管理方式，并提醒根据项目需求选择。 | 状态管理先使用 Flutter 自带能力；当异步状态和共享状态变复杂时再选型。 |

## 目录演进

当前已落地的目录：

```text
app/
├── android/                         # Android 平台工程
├── ios/                             # iOS / iPadOS 平台工程
├── lib/
│   ├── main.dart                    # 启动入口
│   ├── app/app.dart                 # MaterialApp、主题与应用级配置
│   ├── app/presentation/
│   │   └── panel_shell.dart         # 一级 Tab 与悬浮切换栏
│   └── features/
│       ├── launcher/presentation/   # 应用入口与占位功能页
│       └── dashboard/presentation/  # 总览占位页
├── test/                             # Tab 与入口导航测试
├── analysis_options.yaml
└── pubspec.yaml
```

新增功能时按实际需要扩展，而不是先创建空目录：

```text
lib/
├── features/
│   ├── launcher/presentation/      # 应用入口
│   ├── dashboard/presentation/     # 家庭概览
│   ├── hub_connection/presentation/# 发现、连接与连接状态
│   └── devices/presentation/       # 设备列表、详情与操作
├── data/
│   ├── models/                     # 应用使用的设备、房间等模型
│   ├── services/                   # Hub 协议客户端及本地存储适配
│   └── repositories/               # 缓存、刷新、错误映射与数据来源协调
└── ui/core/                        # 多个功能共用的主题与组件
```

`features/` 放用户能看到的功能；`data/` 放可能被多个功能共用的数据访问。单个页面的状态先留在该功能内。确实出现跨功能的复杂规则时，再提取领域层；确实需要多页面导航时，再增加路由目录。

## 数据与交互边界

1. 页面把操作交给该功能的状态逻辑，页面自身只负责展示、输入和布局。
2. 状态逻辑从 Repository 读取数据、发出命令，并给页面提供加载、成功、失败及离线状态。
3. Repository 负责缓存、刷新和错误转换；Service 只负责与 Hub 或本地存储通信。
4. Hub 是设备状态的权威来源。控制指令需要返回结果，并在失败时让用户看见实际状态，不能仅凭按钮点击就假定设备已执行。

Hub 的 API、实时更新方式、发现机制、认证方式和版本兼容策略，应在服务器端设计时一起确定。连接地址不可写死在页面代码中。

## 开发顺序

1. **连接中枢**：确定最小 API 契约，先支持手动配置地址、连通性检查和明确的断线提示；局域网自动发现后续加入。
2. **确定首页内容**：明确总览需要显示哪些真实状态、高频操作和异常信息，再替换当前占位页。
3. **逐个实现应用入口**：优先接入真实设备与房间状态，建立 Service → Repository → 页面状态 → UI 的完整链路。
4. **设备控制**：加入指令执行结果、超时及失败反馈，再考虑乐观更新。
5. **平板体验与质量保障**：根据实际屏幕尺寸处理布局和触控目标，为有逻辑的 Service、Repository 和页面状态补测试。

在明确真实需求前，不增加空的 `usecases/`、多环境入口、路由框架或完整状态管理框架。
