# HomeLab

HomeLab 是一个面向家庭局域网的智能家居项目。家庭服务器作为控制中枢，负责连接和管理设备；平板端提供家庭成员日常使用的控制界面。各端的软件工程集中在同一个仓库中。

## 项目组成

| 组成 | 职责 | 当前状态 |
| --- | --- | --- |
| HomeLab Hub | 部署在家庭局域网服务器上的中枢，处理设备接入、状态和控制请求 | 尚未加入仓库 |
| HomeLab Panel | 运行在平板上的控制端，与 Hub 交互 | Flutter 原型，位于 [`app/`](app/) |

## 仓库结构

```text
.
├── app/    # HomeLab Panel：Flutter 平板端
└── docs/   # 跨工程的设计与规划文档
```

目前仓库只有平板端的初始 Flutter 工程。界面仍是占位首页，尚未接入家庭设备或 Hub；服务器端的技术选型、目录和部署方式也尚未确定。平板端的后续工程安排见[Flutter 工程规划](docs/flutter-app-architecture.md)。

## 运行现有平板端

安装 Flutter 和相应平台的开发工具后，在仓库根目录执行：

```sh
cd app
flutter pub get
flutter run
```

平板端的当前实现、目录和开发命令见 [`app/README.md`](app/README.md)。后续加入 Hub 时，在根 README 中补充它的目录、启动方式，以及平板端连接 Hub 的配置方法。
