# Panda 装修管家 - 项目运行指南

本文档将指导您如何在 Xcode 中运行 Panda 装修管家 iOS 应用。

## 📋 系统要求

在开始之前，请确保您的开发环境满足以下要求：

| 项目 | 要求 |
|------|------|
| **macOS** | 14.0 (Sonoma) 或更高版本 |
| **Xcode** | 15.0 或更高版本 |
| **iOS 模拟器** | iOS 17.0 或更高版本 |
| **Swift** | 5.9+ |
| **磁盘空间** | 至少 10 GB 可用空间 |

## 🚀 快速开始

### 第一步：克隆项目

```bash
# 克隆仓库到本地
git clone https://github.com/ZhangXFeng/panda.git

# 进入项目目录
cd panda
```

### 第二步：打开项目

#### 方法 1：使用命令行

```bash
# 如果项目包含 .xcworkspace 文件
open Panda.xcworkspace

# 如果只有 .xcodeproj 文件
open Panda.xcodeproj
```

#### 方法 2：使用 Xcode

1. 打开 Xcode
2. 选择 **File → Open**
3. 导航到项目目录
4. 选择 `Panda.xcworkspace` 或 `Panda.xcodeproj`
5. 点击 **Open**

### 第三步：配置项目

#### 1. 选择开发团队（如需要）

如果要在真机上运行，需要配置签名：

1. 在 Xcode 左侧导航栏中选择项目文件（蓝色图标）
2. 选择 **Panda** target
3. 进入 **Signing & Capabilities** 标签页
4. 在 **Team** 下拉菜单中选择您的开发者账号
5. 确保 **Automatically manage signing** 已勾选

> 💡 **提示**：如果只在模拟器上运行，可以跳过此步骤。

#### 2. 选择运行目标

在 Xcode 顶部工具栏中：

1. 点击设备选择器（位于运行按钮旁边）
2. 选择一个 iOS 17.0+ 的模拟器，例如：
   - iPhone 15
   - iPhone 15 Pro
   - iPhone 15 Pro Max
   - 或任何 iOS 17.0+ 设备

### 第四步：构建并运行

#### 使用 Xcode 界面

1. 按下 **⌘ + R** 或点击左上角的 **▶️ 播放按钮**
2. 等待项目编译（首次编译可能需要几分钟）
3. 应用将自动在选定的模拟器或设备上启动

#### 使用命令行

```bash
# 构建项目
xcodebuild -scheme Panda -destination 'platform=iOS Simulator,name=iPhone 15' build

# 运行项目
xcodebuild -scheme Panda -destination 'platform=iOS Simulator,name=iPhone 15' run
```

## 🏗️ 项目结构说明

```
Panda/
├── Panda/                      # 主应用代码
│   ├── App/                    # 应用入口
│   │   ├── PandaApp.swift      # App 生命周期
│   │   └── MainTabView.swift   # 主标签导航
│   ├── Features/               # 功能模块
│   │   ├── Budget/             # 预算管理
│   │   ├── Schedule/           # 进度管理
│   │   ├── Materials/          # 材料管理
│   │   ├── Projects/           # 项目管理
│   │   ├── Contacts/           # 通讯录
│   │   ├── Documents/          # 合同文档
│   │   ├── Journal/            # 装修日记
│   │   ├── Home/               # 首页
│   │   └── Profile/            # 个人中心
│   ├── Core/                   # 核心功能
│   │   ├── Database/           # 数据模型（SwiftData）
│   │   ├── Services/           # 服务层
│   │   └── Repositories/       # 数据仓储
│   ├── Shared/                 # 共享组件
│   │   ├── Components/         # UI 组件
│   │   └── Styles/             # 设计系统
│   └── Resources/              # 资源文件
│       └── Assets.xcassets/    # 图片资源
└── PandaTests/                 # 单元测试（待补充）
```

## 🎮 使用应用

### 初次启动

首次启动应用时，数据库是空的。您可以：

#### 选项 1：手动创建数据

1. 点击右上角的 **+** 按钮创建新项目
2. 填写项目信息（名称、房型、面积等）
3. 开始使用各项功能

#### 选项 2：生成测试数据（仅 Debug 模式）

1. 进入 **个人中心** 标签页
2. 滚动到底部的 **开发者选项** 部分
3. 点击 **生成测试数据**
4. 确认操作

> ⚠️ **注意**：生成测试数据会清除所有现有数据！

测试数据包含 4 个示例项目：
- 我的家（进行中）
- 爸妈的房子（刚开始）
- 出租公寓（即将完工）
- 新婚小窝（已完工）

