import 'package:flutter/material.dart';
import 'package:homelab_panel/app/app_feature.dart';
import 'package:homelab_panel/features/settings/settings_controller.dart';
import 'package:homelab_panel/features/settings/settings_page.dart';

/// 桌面入口清单。新增功能时在这里注册一次；具体 UI 和逻辑放到 features/功能名/。
List<AppFeature> createFeatureCatalog(SettingsController settings) => [
  const AppFeature(id: 'rooms', title: '房间', icon: Icons.meeting_room_rounded),
  const AppFeature(id: 'devices', title: '设备', icon: Icons.devices_rounded),
  const AppFeature(id: 'scenes', title: '场景', icon: Icons.auto_awesome_rounded),
  const AppFeature(id: 'lights', title: '灯光', icon: Icons.lightbulb_rounded),
  const AppFeature(id: 'climate', title: '环境', icon: Icons.thermostat_rounded),
  const AppFeature(id: 'curtains', title: '窗帘', icon: Icons.blinds_rounded),
  const AppFeature(id: 'music', title: '音乐', icon: Icons.music_note_rounded),
  const AppFeature(id: 'security', title: '安防', icon: Icons.shield_rounded),
  const AppFeature(id: 'cameras', title: '摄像头', icon: Icons.videocam_rounded),
  const AppFeature(id: 'energy', title: '能耗', icon: Icons.bolt_rounded),
  const AppFeature(id: 'automation', title: '自动化', icon: Icons.sync_rounded),
  AppFeature(
    id: 'settings',
    title: '设置',
    icon: Icons.settings_rounded,
    pageBuilder: (_) => SettingsPage(controller: settings),
  ),
];
