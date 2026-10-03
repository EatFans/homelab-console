# HomeLab Panel

本目录是 HomeLab 的 Flutter 平板端工程。它计划通过家庭局域网中的 HomeLab Hub 查看设备状态并发送控制指令。

目前仍处于原型阶段：应用可以运行，首页显示中枢尚未接入，尚未实现设备控制或与 Hub 通信。

## 本地运行

在本目录执行：

```sh
flutter pub get
flutter run
```

工程目录与实现顺序见[平板端工程规划](../docs/flutter-app-architecture.md)；整个项目的定位和各端职责见[仓库 README](../README.md)。