### 主要功能导航

| 标签页 | 功能 |
|--------|------|
| 🏠 **首页** | 项目概览、快捷操作 |
| 💰 **预算** | 预算管理、支出记录 |
| 📅 **进度** | 装修阶段、任务管理 |
| 📦 **材料** | 材料清单、用量计算器 |
| 👤 **我的** | 个人中心、设置、数据导出 |

## 🔧 常见问题

### 1. 编译错误："Cannot find 'SwiftData' in scope"

**原因**：Xcode 版本过低或未选择正确的 iOS 版本。

**解决方案**：
- 确保 Xcode 版本 ≥ 15.0
- 确保部署目标设置为 iOS 17.0+
- 清理构建：**Product → Clean Build Folder** (⇧⌘K)

### 2. 模拟器启动失败

**解决方案**：
```bash
# 重置模拟器
xcrun simctl shutdown all
xcrun simctl erase all

# 重启 Xcode
```

### 3. "Signing for 'Panda' requires a development team"

**解决方案**：
- 如果在模拟器上运行：
  - 选择 **Signing & Capabilities**
  - 取消勾选 **Automatically manage signing**
  - 选择 **None** 作为 Team
- 如果在真机上运行：
  - 需要 Apple Developer 账号
  - 在 **Signing & Capabilities** 中选择您的开发团队

### 4. 编译速度慢

**优化方案**：
```bash
# 清理派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData

# 在 Xcode 中
# Preferences → Locations → Derived Data → 点击箭头图标 → 删除文件夹
```

### 5. SwiftData 相关错误

**解决方案**：
- 确保部署目标为 iOS 17.0+
- 检查 SwiftData 模型是否正确使用 `@Model` 宏
- 重启 Xcode 和模拟器

## 📱 在真机上运行

### 准备工作

1. **Apple Developer 账号**
   - 免费账号：可以在真机上运行 7 天
   - 付费账号（$99/年）：完整开发权限

2. **连接 iPhone**
   - 使用 USB-C 或 Lightning 线连接
   - 在 iPhone 上信任此电脑

### 配置步骤

1. **选择您的设备**
   - 在 Xcode 顶部设备选择器中选择已连接的 iPhone

2. **配置签名**
   - 选择项目 → **Panda** target → **Signing & Capabilities**
   - 选择您的 Team
   - 修改 Bundle Identifier（如果需要）

3. **信任开发者证书**
   - 首次运行时，在 iPhone 上会提示"不受信任的开发者"
   - 前往：**设置 → 通用 → VPN 与设备管理**
   - 找到您的开发者账号，点击 **信任**

4. **运行应用**
   - 按下 ⌘ + R 即可在真机上运行

## 🛠️ 开发工具推荐

### Xcode 插件

- **SwiftLint**：代码风格检查
- **SwiftFormat**：代码自动格式化

### 调试工具

- **Instruments**：性能分析（⌘ + I）
- **Memory Graph**：内存泄漏检测
- **View Hierarchy**：UI 调试（Debug → View Debugging → Capture View Hierarchy）

### 快捷键

| 功能 | 快捷键 |
|------|--------|
| 构建 | ⌘ + B |
| 运行 | ⌘ + R |
| 停止 | ⌘ + . |
| 清理 | ⇧⌘ + K |
| 快速打开 | ⇧⌘ + O |
| 查找文件 | ⌘ + P |
| 全局搜索 | ⇧⌘ + F |

## 📚 技术栈

- **语言**：Swift 5.9+
- **UI 框架**：SwiftUI
- **数据持久化**：SwiftData
- **架构模式**：MVVM + Clean Architecture
- **并发**：async/await
- **图表**：Swift Charts

## 🔗 相关资源

- **项目文档**：[PRD.md](./docs/PRD.md)
- **开发指南**：[CLAUDE.md](./CLAUDE.md)
- **SwiftUI 官方文档**：https://developer.apple.com/documentation/swiftui/
- **SwiftData 官方文档**：https://developer.apple.com/documentation/swiftdata/

## ❓ 获取帮助

如果遇到问题：

1. 查看本文档的 **常见问题** 部分
2. 查阅 [CLAUDE.md](./CLAUDE.md) 中的开发指南
3. 提交 Issue：https://github.com/ZhangXFeng/panda/issues
4. 查看 Apple 官方文档

## 📝 许可证

本项目仅供学习和参考使用。

---

**最后更新**：2026-02-05
**Xcode 版本**：15.0+
**iOS 版本**：17.0+
